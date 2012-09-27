/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRDisplayManager.h"
#include "GRIPCProtocol.h"
#import <AppSupport/CPDistributedMessagingCenter.h>

@implementation GRDisplayManager

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
