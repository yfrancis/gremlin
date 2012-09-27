/*
 * Created by Youssef Francis on September 25th, 2012.
 */

#import "Gremlin.h"
#import "GRClient.h"

static id<GremlinListener> listener_ = nil;
@implementation Gremlin

+ (void)_handleImportFailureForPath:(NSString*)path
{
    SEL selector = @selector(gremlinImportDidFail:);
    if ([listener_ respondsToSelector:selector])
        [(id)listener_ performSelectorOnMainThread:selector
                                        withObject:path
                                    waitUntilDone:NO];
}

+ (void)_handleImportSuccessForPath:(NSString*)path
{
    SEL selector = @selector(gremlinImportDidComplete:);
    if ([listener_ respondsToSelector:selector])
        [(id)listener_ performSelectorOnMainThread:selector
                                        withObject:path
                                    waitUntilDone:NO];
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
