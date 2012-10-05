/*
 * Created by Youssef Francis on September 25th, 2012.
 */

@interface GRTask : NSObject

@property (retain) NSString* uuid;
@property (retain) NSString* path;
@property (retain) NSString* client;
@property (assign) NSInteger apiVersion;
@property (retain) NSString* mediaKind;
@property (retain) NSString* destination;

- (NSDictionary*)info;
+ (GRTask*)taskWithInfo:(NSDictionary*)info;
+ (GRTask*)taskForUUID:(NSString*)uuid
                  path:(NSString*)path
                client:(NSString*)client
            apiVersion:(NSInteger)apiVersion
             mediaKind:(NSString*)mediaKind
           destination:(NSString*)destination;

@end
