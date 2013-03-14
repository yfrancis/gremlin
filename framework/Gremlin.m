/*
 * Created by Youssef Francis on September 25th, 2012.
 */

#import "Gremlin.h"
#import "GRClient.h"
#import "GRPluginScanner.h"
#import "GRTask.h"

#define kGremlinAPIVersion 2

#define kManifestDir [NSHomeDirectory() stringByAppendingPathComponent: \
                        @"Library/Gremlin"]
#define kHistoryFile [kManifestDir stringByAppendingPathComponent: \
                        @"history.plist"]

static id<GremlinListener> listener_ = nil;

@interface Gremlin (Private)
+ (void)handleGremlinServerDeath:(NSNotification*)notif;
+ (void)handleImportFailureWithInfo:(NSDictionary*)info;
+ (void)handleImportSuccessWithInfo:(NSDictionary*)info;
+ (void)updateTaskInfoForImports:(NSArray*)imports;
@end

static NSMutableDictionary* localImports_ = nil;

@implementation Gremlin

+ (void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        localImports_ = [NSMutableDictionary new];

        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(_handleGremlinServerDeath:)
                   name:@"co.cocoanuts.gremlin.server.crash"
                 object:nil];
    });
}

+ (void)handleGremlinServerDeath:(NSNotification*)notif
{
    if ([[notif name] isEqualToString:@"co.cocoanuts.gremlin.server.crash"]) {
        NSDictionary* info = [NSDictionary dictionaryWithObject:@"server.crash"
                                                         forKey:@"reason"];
        [self handleImportFailureWithInfo:info];
    }
}

+ (BOOL)isValidTask:(NSDictionary*)info
{
    NSString* uuid = [info objectForKey:@"uuid"];
    NSDictionary* localVersion = [localImports_ objectForKey:uuid];

    NSString* localPath = [localVersion objectForKey:@"path"];
    NSString* path = [info objectForKey:@"path"];

    if ([path isEqualToString:localPath]) {
        // remove from local imports
        [localImports_ removeObjectForKey:uuid];
        return YES;
    }

    return NO;
}

+ (void)handleImportFailureWithInfo:(NSDictionary*)info
{
    if (![self isValidTask:info])
        return;

    SEL selector = @selector(gremlinImport:didFailWithError:);
    
    NSDictionary* errorInfo = [info objectForKey:@"error_info"];
    NSError* error = [NSError errorWithDomain:@"gremlin"
                                         code:0
                                     userInfo:errorInfo];

    if ([listener_ respondsToSelector:selector])
        [listener_ performSelector:selector
                        withObject:info
                        withObject:error];
}

+ (void)handleImportSuccessWithInfo:(NSDictionary*)info
{
    if (![self isValidTask:info])
        return;

    SEL selector = @selector(gremlinImportWasSuccessful:); 
        
    if ([listener_ respondsToSelector:selector])
        [listener_ performSelector:selector
                        withObject:info];
}

+ (BOOL)haveGremlin 
{
    return [[GRClient sharedClient] haveGremlin];
}

+ (BOOL)registerNotifications:(id<GremlinListener>)listener 
{
    BOOL success = NO;
    if ([listener conformsToProtocol:@protocol(GremlinListener)]) {
        success = [[GRClient sharedClient] registerForNotifications:self];
        if (success == YES)
            listener_ = listener;
    }
    return success;
}

+ (void)unregisterNotifications
{
    listener_ = nil;
    [[GRClient sharedClient] unregisterForNotifications];
}

+ (void)updateTaskInfoForImports:(NSArray*)imports
{
    for (NSMutableDictionary* task in imports) {
        // generate uuid for task
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        NSString* uuidstr = (NSString*)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);

        // add uuid to task info dict
        [task setObject:uuidstr forKey:@"uuid"];

        // add task to local imports dict
        [localImports_ setObject:task forKey:uuidstr];
        [uuidstr release];
    }
}

+ (BOOL)importFiles:(NSArray*)files 
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    NSMutableArray* importArray = [NSMutableArray array];

    for (NSDictionary* info  in files) {
        if (![info isKindOfClass:[NSDictionary class]])
            return NO;
        [importArray addObject:[[info mutableCopy] autorelease]];
    }

    // give each individual task a uuid
    [self updateTaskInfoForImports:importArray];

    [dict setObject:importArray forKey:@"import"];
    [dict setObject:[NSNumber numberWithInt:kGremlinAPIVersion] 
             forKey:@"apiVersion"];

    BOOL haveListener = (listener_ != nil);
    return [[GRClient sharedClient] sendServerMessage:dict
                                         haveListener:haveListener];
}

+ (BOOL)importFileWithInfo:(NSDictionary*)info 
{
    if (info != nil) {
        NSMutableDictionary* mut = [[info mutableCopy] autorelease];
        return [Gremlin importFiles:[NSArray arrayWithObject:mut]];
    }
    return NO;
}

+ (BOOL)importFileAtPath:(NSString*)path 
{
    if (path != nil) {
        NSDictionary* info = [NSDictionary dictionaryWithObject:path
                                                         forKey:@"path"];
        return [Gremlin importFileWithInfo:info];
    }
    return NO;
}

#pragma mark Destinations

+ (NSArray*)allAvailableDestinations
{
    return [GRPluginScanner allAvailableDestinations];
}

+ (NSArray*)availableDestinationsForFile:(NSString*)path
{
    return [GRPluginScanner availableDestinationsForFile:path];
}

+ (GRDestination*)defaultDestinationForFile:(NSString*)path
{
    return [GRPluginScanner defaultDestinationForFile:path];
}

#pragma mark Manifest

+ (NSArray*)getHistory
{
    NSDictionary* history;
	history = [NSDictionary dictionaryWithContentsOfFile:kHistoryFile];

	NSMutableArray* tasks = [NSMutableArray array];
	for (NSDictionary* taskInfo in [history allValues]) {
		[tasks addObject:[GRTask taskWithInfo:taskInfo]];
	}
	return tasks;
}

@end
