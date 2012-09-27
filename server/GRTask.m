#import "GRTask.h"

@implementation GRTask
@synthesize path, client, destination, successful;

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary* temp = [NSMutableDictionary dictionary];
    [temp setObject:path forKey:@"path"];
    if (destination)
        [temp setObject:destination forKey:@"destination"];
    return [[temp copy] autorelease];
}

- (id)initWithPath:(NSString*)aPath
            client:(NSString*)aClient
       destination:(NSString*)aDestination
{
    self = [super init];
    if (self != nil) {
        self.path = aPath;
        self.client = aClient;
        self.destination = aDestination;
    }
    return self;
}

+ (GRTask*)taskForPath:(NSString*)path
                client:(NSString*)client
           destination:(NSString*)destination
{
    return [[[GRTask alloc] initWithPath:path 
                                  client:client
                             destination:destination] autorelease];
}

- (void)dealloc
{
    self.path = nil;
    self.client = nil;
    self.destination = nil;
    [super dealloc];
}
@end
