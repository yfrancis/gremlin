/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRController.h"
#import "GRPluginManager.h"
#import "GRTaskQueue.h"
#import "GRServer.h"

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
        
        // initialize the IPC server singleton and assign
        // ourselves as the server's import delegate
        GRServer* server = [GRServer sharedServer];
        server.importDelegate = self;

        // start the server to listen for import requests.
        // the server will run inside its own thread with
        // its own runloop
        NSThread* serverThread;
        serverThread = [[NSThread alloc] initWithTarget:server
                                               selector:@selector(run)
                                                 object:nil];
        [serverThread start];
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

- (void)importFile:(NSString*)path
            client:(NSString*)client
       destination:(NSString*)destination
{
    GRTask* task = [GRTask taskForPath:path
                                client:client
                           destination:destination];

    // figure out what importer class to use and
    // which resources it needs to acquire
    NSArray* resources = nil;
    Class<GRImporter> Importer;
    GRPluginManager* pm = [GRPluginManager sharedManager];
    Importer = [pm importerClassForTask:task requiredResources:&resources];

    if (Importer == Nil) {
        task.successful = NO;
        [[GRServer sharedServer] informClientImportCompleteForTask:task];
        return;
    }

    // generate success and failure blocks
    GRImportCompletionBlock succ = Block_copy(^(NSDictionary* info) {
        task.successful = YES;
        [[GRServer sharedServer] informClientImportCompleteForTask:task];
    });

    GRImportCompletionBlock fail = Block_copy(^(NSDictionary* info) {
        task.successful = NO;
        [[GRServer sharedServer] informClientImportCompleteForTask:task];
    });

    [[GRTaskQueue sharedQueue] addTask:task 
                              importer:Importer
                             resources:resources
                          successBlock:succ
                          failureBlock:fail];
}

@end
