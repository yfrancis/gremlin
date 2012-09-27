/*
 * Created by Youssef Francis on September 25th, 2012.
 */

#import "GRTask.h"
#import "GRImporterProtocol.h"

@interface GRTaskQueue : NSOperationQueue

@property (retain) NSMutableDictionary* resources;

+ (GRTaskQueue*)sharedQueue;
- (void)addTask:(GRTask*)task 
       importer:(Class<GRImporter>)Importer
      resources:(NSArray*)resources
   successBlock:(GRImportCompletionBlock)succ
   failureBlock:(GRImportCompletionBlock)fail;

@end
