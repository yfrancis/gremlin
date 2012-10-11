/*
 * Created by Youssef Francis on September 28th, 2012.
 */

#import "GRResource.h"

static NSMutableDictionary* resources_ = nil;

@interface GRResource (Private)
- (id)initWithName:(NSString*)name;
@end

@implementation GRResource

+ (void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        resources_ = [NSMutableDictionary new];
    });
}

+ (GRResource*)resourceWithName:(NSString*)name
{
    @synchronized(resources_) {
        GRResource* r = [resources_ objectForKey:name];
        if (r == nil) {
            r = [[[GRResource alloc] initWithName:name] autorelease];
            [resources_ setObject:r forKey:name];
        }
        return r;
    }
}

- (id)initWithName:(NSString*)name
{
    self = [super init];
    if (self != nil)
        self.name = name;
    return self;
}

+ (void)acquireResources:(NSArray*)resources
{
    for (NSString* resourceName in resources)
        [[GRResource resourceWithName:resourceName] lock];
}

+ (void)relinquishResources:(NSArray*)resources
{
    for (NSString* resourceName in resources)
        [[GRResource resourceWithName:resourceName] unlock];
}

@end
