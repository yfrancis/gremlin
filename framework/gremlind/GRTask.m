#import "GRTask.h"

@implementation GRTask
@synthesize
    uuid = uuid_,
    path = path_, 
    client = client_, 
    apiVersion = apiVersion_, 
    destination = destination_;

+ (NSString*)getUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString*)string autorelease];
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary* temp = [NSMutableDictionary dictionary];
    [temp setObject:uuid_ forKey:@"uuid"];
    [temp setObject:path_ forKey:@"path"];
    
    if (client_ != nil) {
        [temp setObject:client_ forKey:@"client"];
        [temp setObject:[NSNumber numberWithInteger:apiVersion_]
                 forKey:@"apiVersion"];
    }
    
    if (destination_ != nil)
        [temp setObject:destination_ forKey:@"destination"];
   
    return [[temp copy] autorelease];
}

- (id)_initWithUUID:(NSString*)uuid
               path:(NSString*)path
             client:(NSString*)client
         apiVersion:(NSInteger)apiVersion
        destination:(NSString*)destination
{
    self = [super init];
    if (self != nil) {
        self.uuid = (uuid != nil) ? uuid : [GRTask getUUID];
        self.path = path;
        self.client = client;
        self.apiVersion = apiVersion;
        self.destination = destination;
    }
    return self;
}

+ (GRTask*)taskWithInfo:(NSDictionary*)info
{
    return [GRTask taskForUUID:[info objectForKey:@"uuid"] 
                          path:[info objectForKey:@"path"]
                        client:[info objectForKey:@"client"]
                    apiVersion:[[info objectForKey:@"apiVersion"] integerValue]
                   destination:[info objectForKey:@"destination"]];
}

+ (GRTask*)taskForUUID:(NSString*)uuid
                  path:(NSString*)path
                client:(NSString*)client
            apiVersion:(NSInteger)apiVersion
           destination:(NSString*)destination
{
    return [[[GRTask alloc] _initWithUUID:uuid
                                     path:path 
                                   client:client
                               apiVersion:apiVersion
                              destination:destination] autorelease];
}

- (void)dealloc
{
    self.uuid = nil;
    self.path = nil;
    self.client = nil;
    self.destination = nil;
    [super dealloc];
}
@end
