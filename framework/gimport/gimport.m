#import <Gremlin/Gremlin.h>

@interface Listener : NSObject <GremlinListener>
@end

@implementation Listener

- (void)gremlinImportWasSuccessful:(NSDictionary*)info
{
    NSLog(@"gimport: gremlinImportWasSuccessful: %@", info);
    exit(0);
}

- (void)gremlinImport:(NSDictionary*)info didFailWithError:(NSError*)error
{
    NSLog(@"gimport: gremlinImport:didFailWithError: %@, %@]", info, error);
    exit(-1);
}

@end

int main(int argc, const char **argv, char **envp) 
{
    NSAutoreleasePool* pool = [NSAutoreleasePool new];
	
    if (argc > 1) {
        [Gremlin haveGremlin];	
        [Gremlin registerNotifications:[Listener new]];
        
        NSString* path = [NSString stringWithUTF8String:argv[1]];
        NSString* destination, * mediaKind = nil;
        if (argc >= 3) {
            destination = [NSString stringWithUTF8String:argv[2]];
            if (argc == 4)
                mediaKind = [NSString stringWithUTF8String:argv[3]];
        }

        NSMutableDictionary* info = [NSMutableDictionary dictionary];
        [info setObject:path forKey:@"path"];
        if (destination != nil)
            [info setObject:destination forKey:@"destination"];
        if (mediaKind != nil)
            [info setObject:mediaKind forKey:@"mediaKind"];

        NSLog(@"gimport: importing %@", info);

        if ([Gremlin importFileWithInfo:info])
            CFRunLoopRun();
        else
            NSLog(@"gimport: import request failed");
    }
	
    [pool drain];
    return 0;
}

// vim:ft=objc
