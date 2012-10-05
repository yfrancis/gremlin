/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRController.h"
#import "GRPluginManager.h"
#import "GRTaskQueue.h"
#import "GRManifest.h"

@interface GRController (Private)
- (void)_processImportCompletionForTask:(GRTask*)task
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
            [self _processImportCompletionForTask:task
                                           status:NO
                                            error:error];
        }

        [GRManifest clearManifest];
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

- (void)_processImportCompletionForTask:(GRTask*)task
                                 status:(BOOL)status
                                  error:(NSError*)error
{
    [[GRServer sharedServer] signalImportCompleteForTask:task
                                                  status:status
                                                   error:error];
}

- (void)importTask:(GRTask*)task 
{
    // figure out what importer class to use and which
    // resources it needs to acquire
    NSArray* rsrc = nil;
    Class<GRImporter> Importer;
    Importer = [[GRPluginManager sharedManager] importerClassForTask:task 
                                                   requiredResources:&rsrc];

    GRImportCompletionBlock complete;
    complete = ^(BOOL status, NSError* error) {
        [GRManifest removeTask:task];

        [self _processImportCompletionForTask:task
                                       status:status
                                        error:error];
    };

    if (Importer == Nil) {
        complete(NO, nil);
        return;
    }

    // add task to persistent manifest
    [GRManifest addTask:task];

    // queue the import task
    [[GRTaskQueue sharedQueue] addTask:task 
                              importer:Importer
                             resources:rsrc
                       completionBlock:complete];
}

@end
