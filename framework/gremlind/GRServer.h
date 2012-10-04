/*
 * Created by Youssef Francis on September 25th,  2012.
 */

@protocol GRServerImportDelegate <NSObject>
- (void)importTask:(NSString*)uuid
              path:(NSString*)path
            client:(NSString*)client
        apiVersion:(NSInteger)apiVersion
       destination:(NSString*)destination;
@end

@interface GRServer : NSObject

@property (assign) id<GRServerImportDelegate> importDelegate;

+ (GRServer*)sharedServer;
- (void)signalImportCompleteForTask:(NSString*)uuid
                               path:(NSString*)path
                             client:(NSString*)client
                         apiVersion:(NSInteger)apiVersion
                             status:(BOOL)status
                              error:(NSError*)error;
- (void)run;

@end
