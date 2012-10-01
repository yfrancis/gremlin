/*
 * Created by Youssef Francis on September 26th, 2012.
 */

@protocol GRServerImportDelegate <NSObject>
- (void)importTask:(NSString*)uuid
              path:(NSString*)path
            client:(NSString*)client
        apiVersion:(NSInteger)apiVersion
       destination:(NSString*)destination;
@end
