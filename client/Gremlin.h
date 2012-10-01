/*
 * Created by Youssef Francis on September 25th, 2012.
 */

@protocol GremlinListener <NSObject>
- (void)gremlinImportWasSuccessful:(NSDictionary*)info;
- (void)gremlinImport:(NSDictionary*)info didFailWithError:(NSError*)error;
@end

@interface Gremlin : NSObject
+ (BOOL)haveGremlin;
+ (void)importFiles:(NSArray*)files;
+ (void)importFileAtPath:(NSString*)path;
+ (void)importFileWithInfo:(NSDictionary*)info;
+ (BOOL)registerNotifications:(id<GremlinListener>)listener;
@end
