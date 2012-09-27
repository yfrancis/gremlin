/*
 * Created by Youssef Francis on September 25th, 2012.
 */

@interface GRTask : NSObject

@property (retain) NSString* path;
@property (retain) NSString* client;
@property (retain) NSString* destination;
@property (assign) BOOL successful;

- (NSDictionary*)dictionaryRepresentation;
+ (GRTask*)taskForPath:(NSString*)path
                client:(NSString*)client
           destination:(NSString*)destination;

@end
