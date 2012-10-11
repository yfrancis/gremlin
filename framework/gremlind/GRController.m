/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRController.h"
#import "GRTaskQueue.h"
#import "GRManifest.h"

#import "GRDestination+Import.h"

#import <Gremlin/GRPluginScanner.h>

@interface GRController (Private)
- (void)processImportCompletionForTask:(GRTask*)task
                                status:(BOOL)status
                                 error:(NSError*)error;
@end

@implementation GRController
@synthesize hasActiveTasks;

+ (GRController*)sharedController
{
    static dispatch_once_t once;
    static GRController* sharedController;
    dispatch_once(&once, ^{
        sharedController = [[self alloc] init];
    });
    return sharedController;
}

- (oneway void)release {}
- (NSUInteger)retainCount { return NSUIntegerMax; }
- (id)retain { return self; }
- (id)autorelease { return self; }

- (id)init
{
    self = [super init];
    if (self != nil) {
        // set up the import task queue and register for
        // KVO updates for the "taskCount"
        GRTaskQueue* taskQueue = [GRTaskQueue sharedQueue];
        [taskQueue addObserver:self
                    forKeyPath:@"operationCount"
                       options:NSKeyValueObservingOptionNew
                       context:NULL];

        // check if we previously crashed and inform clients
        NSArray* recovered = [GRManifest recoveredTasks];
        
        NSDictionary* error_info;
        error_info = [NSDictionary dictionaryWithObject:@"crashed"
                                                 forKey:@"reason"];

        NSError* error = [NSError errorWithDomain:@"gremlin"
                                             code:500
                                         userInfo:error_info];

        for (NSDictionary* info in recovered) {
            GRTask* task = [GRTask taskWithInfo:info];
            [self processImportCompletionForTask:task
                                          status:NO
                                           error:error];
        }
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    if ([keyPath isEqualToString:@"operationCount"]) {
        NSUInteger newCount = [[change objectForKey:NSKeyValueChangeNewKey]
                                unsignedIntegerValue];
        self.hasActiveTasks = (newCount > 0);
    }
}

- (void)processImportRequests
{
    // initialize the IPC server singleton and assign
    // ourselves as the server's import delegate
    GRServer* server = [GRServer sharedServer];
    server.importDelegate = self;

    // start the server to listen for import requests
    // if the server is unable to initialize, we should
    // just terminate right here
    if ([server run] == NO) {
        NSLog(@"server init failed, terminating");
        return;
    }

    // start the runloop, the controller will keep this
    // runloop running until the number of active tasks
    // reaches zero, and 30s of inactivty elapse
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 30, 1)
            == kCFRunLoopRunHandledSource ||
            self.hasActiveTasks);

    NSLog(@"server went idle, terminating");
}

- (void)processImportCompletionForTask:(GRTask*)task
                                 status:(BOOL)status
                                  error:(NSError*)error
{
    [[GRServer sharedServer] signalImportCompleteForTask:task
                                                  status:status
                                                   error:error];
}

- (void)importTask:(GRTask*)task 
{
    // this is the completion block called in case
    // of import success or failure, we may call
    // this block ourselves here in some cases
    GRImportCompletionBlock complete;
    complete = ^(BOOL status, NSError* error) {
        [GRManifest removeTask:task 
                        status:status
                         error:error];

        [self processImportCompletionForTask:task
                                      status:status
                                       error:error];
    };

    // figure out what importer class to use and which
    // resources it needs to acquire
    NSString* path = task.path;
    NSArray* plugins = [GRPluginScanner availableDestinationsForFile:path];

    if (plugins.count == 0) {
        complete(NO, nil);
        return;
    }

    NSString* taskDestination = task.destination;
    GRDestination* chosenDestination = nil;
    if (taskDestination != nil) {
        // client has specified a destination here, we must honor it
        for (GRDestination* dest in plugins) {
            if ([dest.name isEqualToString:taskDestination]) {
                chosenDestination = dest;
                break;
            }
        }
    }
    else {
        chosenDestination = [plugins objectAtIndex:0];
    }

    if (chosenDestination == nil) {
        // chosen destination is not available, error
        complete(NO, nil);
        return;
    }

    NSArray* requiredResources = [chosenDestination resources];
    Class<GRImporter> Importer = [chosenDestination importerClass];

    if (Importer == Nil) {
        complete(NO, nil);
        return;
    }

    // add task to persistent manifest
    [GRManifest addTask:task];

    // queue the import task
    [[GRTaskQueue sharedQueue] addTask:task 
                              importer:Importer
                             resources:requiredResources
                       completionBlock:complete];
}

@end
