/*
 * Created by Youssef Francis on October 10th, 2012.
 */

#import "GRDestination.h"

#define kCFBundleNameKey (NSString*)kCFBundleNameKey

#define LSHandlerRankOwner(r) [r isEqualToString:@"Owner"]
#define LSHandlerRankAlternate(r) [r isEqualToString:@"Alternate"]
#define LSHandlerRankNone(r) [r isEqualToString:@"None"]

#define kGRRequiredResourcesKey @"GRRequiredResources"
#define kGRDestinationNameKey @"GRDestinationDisplayName"

@implementation GRDestination
@synthesize name, bundle, rank, resources;

+ (NSArray*)standardizedResourceArray:(NSArray*)ain
{
    NSMutableArray* tmp = [NSMutableArray array];
    
    NSString* lower = nil;
    for (NSString* resource in ain) {
        lower = [resource lowercaseString];
        if ([tmp containsObject:lower] == NO)
            [tmp addObject:lower];
    }
    
    [tmp sortUsingSelector:@selector(compare:)];
    
    return tmp;
}

+ (GRDestination*)destinationForBundle:(NSBundle*)bundle rank:(NSString*)rank
{
    GRDestination* d = [GRDestination new];
    
    d.bundle = bundle;
    d.rank = rank;
    
    d.name = [bundle objectForInfoDictionaryKey:kGRDestinationNameKey];
    
    NSArray* rsrc = [bundle objectForInfoDictionaryKey:kGRRequiredResourcesKey];
    d.resources = [self standardizedResourceArray:rsrc];
    
    return [d autorelease];
}

- (NSString*)description
{
    return [bundle objectForInfoDictionaryKey:kCFBundleNameKey];
}

- (NSComparisonResult)compare:(GRDestination*)other
{
    if ([rank isEqualToString:other.rank] ||
        ((rank == nil) && (other.rank == nil)))
        return NSOrderedSame;
    else if (LSHandlerRankOwner(rank) ||
             LSHandlerRankNone(other.rank))
        return NSOrderedAscending;
    else
        return NSOrderedDescending;
}

- (void)dealloc
{
    self.bundle = nil;
    self.rank = nil;
    self.resources = nil;
    [super dealloc];
}

@end

