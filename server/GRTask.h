/*
 * Created by Youssef Francis on September 25th, 2012.
 */

@interface GRTask : NSObject

@property (retain) NSString* path;
@property (retain) NSString* client;
@property (assign) NSInteger apiVersion;
@property (retain) NSString* destination;

- (NSDictionary*)dictionaryRepresentation;
+ (GRTask*)taskForPath:(NSString*)path
                client:(NSString*)client
            apiVersion:(NSInteger)apiVersion
           destination:(NSString*)destination;

@end
