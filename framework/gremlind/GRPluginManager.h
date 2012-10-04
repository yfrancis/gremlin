/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRTask.h"
#import "GRImporterProtocol.h"

@interface GRPluginManager : NSObject

+ (GRPluginManager*)sharedManager;
- (Class<GRImporter>)importerClassForTask:(GRTask*)task
                        requiredResources:(NSArray**)resources;

@end
