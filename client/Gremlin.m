/*
 * Created by Youssef Francis on September 25th, 2012.
 */

#import "Gremlin.h"
#import "GRClient.h"

#define kGremlinAPIVersion 2

static id<GremlinListener> listener_ = nil;

@interface Gremlin (Private)
+ (void)_handleGremlinServerDeath:(NSNotification*)notif;
+ (void)_handleImportFailureWithInfo:(NSDictionary*)info;
+ (void)_handleImportSuccessWithInfo:(NSDictionary*)info;
@end

@implementation Gremlin

+ (void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(_handleGremlinServerDeath:)
                   name:@"co.cocoanuts.gremlin.serverdied"
                 object:nil];
    });
}

+ (void)_handleGremlinServerDeath:(NSNotification*)notif
{
    if ([[notif name] isEqualToString:@"co.cocoanuts.gremlin.serverdied"]) {
        NSDictionary* info = [NSDictionary dictionaryWithObject:@"serverdied"
                                                         forKey:@"reason"];
        [self _handleImportFailureWithInfo:info];
    }
}

+ (void)_handleImportFailureWithInfo:(NSDictionary*)info
{
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

+ (void)_handleImportSuccessWithInfo:(NSDictionary*)info
{
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

+ (void)importFiles:(NSArray*)files 
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:files forKey:@"import"];
    [dict setObject:[NSNumber numberWithInt:kGremlinAPIVersion] 
             forKey:@"apiVersion"];

    BOOL haveListener = (listener_ != nil);
    [[GRClient sharedClient] sendServerMessage:dict
                                  haveListener:haveListener];
}

+ (void)importFileAtPath:(NSString*)path 
{
    if (path)
        [Gremlin importFiles:[NSArray arrayWithObject:path]];
}

+ (void)importFileWithInfo:(NSDictionary*)info 
{
    if (info)
        [Gremlin importFiles:[NSArray arrayWithObject:info]];
}

@end
