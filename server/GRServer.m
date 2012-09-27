#import "GRServer.h"
#import "GRIPCProtocol.h"

@interface GRServer (Private)
+ (BOOL)_portIsValid:(CFMessagePortRef)port;
- (void)_handlePortInvalidated:(CFMessagePortRef)port;
- (void)_handleIncomingMessage:(int)msgid withInfo:(NSDictionary*)info;
- (void)_sendClientMessageForTask:(GRTask*)task;
- (CFMessagePortRef)_createMessagePortForTask:(GRTask*)task;
- (CFMessagePortRef)_createLocalMessagePort;
@end

CFDataRef GRS_messageReceived(CFMessagePortRef local, 
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

    [(id)server _handleIncomingMessage:msgid withInfo:(NSDictionary*)info];

    CFRelease(info);

    return NULL;
}

void GRS_portInvalidated(CFMessagePortRef port, void* info)
{
    if (info != NULL)
        [(id)info _handlePortInvalidated:port];
    else
        CFRelease(port);
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

+ (BOOL)_portIsValid:(CFMessagePortRef)port
{
    return (port != NULL && CFMessagePortIsValid(port));
}

- (CFMessagePortRef)_createRemoteMessagePortForTask:(GRTask*)task
{
    CFStringRef client = (CFStringRef)task.client;
    if (client != nil) {
        CFMessagePortRef port = CFMessagePortCreateRemote(NULL, client);
        if ([GRServer _portIsValid:port]) {
            CFMessagePortSetInvalidationCallBack(port, GRS_portInvalidated);
            return port;
        }
    }
    return NULL;
}

- (CFMessagePortRef)_createLocalMessagePort
{
    CFStringRef localPortName = CFSTR(gremlind_MessagePortName);
    CFMessagePortContext context = {0, (void*)self, NULL, NULL, NULL};
    local_port_ = CFMessagePortCreateLocal(NULL,
                                           localPortName,
                                           GRS_messageReceived,
                                           &context,
                                           NULL);	
    CFMessagePortSetInvalidationCallBack(local_port_, GRS_portInvalidated);

    rl_source_ = CFMessagePortCreateRunLoopSource(NULL, local_port_, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rl_source_, kCFRunLoopDefaultMode);

    return local_port_;
}

- (void)_handlePortInvalidated:(CFMessagePortRef)port
{
    // our local port should never be invalidated, if it is, we
    // need to recreate it and re-add it to the runloop
    if (CFEqual(port, local_port_)) {
        // deallocate the old port, we'll be making a new one
        CFRelease(local_port_);
        local_port_ = NULL;

        // remove the old runloop source from the current runloop
        if (rl_source_ != NULL) {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), 
                                  rl_source_,
                                  kCFRunLoopDefaultMode);
            CFRelease(rl_source_);
            rl_source_ = NULL;
        }

        [self _createLocalMessagePort];
    }
}

- (void)_handleIncomingMessage:(int)msgid withInfo:(NSDictionary*)info
{
    NSLog(@"%@ _handleIncomingMessage:%d, %@", self, msgid, info);

    switch (msgid) {
        case GREMLIN_IMPORT: {
            NSString* client = [info objectForKey:@"center"];
            NSArray* files = [info objectForKey:@"import"];

            for (id file in files) {
                NSString* filePath, * destination = nil;
                if ([file isKindOfClass:[NSDictionary class]]) {
                    filePath = [file objectForKey:@"path"];
                    destination = [file objectForKey:@"destination"];
                }
                else if ([file isKindOfClass:[NSString class]])
                    filePath = file;
                else
                    continue;
                
                NSLog(@"importDelegate: %@", importDelegate);

                [importDelegate importFile:filePath
                                    client:client
                               destination:destination];
            }
        } break;

        default:
            break;
    }
}

- (void)_sendClientMessageForTask:(GRTask*)task
{
    CFDataRef data;
    data = (CFDataRef)[task.path dataUsingEncoding:NSUTF8StringEncoding];

    CFMessagePortRef port;
    port = [self _createRemoteMessagePortForTask:task];

    int msgid = task.successful ? GREMLIN_SUCC : GREMLIN_FAIL;

    if (port != NULL)
        CFMessagePortSendRequest(port, msgid, data, 0, 0, NULL, NULL);
}

- (void)informClientImportCompleteForTask:(GRTask*)task
{
    [self performSelector:@selector(_sendClientMessageForTask:)
                 onThread:serverThread_
               withObject:task
            waitUntilDone:NO];
}

- (void)run
{
    NSAutoreleasePool* pool = [NSAutoreleasePool new];

    serverThread_ = [[NSThread currentThread] retain];

    [self _createLocalMessagePort];

    CFRunLoopRun();

    NSLog(@"gremlind server thread terminated!");

    if (local_port_ != NULL)
        CFMessagePortInvalidate(local_port_);

    [serverThread_ release];
    serverThread_ = nil;

    [pool drain];
}

@end
