/*
 * Created by Youssef Francis on September 25th,  2012.
 */

#import "GRTask.h"
#import "GRServerDelegateProtocol.h"

@interface GRServer : NSObject

@property (assign) id<GRServerImportDelegate> importDelegate;

+ (GRServer*)sharedServer;
- (void)signalImportCompleteForPath:(NSString*)path
                             client:(NSString*)client
                         apiVersion:(NSInteger)apiVersion
                             status:(BOOL)status
                              error:(NSError*)error;
- (void)run;

@end
