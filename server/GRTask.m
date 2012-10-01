#import "GRTask.h"

@implementation GRTask
@synthesize 
    path = path_, 
    client = client_, 
    apiVersion = apiVersion_, 
    destination = destination_;

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary* temp = [NSMutableDictionary dictionary];
    [temp setObject:path_ forKey:@"path"];
    if (destination_ != nil)
        [temp setObject:destination_ forKey:@"destination"];
    return [[temp copy] autorelease];
}

- (id)_initWithPath:(NSString*)path
             client:(NSString*)client
         apiVersion:(NSInteger)apiVersion
        destination:(NSString*)destination
{
    self = [super init];
    if (self != nil) {
        self.path = path;
        self.client = client;
        self.apiVersion = apiVersion;
        self.destination = destination;
    }
    return self;
}

+ (GRTask*)taskForPath:(NSString*)path
                client:(NSString*)client
            apiVersion:(NSInteger)apiVersion
           destination:(NSString*)destination
{
    return [[[GRTask alloc] _initWithPath:path 
                                   client:client
                               apiVersion:apiVersion
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
