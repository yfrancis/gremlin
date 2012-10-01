/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRDisplayManager.h"
#include "GRIPCProtocol.h"
#import <AppSupport/CPDistributedMessagingCenter.h>

@implementation GRDisplayManager

+ (GRDisplayManager*)sharedManager
{
    static dispatch_once_t once;
    static GRDisplayManager* sharedManager;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (oneway void)release {}
- (NSUInteger)retainCount { return NSUIntegerMax; }
- (id)retain { return self; }
- (id)autorelease { return self; }

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    if ([keyPath isEqualToString:@"hasActiveTasks"]) {
        NSNumber* active = [change objectForKey:NSKeyValueChangeNewKey];
        NSLog(@"active value changed to: %@", active);

        NSString* centerName = @GRSBSupport_MessagePortName;
        CPDistributedMessagingCenter* server;
        server = [CPDistributedMessagingCenter centerNamed:centerName];

        NSDictionary* info;
        info = [NSDictionary dictionaryWithObject:active
                                           forKey:@"showIcon"];
        [server sendMessageName:@"updateStatusBarIcon" 
                       userInfo:info];
    }
}

@end
