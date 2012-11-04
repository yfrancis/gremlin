/*
 * Created by Youssef Francis on November 4th, 2012.
 */

#import "GRManifestListener.h"
#import "GRIPCProtocol.h"
#import "GRTask.h"

@interface CPDistributedNotificationCenter : NSObject
+ (CPDistributedNotificationCenter*)centerNamed:(NSString*)centerName;
- (void)startDeliveringNotificationsToMainThread;
- (void)stopDeliveringNotifications;
@end

static CPDistributedNotificationCenter* center_;
static id<GRManifestListenerDelegate> delegate_;
static BOOL isListening_ = NO;

@implementation GRManifestListener

+ (void)serverReset:(NSNotification*)note
{
    [delegate_ manifestServerReset];
}

+ (void)tasksUpdated:(NSNotification*)note
{
    NSDictionary* receivedInfo = [note userInfo];
    NSMutableArray* tasks = [NSMutableArray array];
    for (NSDictionary* taskInfo in [receivedInfo allValues]) {
        [tasks addObject:[GRTask taskWithInfo:taskInfo]];
    }
    [delegate_ manifestTasksUpdated:tasks];
}

+ (BOOL)startListening:(id<GRManifestListenerDelegate>)delegate
{
    if (isListening_ == YES)
        return NO;

    delegate_ = delegate;

    center_ = [CPDistributedNotificationCenter centerNamed:GRManifest_NCName];
    if (center_ == nil)
        return NO;

    [center_ startDeliveringNotificationsToMainThread];

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(serverReset:)
               name:GRManifest_serverResetNotification
             object:nil];

    [nc addObserver:self
           selector:@selector(tasksUpdated:)
               name:GRManifest_tasksUpdatedNotification
             object:nil];

    [center_ retain];

    return YES;
}

+ (void)stopListening
{
    [center_ stopDeliveringNotifications];
    isListening_ = NO;
    delegate_ = nil;
}

@end
