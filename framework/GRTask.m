#import "GRTask.h"

@implementation GRTask
@synthesize
    uuid,
    path,
    client,
    apiVersion,
    mediaKind,
    destination,
    metadata,
    error,
    status;

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
    [temp setObject:uuid forKey:@"uuid"];
    [temp setObject:path forKey:@"path"];
    
    if (client != nil) {
        [temp setObject:client forKey:@"client"];
        [temp setObject:[NSNumber numberWithInteger:apiVersion]
                 forKey:@"apiVersion"];
    }

    if (mediaKind != nil)
        [temp setObject:mediaKind forKey:@"mediaKind"];
    
    if (destination != nil)
        [temp setObject:destination forKey:@"destination"];

    if (metadata != nil)
        [temp setObject:metadata forKey:@"metadata"];
    if (error != nil)
        [temp setObject:error forKey:@"error"];
    if (status != nil)
        [temp setObject:status forKey:@"status"];

    return [[temp copy] autorelease];
}

+ (GRTask*)taskWithInfo:(NSDictionary*)info
{
    return [GRTask taskForUUID:[info objectForKey:@"uuid"] 
                          path:[info objectForKey:@"path"]
                        client:[info objectForKey:@"client"]
                    apiVersion:[[info objectForKey:@"apiVersion"] integerValue]
                     mediaKind:[info objectForKey:@"mediaKind"]
                   destination:[info objectForKey:@"destination"]
                      metadata:[info objectForKey:@"metadata"]
                         error:[info objectForKey:@"error"]
                        status:[info objectForKey:@"status"]];
}

+ (GRTask*)taskForUUID:(NSString*)uuid
                  path:(NSString*)path
                client:(NSString*)client
            apiVersion:(NSInteger)apiVersion
             mediaKind:(NSString*)mediaKind
           destination:(NSString*)destination
              metadata:(NSDictionary*)metadata
                 error:(NSString *)error
                status:(NSNumber *)status
{
    GRTask* task = [GRTask new];
    
    task.uuid = (uuid != nil) ? uuid : [GRTask getUUID];
    task.path = path;
    task.client = client;
    task.apiVersion = apiVersion;
    task.mediaKind = mediaKind;
    task.destination = destination;
    task.metadata = metadata;
    task.error = error;
    task.status = status;
    return [task autorelease];
}

- (void)dealloc
{
    self.uuid = nil;
    self.path = nil;
    self.client = nil;
    self.mediaKind = nil;
    self.destination = nil;
    self.metadata = nil;
    self.error = nil;
    self.status = nil;
    [super dealloc];
}
@end
