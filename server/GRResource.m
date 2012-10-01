/*
 * Created by Youssef Francis on September 28th, 2012.
 */

#import "GRResource.h"

static NSMutableDictionary* resources_ = nil;

@interface GRResource (Private)
- (id)_initWithName:(NSString*)name;
@end

@implementation GRResource

+ (void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        resources_ = [NSMutableDictionary new];
    });
}

+ (GRResource*)_resourceWithName:(NSString*)name
{
    @synchronized(resources_) {
        GRResource* r = [resources_ objectForKey:name];
        if (r == nil) {
            r = [[[GRResource alloc] _initWithName:name] autorelease];
            [resources_ setObject:r forKey:name];
        }
        return r;
    }
}

- (id)_initWithName:(NSString*)name
{
    self = [super init];
    if (self != nil)
        self.name = name;
    return self;
}

+ (void)acquireResources:(NSArray*)resources
{
    for (NSString* resourceName in resources)
        [[GRResource _resourceWithName:resourceName] lock];
}

+ (void)relinquishResources:(NSArray*)resources
{
    for (NSString* resourceName in resources)
        [[GRResource _resourceWithName:resourceName] unlock];
}

@end
