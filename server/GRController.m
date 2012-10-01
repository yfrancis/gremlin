/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRController.h"
#import "GRPluginManager.h"
#import "GRTaskQueue.h"
#import "GRServer.h"

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
    [server run];

    NSLog(@"gremlind initializing");

    // start the runloop, the controller will keep this
    // runloop running until the number of active tasks
    // reaches zero, and 30s of inactivty elapse
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 30, 1)
            == kCFRunLoopRunHandledSource ||
            self.hasActiveTasks);

    NSLog(@"gremlind terminating");
}

- (void)_processImportCompletionForTask:(GRTask*)task
                                 status:(BOOL)status
                                  error:(NSError*)error
{
    [[GRServer sharedServer] signalImportCompleteForPath:task.path
                                                  client:task.client
                                              apiVersion:task.apiVersion
                                                  status:status
                                                   error:error];
}

- (void)importFile:(NSString*)path
            client:(NSString*)client
        apiVersion:(NSInteger)apiVersion
       destination:(NSString*)destination
{
    GRTask* task = [GRTask taskForPath:path
                                client:client
                            apiVersion:apiVersion
                           destination:destination];

    // figure out what importer class to use and which
    // resources it needs to acquire
    NSArray* rsrc = nil;
    Class<GRImporter> Importer;
    Importer = [[GRPluginManager sharedManager] importerClassForTask:task 
                                                   requiredResources:&rsrc];

    GRImportCompletionBlock complete;
    complete = ^(BOOL status, NSError* error) {
        [self _processImportCompletionForTask:task
                                       status:status
                                        error:error];
    };

    if (Importer == Nil) {
        complete(NO, nil);
        return;
    }

    [[GRTaskQueue sharedQueue] addTask:task 
                              importer:Importer
                             resources:rsrc
                       completionBlock:complete];
}

@end
