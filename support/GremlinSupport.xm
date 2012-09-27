#include "GRIPCProtocol.h"
#import <AppSupport/CPDistributedMessagingCenter.h>

@interface GRSBSupport : NSObject
@end

@implementation GRSBSupport

+ (GRSBSupport*)sharedInstance
{
    static dispatch_once_t once;
    static GRSBSupport* sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)runServer
{
    // set up listener server
    NSString* centerName = @GRSBSupport_MessagePortName;
    CPDistributedMessagingCenter* server;
    server = [[CPDistributedMessagingCenter centerNamed:centerName] retain];

    // schedule the server on the current runloop
    [server runServerOnCurrentThread];

    // register for incoming messages
    [server registerForMessageName:@"updateStatusBarIcon"
                            target:self
                          selector:@selector(updateStatusBarIcon:userInfo:)];
}

- (NSDictionary*)updateStatusBarIcon:(NSString*)m userInfo:(NSDictionary*)info
{
    BOOL showIcon = [[info objectForKey:@"showIcon"] boolValue];
    if (showIcon == YES)
        NSLog(@"show the icon");
    else
        NSLog(@"hide the icon");

    return nil;
}

@end

%ctor {
   [[GRSBSupport sharedInstance] runServer];
}
