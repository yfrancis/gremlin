#import "GRTaskQueue.h"

@implementation GRTaskQueue
@synthesize resources;

+ (GRTaskQueue*)sharedQueue
{
    static dispatch_once_t once;
    static GRTaskQueue* sharedQueue;
    dispatch_once(&once, ^{ 
            sharedQueue = [[self alloc] init]; 
    });
    return sharedQueue;
}

- (oneway void)release {}
- (NSUInteger)retainCount { return NSUIntegerMax; }
- (id)retain { return self; }
- (id)autorelease { return self; }

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.maxConcurrentOperationCount = 5;
        self.resources = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addTask:(GRTask*)task 
       importer:(Class<GRImporter>)Importer
      resources:(NSArray*)requiredResources
   successBlock:(GRImportCompletionBlock)succ
   failureBlock:(GRImportCompletionBlock)fail
{
    // get execution block for the import task
    NSDictionary* taskInfo = [[task dictionaryRepresentation] copy];
    GRImportOperationBlock block;
    block = [Importer newImportBlockWithInfo:taskInfo
                                successBlock:succ
                                failureBlock:fail];

    // create NSBlockOperation wrapper
    NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:block];

    // set up dependencies
    // check task resource requirements
    NSMutableArray* savedDepArrays = [NSMutableArray array];
    for (NSString* resource in requiredResources) {
        NSMutableArray* depends = [resources objectForKey:resource];

        if (depends == nil) {
            depends = [NSMutableArray array];
            [resources setObject:depends forKey:resource];
        }
        else {
            for (NSBlockOperation* dep in depends)
                [op addDependency:dep];
        }

        [depends addObject:op];
        [savedDepArrays addObject:depends];
    }

    [op setCompletionBlock:^{
        Block_release(succ);
        Block_release(fail);
        Block_release(block);

        [taskInfo release];

        // remove operation from dependency arrays
        [savedDepArrays makeObjectsPerformSelector:@selector(removeObject:)
                                        withObject:op];
    }];

    [self addOperation:op];
}

@end
