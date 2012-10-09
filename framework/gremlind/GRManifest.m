/*
 * Created by Youssef Francis on October 1st, 2012.
 */

#import "GRManifest.h"
#import "GRIPCProtocol.h"
#import <AppSupport/CPDistributedMessagingCenter.h>

#define kManifestDir [NSHomeDirectory() stringByAppendingPathComponent: \
                        @"Library/Gremlin"]
#define kActivityFile [kManifestDir stringByAppendingPathComponent: \
                        @"activity.plist"]
#define kHistoryFile [kManifestDir stringByAppendingPathComponent: \
						@"history.plist"]

static NSMutableDictionary* activity_ = nil;

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

		CPDistributedMessagingCenter* center;
		NSString* centerName = @GRManifest_MessagePortName;
		center = [CPDistributedMessagingCenter centerNamed:centerName];
		[center runServerOnCurrentThread];

		[center registerForMessageName:@"getManifest"
								target:self
							  selector:@selector(_getManifest:userInfo:)];
		[center retain];
    });
}

#pragma mark IPC

- (NSDictionary*)_getManifest:(NSString*)msg userInfo:(NSDictionary*)info
{
	NSString* type = [info objectForKey:@"type"];
	if ([type isEqualToString:@"active"])
		return activity_;
	return nil;
}

#pragma mark Persistence

+ (void)_synchronize
{
    [activity_ writeToFile:kActivityFile atomically:YES];
}

+ (void)addTask:(GRTask*)task
{
    @synchronized(activity_) {
        [activity_ setObject:[task info] forKey:task.uuid];
        [self _synchronize];
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
	
		NSMutableArray* history;
		history = [NSMutableArray arrayWithContentsOfFile:kHistoryFile];
		[history addObject:info];
		[history writeToFile:kHistoryFile atomically:YES];
        
		[self _synchronize];
    }
}

#pragma mark Recovery

+ (NSArray*)recoveredTasks
{
    NSDictionary* mfst;
    mfst = [NSDictionary dictionaryWithContentsOfFile:kActivityFile];
	[[NSFileManager defaultManager] removeItemAtPath:kActivityFile error:nil];
	
	NSMutableArray* history;
	history = [NSMutableArray arrayWithContentsOfFile:kHistoryFile];
	for (NSDictionary* info in [mfst allValues]) {
		NSMutableDictionary* outInfo;
		outInfo = [NSMutableDictionary dictionaryWithDictionary:info];
		[outInfo setObject:[NSNumber numberWithBool:NO] forKey:@"status"];
		[outInfo setObject:@"Gremlin server crashed" forKey:@"error"];
		[history addObject:outInfo];
	}
	[history writeToFile:kHistoryFile atomically:YES];

	return [mfst allValues];
}

@end
