/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRServer.h"
#import "GRIPCProtocol.h"

@interface GRServer (Private)
- (void)handleImportRequest:(NSDictionary*)info;
@end

static CFDataRef 
messageReceived(CFMessagePortRef local,
                SInt32 msgid,
                CFDataRef completeData,
                void* server)
{
    CFPropertyListRef info = NULL;

    switch (msgid) {
        case GREMLIN_IMPORT_LEGACY: {
            if (completeData == NULL)
                break;

            // API maintains backward-compatibility, but ignores digest
            int dataLen = CFDataGetLength(completeData);
            UInt8* dataPtr = (UInt8*)CFDataGetBytePtr(completeData);

            if (dataLen == 0 || dataPtr == NULL)
                break;

            CFDataRef data;
            data = CFDataCreate(kCFAllocatorDefault, dataPtr, dataLen-32);

            if (data == NULL)
                break;

            // Reconstitute the dictionary using the XML data.
            info = CFPropertyListCreateFromXMLData(kCFAllocatorDefault,
                                                   data,
                                                   kCFPropertyListImmutable,
                                                   NULL);
            CFRelease(data);
        } break;
        case GREMLIN_IMPORT: {
            // Reconstitute the dictionary using the XML data.
            info = CFPropertyListCreateFromXMLData(kCFAllocatorDefault,
                                                   completeData,
                                                   kCFPropertyListImmutable,
                                                   NULL);
        } break;
        default:
            return NULL;
    }

    if (info != NULL) {
        [(id)server handleImportRequest:(NSDictionary*)info];
        CFRelease(info);
    }
    
    return NULL;
}

static void 
portInvalidated(CFMessagePortRef port, void* info)
{
    CFRelease(port);
}

static BOOL 
portIsValid(CFMessagePortRef port)
{
    return (port != NULL && CFMessagePortIsValid(port));
}

static CFMessagePortRef 
createRemoteMessagePortForClient(CFStringRef client)
{
    if (client != NULL) {
        CFMessagePortRef port = CFMessagePortCreateRemote(NULL, client);
        if (portIsValid(port) == YES) {
            CFMessagePortSetInvalidationCallBack(port, portInvalidated);
            return port;
        }
        else {
            if (port != NULL)
                CFRelease(port);
        }
    }
    return NULL;
}

static CFMessagePortRef 
createLocalMessagePort(void* server)
{
    CFStringRef localPortName = CFSTR(gremlind_MessagePortName);
    CFMessagePortContext context = {0, server, NULL, NULL, NULL};
    CFMessagePortRef local_port;
    local_port = CFMessagePortCreateLocal(NULL,
                                         localPortName,
                                         messageReceived,
                                         &context,
                                         NULL); 

    CFMessagePortSetInvalidationCallBack(local_port, 
                                         portInvalidated);

    CFRunLoopSourceRef source;
    source = CFMessagePortCreateRunLoopSource(NULL, local_port, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);

    return local_port;
}

static void
sendImportCompletionStatusWithInfo(CFDictionaryRef info,
                                       Boolean success)
{
    if (info == NULL)
        return;

    SInt32 apiVersion = 0;
    CFNumberRef apiNum = CFDictionaryGetValue(info, CFSTR("apiVersion"));
    if (apiNum != NULL)
        CFNumberGetValue(apiNum, kCFNumberSInt32Type, &apiVersion);
    CFStringRef client = CFDictionaryGetValue(info, CFSTR("client"));

    int msgid = 0;
    CFDataRef data = NULL;

    // wrap task info for transmission
    if (apiVersion < 2) {
        CFStringRef path = CFDictionaryGetValue(info, CFSTR("path"));

        // determine msgid
        msgid = (success == true) ? GREMLIN_SUCC_LEGACY : GREMLIN_FAIL_LEGACY;

        if (path != NULL) {
            // clients using old API expect only a path
            data = CFStringCreateExternalRepresentation(kCFAllocatorDefault,
                                                        path,
                                                        kCFStringEncodingUTF8,
                                                        0);
        }
    }
    else {
        // determine msgid for new API
        msgid = (success == true) ? GREMLIN_SUCCESS : GREMLIN_FAILURE;

        // clients using apiVersion > 2 expect a dictionary
        data = CFPropertyListCreateData(kCFAllocatorDefault,
                                        info,
                                        kCFPropertyListBinaryFormat_v1_0,
                                        0,
                                        NULL);
    }

    if (data == NULL)
        data = CFDataCreate(kCFAllocatorDefault, NULL, 0);

    // create remote port to communicate with client
    CFMessagePortRef port;
    port = createRemoteMessagePortForClient(client);

    if (portIsValid(port) == YES) {
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

- (void)handleImportRequest:(NSDictionary*)info
{
    NSString* client = [info objectForKey:@"center"];
    NSInteger apiVersion = [[info objectForKey:@"apiVersion"] integerValue];
    NSArray* files = [info objectForKey:@"import"];
    
    [files enumerateObjectsUsingBlock:^(id info, NSUInteger idx, BOOL* stop) {
        GRTask* task = nil;
        if ([info isKindOfClass:[NSDictionary class]]) {
            task = [GRTask taskWithInfo:(NSDictionary*)info];
            task.client = client;
            task.apiVersion = apiVersion;
        }
        else if ([info isKindOfClass:[NSString class]]) {
            task = [GRTask taskForUUID:nil
                                  path:(NSString*)info
                                client:client
                            apiVersion:apiVersion
                             mediaKind:nil
                           destination:nil
                              metadata:nil];
        }
       
        if (task != nil)
            [importDelegate importTask:task];
    }];
}

- (void)signalImportCompleteForTask:(GRTask*)task
                             status:(BOOL)status
                              error:(NSError*)error
{
    NSDictionary* info = [task info];

    if (error.userInfo != nil) {
        NSMutableDictionary* tmp;
        tmp = [NSMutableDictionary dictionaryWithDictionary:info];
        [tmp setObject:error.userInfo forKey:@"error_info"];
        info = tmp;
    }

    sendImportCompletionStatusWithInfo((CFDictionaryRef)info,
                                       (Boolean)status);
}

- (BOOL)run
{
    // set up a local port to listen for incoming import requests
    return (createLocalMessagePort((void*)self) != NULL);
}

@end
