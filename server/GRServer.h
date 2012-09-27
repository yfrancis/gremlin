/*
 * Created by Youssef Francis on September 25th,  2012.
 */

#import "GRTask.h"
#import "GRServerDelegateProtocol.h"

@interface GRServer : NSObject
{
    CFMessagePortRef local_port_;
    CFRunLoopSourceRef rl_source_;
    NSThread* serverThread_;
}

@property (assign) id<GRServerImportDelegate> importDelegate;

+ (GRServer*)sharedServer;
- (void)informClientImportCompleteForTask:(GRTask*)task;
- (void)run;

@end
