/*
 * Created by Youssef Francis on September 25th, 2012.
 */

#import "GRClient.h"
#include "GRIPCProtocol.h"

#include <mach-o/dyld.h>

@interface GRClient (Private)
+ (BOOL)_portIsValid:(CFMessagePortRef)port;
- (NSString*)_executableName;
- (CFMessagePortRef)_serverPort;
- (CFMessagePortRef)_localPort;
- (void)_destroyLocalPort;
- (CFDataRef)_createMessageWithInfo:(CFDictionaryRef)info;
- (void)_sendMessage:(CFDataRef)data;
@end

@protocol GRClientDelegate <NSObject>
+ (void)_handleImportFailureWithInfo:(NSDictionary*)info;
+ (void)_handleImportSuccessWithInfo:(NSDictionary*)info;
@end

static CFDictionaryRef
_GRC_createUnwrappedMessage(CFDataRef data)
{
    CFPropertyListRef info = NULL;
    if (data != NULL) {
        info = CFPropertyListCreateWithData(kCFAllocatorDefault,
                                            data,
                                            kCFPropertyListImmutable,
                                            NULL,
                                            NULL);
    }
    return (CFDictionaryRef)info;
}

static CFDataRef 
GRC_messageReceived(CFMessagePortRef local, 
                    SInt32 msgid, 
                    CFDataRef data, 
                    void* info) 
{    
    Class<GRClientDelegate> delegate = (Class<GRClientDelegate>)info;
    
    switch (msgid) {
        case GREMLIN_SUCCESS: {
                CFDictionaryRef dict = _GRC_createUnwrappedMessage(data);
                [delegate _handleImportSuccessWithInfo:(NSDictionary*)dict];
                CFRelease(dict);
        } break;
        case GREMLIN_FAILURE: {
                CFDictionaryRef dict = _GRC_createUnwrappedMessage(data);
                [delegate _handleImportFailureWithInfo:(NSDictionary*)dict];
                CFRelease(dict);
        } break;
        default:
            break;
    }

    return NULL;
}

void 
GRC_localPortInvalidated(CFMessagePortRef port, void*info)
{
    // deallocate the port once it's been successfully
    // invalidated
    CFRelease(port);
}

void 
GRC_serverPortInvalidated(CFMessagePortRef port, void*info)
{
    NSLog(@"PORT INVALIDATED LOLOLOLOL");
    
    // looks like the server died (crashed), we should
    // inform the client. since we have no pointer to
    // either the delegate or listener, we should post
    // a notiifcation, and the delegate will handle it
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"co.cocoanuts.gremlin.server_died"
                      object:nil];
}

@implementation GRClient
@synthesize localPortName = localPortName_;
@synthesize delegate = delegate_;

+ (GRClient*)sharedClient
{
    static dispatch_once_t once;
    static GRClient* sharedClient;
    dispatch_once(&once, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

+ (BOOL)_portIsValid:(CFMessagePortRef)port
{
    return (port != NULL &&
            CFMessagePortIsValid(port));
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        // let's set up a name for the local port here
        NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];

        // our client is not in a bundle, get executable name instead
        if (bundleID == nil)
            bundleID = [self _executableName];

        self.localPortName = [bundleID stringByAppendingString:@".gremlin"];
    }
    return self;
}

- (void)_sendMessage:(CFDataRef)msg
{
    CFMessagePortRef port = [self _serverPort];
    if (port)
        CFMessagePortSendRequest(port, 
                                 GREMLIN_IMPORT, 
                                 msg, 
                                 0, 
                                 0, 
                                 NULL, 
                                 NULL);
}

- (CFDataRef)_createMessageWithInfo:(CFDictionaryRef)info
{
    CFDataRef odat = CFPropertyListCreateXMLData(kCFAllocatorDefault, info);
    CFIndex olen = CFDataGetLength(odat);
    char* obuf = (char*)CFDataGetBytePtr(odat);

    // pad with 32 bytes for backwards compatibility
    int nlen = olen + 32;
    char* nbuf = (char*)malloc(nlen);
    memset(nbuf, 0, nlen);
    memcpy(nbuf, obuf, olen);
    
    CFDataRef ndat = CFDataCreate(kCFAllocatorDefault, (UInt8*)nbuf, nlen);
    return ndat;
}

- (NSString*)_executableName
{
    char* path = malloc(1024*sizeof(char));
    uint32_t size = 1024;

    if (_NSGetExecutablePath(path, &size) < 0)
        path = realloc(path, size*sizeof(char));

    // assert(path != nil);

    NSString* execPath = [NSString stringWithUTF8String:path];

    free(path);

    return [execPath lastPathComponent];
}

- (void)_destroyLocalPort
{
    if (local_port_ != NULL) {
        CFMessagePortInvalidate(local_port_);
        local_port_ = NULL;
    }
}

- (CFMessagePortRef)_localPort
{
    if (local_port_ == NULL) {
        CFMessagePortContext context = {0, (void*)delegate_, NULL, NULL, NULL};
        local_port_ = CFMessagePortCreateLocal(NULL,
                                              (CFStringRef)localPortName_,
                                              GRC_messageReceived,
                                              &context, 
                                              NULL);
        
        CFMessagePortSetInvalidationCallBack(local_port_, 
                                             GRC_localPortInvalidated);
        
        // if rl_source_ already exists, remove it from the runloop
        if (rl_source_ != NULL) {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(),
                                  rl_source_,
                                  kCFRunLoopDefaultMode);
            CFRelease(rl_source_);
            rl_source_ = NULL;
        }

        rl_source_ = CFMessagePortCreateRunLoopSource(NULL, local_port_, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(),
                           rl_source_,
                           kCFRunLoopDefaultMode);
    }

    return local_port_; 
}

- (CFMessagePortRef)_serverPort
{
    if (server_port_ == NULL || 
        CFMessagePortIsValid(server_port_) == NO) {
        if (server_port_ != NULL) 
            CFRelease(server_port_);
        
        const CFStringRef serverPortName = 
            CFSTR(gremlind_MessagePortName);
        server_port_ = CFMessagePortCreateRemote(NULL, serverPortName);
        CFMessagePortSetInvalidationCallBack(server_port_,
                                             GRC_serverPortInvalidated);
    }

    return server_port_;
}

- (BOOL)registerForNotifications:(id)delegate
{
    self.delegate = delegate;
    return [GRClient _portIsValid:[self _localPort]];
}

- (void)unregisterForNotifications
{
    self.delegate = nil;
    [self _destroyLocalPort];
}

- (void)sendServerMessage:(NSMutableDictionary*)msgInfo
             haveListener:(BOOL)haveListener
{
    if (haveListener == YES) {
        [msgInfo setObject:localPortName_
                    forKey:@"center"];
    }

    CFDataRef msg = [self _createMessageWithInfo:(CFDictionaryRef)msgInfo];
    if (msg != NULL) {
        [self _sendMessage:msg];
        CFRelease(msg);
    }
}

- (BOOL)haveGremlin
{
    return [GRClient _portIsValid:[self _serverPort]];
}

@end

