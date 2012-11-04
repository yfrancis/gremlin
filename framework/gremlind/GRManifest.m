/*
 * Created by Youssef Francis on October 1st, 2012.
 */

#import "GRManifest.h"
#import "GRIPCProtocol.h"

#define kManifestDir [NSHomeDirectory() stringByAppendingPathComponent: \
                        @"Library/Gremlin"]
#define kActivityFile [kManifestDir stringByAppendingPathComponent: \
                        @"activity.plist"]
#define kHistoryFile [kManifestDir stringByAppendingPathComponent: \
                        @"history.plist"]

#define kClientDidStartListeningNotificationName \
    @"CPDistributedNotificationCenterClientDidStartListeningNotification"

@interface CPDistributedNotificationCenter : NSObject
+ (CPDistributedNotificationCenter*)centerNamed:(NSString*)centerName;
- (void)runServer;
- (void)postNotificationName:(NSString*)name;
- (void)postNotificationName:(NSString*)name userInfo:(NSDictionary*)info;
@end

static NSMutableDictionary* activity_ = nil;
static CPDistributedNotificationCenter* center_ = nil;

@implementation GRManifest

+ (void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        activity_ = [NSMutableDictionary new];
        [[NSFileManager defaultManager] createDirectoryAtPath:kManifestDir
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];

        center_ = [CPDistributedNotificationCenter centerNamed:
                    GRManifest_NCName];
        [center_ runServer];        
        [center_ retain];
    });
}

#pragma mark Getters

+ (NSMutableDictionary*)activity
{
    return [NSMutableDictionary dictionaryWithContentsOfFile:kActivityFile];
}

+ (NSMutableDictionary*)history
{
    return [NSMutableDictionary dictionaryWithContentsOfFile:kHistoryFile];
}

#pragma mark Persistence

+ (void)synchronize
{
    [activity_ writeToFile:kActivityFile atomically:YES];
}

+ (void)addTask:(GRTask*)task
{
    @synchronized(activity_) {
        NSDictionary* info = [task info];
        [activity_ setObject:info forKey:task.uuid];
        [self synchronize];
        [center_ postNotificationName:GRManifest_tasksUpdatedNotification
                             userInfo:activity_];
    }
}

+ (void)removeTask:(GRTask*)task
            status:(BOOL)status
             error:(NSError*)error
{
    @synchronized(activity_) {
        [activity_ removeObjectForKey:task.uuid];
            
        NSMutableDictionary* info;
        info = [NSMutableDictionary dictionaryWithDictionary:[task info]];
        [info setObject:[NSNumber numberWithBool:status] forKey:@"status"];

        if (error != nil)
            [info setObject:[error description] forKey:@"error"];
    
        NSMutableDictionary* history = [GRManifest history];
        [history setObject:info forKey:task.uuid];
        [history writeToFile:kHistoryFile atomically:YES];
        
        [self synchronize];
        [center_ postNotificationName:GRManifest_tasksUpdatedNotification
                             userInfo:activity_];
    }
}

#pragma mark Recovery

+ (NSArray*)recoveredTasks
{
    NSDictionary* mfst = [GRManifest activity];
    [[NSFileManager defaultManager] removeItemAtPath:kActivityFile error:nil];
    
    NSMutableDictionary* history = [GRManifest history];
    for (NSString* key in [mfst allKeys]) {
        NSMutableDictionary* outInfo = [[mfst objectForKey:key] mutableCopy];
        [outInfo setObject:[NSNumber numberWithBool:NO] forKey:@"status"];
        [outInfo setObject:@"Gremlin server terminated prematurely" 
                    forKey:@"error"];
        [history setObject:outInfo forKey:key];
        [outInfo release];
    }
    [history writeToFile:kHistoryFile atomically:YES];

    [center_ postNotificationName:GRManifest_serverResetNotification];

    return [mfst allValues];
}

@end
