/*
 * Created by Youssef Francis on September 25th, 2012.
 */

@interface GRClient : NSObject 
{
    CFMessagePortRef local_port_;
    CFRunLoopSourceRef rl_source_;
    CFMessagePortRef server_port_;
}

@property (assign) id delegate;
@property (retain) NSString* localPortName;

+ (GRClient*)sharedClient;

- (BOOL)registerForNotifications:(id)delegate;
- (void)unregisterForNotifications;

- (BOOL)sendServerMessage:(NSDictionary*)msgInfo
             haveListener:(BOOL)haveListener;
- (BOOL)haveGremlin;

@end
