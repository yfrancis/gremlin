#import "GRTask.h"

@implementation GRTask
@synthesize
    uuid = uuid_,
    path = path_, 
    client = client_, 
    apiVersion = apiVersion_,
    mediaKind = mediaKind_,
    destination = destination_,
    metadata = metadata_;

+ (NSString*)getUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString*)string autorelease];
}

- (NSDictionary*)info
{
    NSMutableDictionary* temp = [NSMutableDictionary dictionary];
    [temp setObject:uuid_ forKey:@"uuid"];
    [temp setObject:path_ forKey:@"path"];
    
    if (client_ != nil) {
        [temp setObject:client_ forKey:@"client"];
        [temp setObject:[NSNumber numberWithInteger:apiVersion_]
                 forKey:@"apiVersion"];
    }

    if (mediaKind_ != nil)
        [temp setObject:mediaKind_ forKey:@"mediaKind"];
    
    if (destination_ != nil)
        [temp setObject:destination_ forKey:@"destination"];

    if (metadata_ != nil)
        [temp setObject:metadata_ forKey:@"metadata"];
   
    return [[temp copy] autorelease];
}

- (id)_initWithUUID:(NSString*)uuid
               path:(NSString*)path
             client:(NSString*)client
         apiVersion:(NSInteger)apiVersion
          mediaKind:(NSString*)mediaKind
        destination:(NSString*)destination
           metadata:(NSDictionary*)metadata
{
    self = [super init];
    if (self != nil) {
        self.uuid = (uuid != nil) ? uuid : [GRTask getUUID];
        self.path = path;
        self.client = client;
        self.apiVersion = apiVersion;
        self.mediaKind = mediaKind;
        self.destination = destination;
        self.metadata = metadata;
    }
    return self;
}

+ (GRTask*)taskWithInfo:(NSDictionary*)info
{
    return [GRTask taskForUUID:[info objectForKey:@"uuid"] 
                          path:[info objectForKey:@"path"]
                        client:[info objectForKey:@"client"]
                    apiVersion:[[info objectForKey:@"apiVersion"] integerValue]
                     mediaKind:[info objectForKey:@"mediaKind"]
                   destination:[info objectForKey:@"destination"]
                      metadata:[info objectForKey:@"metadata"]];
}

+ (GRTask*)taskForUUID:(NSString*)uuid
                  path:(NSString*)path
                client:(NSString*)client
            apiVersion:(NSInteger)apiVersion
             mediaKind:(NSString*)mediaKind
           destination:(NSString*)destination
              metadata:(NSDictionary*)metadata
{
    return [[[GRTask alloc] _initWithUUID:uuid
                                     path:path 
                                   client:client
                               apiVersion:apiVersion
                                mediaKind:mediaKind
                              destination:destination
                                 metadata:metadata] autorelease];
}

- (void)dealloc
{
    self.uuid = nil;
    self.path = nil;
    self.client = nil;
    self.mediaKind = nil;
    self.destination = nil;
    self.metadata = nil;
    [super dealloc];
}
@end
