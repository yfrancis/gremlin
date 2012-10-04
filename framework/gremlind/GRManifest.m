/*
 * Created by Youssef Francis on October 1st, 2012.
 */

#import "GRManifest.h"

#define kManifestDir [NSHomeDirectory() stringByAppendingPathComponent: \
                        @"Library/Gremlin"]
#define kManifestFile [kManifestDir stringByAppendingPathComponent: \
                        @"manifest.plist"]

static NSMutableDictionary* manifest_ = nil;

@implementation GRManifest

+ (void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manifest_ = [NSMutableDictionary new];
        [[NSFileManager defaultManager] createDirectoryAtPath:kManifestDir
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    });
}

#pragma mark Persistence

+ (void)_synchronize
{
    [manifest_ writeToFile:kManifestFile
                atomically:YES];
}

+ (void)addTask:(GRTask*)task
{
    @synchronized(manifest_) {
        [manifest_ setObject:[task dictionaryRepresentation]
                      forKey:task.uuid];

        [self _synchronize];
    }
}

+ (void)removeTask:(GRTask*)task
{
    @synchronized(manifest_) {
        [manifest_ removeObjectForKey:task.uuid];

        [self _synchronize];
    }
}

#pragma mark Recovery

+ (NSArray*)recoveredTasks
{
    NSDictionary* mfst;
    mfst = [NSDictionary dictionaryWithContentsOfFile:kManifestFile];
    return [mfst allValues];
}

+ (void)clearManifest
{
    [[NSFileManager defaultManager] removeItemAtPath:kManifestFile
                                               error:nil];
}

@end
