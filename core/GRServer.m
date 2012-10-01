#import "GRServer.h"
#import "GRIPCProtocol.h"

@interface GRServer (Private)
- (void)_handleImportRequest:(NSDictionary*)info;
@end

static CFDataRef 
GRS_messageReceived(CFMessagePortRef local,
                    SInt32 msgid,
                    CFDataRef completeData,
                    void* server)
{
    if (completeData == NULL)
        return NULL;

    // API maintains backward-compatibility, but ignores digest
    int dataLen = CFDataGetLength(completeData);
    UInt8* dataPtr = (UInt8*)CFDataGetBytePtr(completeData);

    if (dataLen == 0 || dataPtr == NULL)
        return NULL;

    CFDataRef data = CFDataCreate(kCFAllocatorDefault, dataPtr, dataLen-32);

    if (data == NULL)
        return NULL;

    // Reconstitute the dictionary using the XML data.
    CFPropertyListRef info;
    info = CFPropertyListCreateFromXMLData(kCFAllocatorDefault,
                                           data,
                                           kCFPropertyListImmutable,
                                           NULL);
    CFRelease(data);

    switch (msgid) {
        case GREMLIN_IMPORT:
            [(id)server _handleImportRequest:(NSDictionary*)info];
            break;
        default:
            break;
    }

    CFRelease(info);

    return CFRetain(completeData);
}

static void 
GRS_portInvalidated(CFMessagePortRef port, void* info)
{
    NSLog(@"message port invalidated");
    CFRelease(port);
}

static BOOL 
GRS_portIsValid(CFMessagePortRef port)
{
    return (port != NULL && CFMessagePortIsValid(port));
}

static CFMessagePortRef 
GRS_createRemoteMessagePortForClient(CFStringRef client)
{
    if (client != NULL) {
        CFMessagePortRef port = CFMessagePortCreateRemote(NULL, client);
        if (GRS_portIsValid(port) == YES) {
            CFMessagePortSetInvalidationCallBack(port, GRS_portInvalidated);
            return port;
        }
    }
    return NULL;
}

static CFMessagePortRef 
GRS_createLocalMessagePort(void* server)
{
    CFStringRef localPortName = CFSTR(gremlind_MessagePortName);
    CFMessagePortContext context = {0, server, NULL, NULL, NULL};
    CFMessagePortRef local_port;
    local_port = CFMessagePortCreateLocal(NULL,
                                         localPortName,
                                         GRS_messageReceived,
                                         &context,
                                         NULL);	

    CFMessagePortSetInvalidationCallBack(local_port, 
                                         GRS_portInvalidated);

    CFRunLoopSourceRef source;
    source = CFMessagePortCreateRunLoopSource(NULL, local_port, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);

    return local_port;
}

static void
GRS_sendImportCompletionStatusToClient(CFStringRef uuid,
                                       CFStringRef path,
                                       CFStringRef client,
                                       CFIndex apiVersion,
                                       Boolean success,
                                       CFErrorRef error)
{
    int msgid = 0;
    CFDataRef data = NULL;

    // wrap task info for transmission
    if (apiVersion < 2) {
        // determine msgid
        msgid = (success == true) ? GREMLIN_SUCC_LEGACY : GREMLIN_FAIL_LEGACY;

        // clients using old API expect only a path
        data = CFStringCreateExternalRepresentation(kCFAllocatorDefault,
                                                    path,
                                                    kCFStringEncodingUTF8,
                                                    0);
    }
    else {
        // determine msgid for new API
        msgid = (success == true) ? GREMLIN_SUCCESS : GREMLIN_FAILURE;

        // clients using apiVersion > 2 expect a dictionary
        // encapsulating import info and results
        CFDictionaryRef dict;
        int keyCount = 2;
        CFDictionaryRef error_info = NULL;
        if (error != NULL) {
            keyCount += 1;
            error_info = CFErrorCopyUserInfo(error);
        }

        const void* keys[] = {CFSTR("uuid"), CFSTR("path"), CFSTR("error_info")};
        const void* values[] = {uuid, path, error_info};

        dict = CFDictionaryCreate(kCFAllocatorDefault,
                                  keys,
                                  values,
                                  keyCount,
                                  &kCFTypeDictionaryKeyCallBacks,
                                  &kCFTypeDictionaryValueCallBacks);
        
        if (error_info != NULL)
            CFRelease(error_info);

        data = CFPropertyListCreateData(kCFAllocatorDefault,
                                        dict,
                                        kCFPropertyListBinaryFormat_v1_0,
                                        0,
                                        NULL);
        CFRelease(dict);
    }

    if (data == NULL)
        data = CFDataCreate(kCFAllocatorDefault, NULL, 0);

    // create remote port to communicate with client
    CFMessagePortRef port;
    port = GRS_createRemoteMessagePortForClient(client);

    if (GRS_portIsValid(port) == YES) {
        // transmit message to client
        CFMessagePortSendRequest(port, msgid, data, 0, 0, NULL, NULL);
        
        // invalidate the port once we are done with it
        CFMessagePortInvalidate(port);
    }
    else {
        if (port != NULL)
            CFRelease(port);
    }

    CFRelease(data);
}


@implementation GRServer
@synthesize importDelegate;

+ (GRServer*)sharedServer
{
    static dispatch_once_t once;
    static GRServer* sharedServer;
    dispatch_once(&once, ^{
        sharedServer = [[self alloc] init];
    });
    return sharedServer;
}

- (oneway void)release {}
- (NSUInteger)retainCount { return NSUIntegerMax; }
- (id)retain { return self; }
- (id)autorelease { return self; }

- (void)_handleImportRequest:(NSDictionary*)info
{
    NSLog(@"_handleImportRequest: %@", info);

    NSString* client = [info objectForKey:@"center"];
    NSArray* files = [info objectForKey:@"import"];
    NSInteger apiVersion = [[info objectForKey:@"apiVersion"] integerValue];

    [files enumerateObjectsUsingBlock:^(id file, NSUInteger idx, BOOL* stop) {
        NSString* uuid, * filePath, * destination = nil;
        if ([file isKindOfClass:[NSDictionary class]]) {
            uuid = [file objectForKey:@"uuid"];
            filePath = [file objectForKey:@"path"];
            destination = [file objectForKey:@"destination"];
        }
        else if ([file isKindOfClass:[NSString class]])
            filePath = file;
        else
            return;
        
        [importDelegate importTask:uuid
                              path:filePath
                            client:client
                        apiVersion:apiVersion
                       destination:destination];
    }];
}

- (void)signalImportCompleteForTask:(NSString*)uuid
                               path:(NSString*)path
                             client:(NSString*)client
                         apiVersion:(NSInteger)apiVersion
                             status:(BOOL)status
                              error:(NSError*)error
{
    GRS_sendImportCompletionStatusToClient((CFStringRef)uuid,
                                           (CFStringRef)path, 
                                           (CFStringRef)client,
                                           (CFIndex)apiVersion,
                                           (Boolean)status,
                                           (CFErrorRef)error);
}

- (void)run
{
    // set up a local port to listen for incoming import requests
    GRS_createLocalMessagePort((void*)self);
}

@end
