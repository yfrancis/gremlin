#include <CoreFoundation/CoreFoundation.h>
#include <Gremlin/Gremlin.h>

@interface Listener : NSObject <GremlinListener>
@end

@implementation Listener

- (void)gremlinImportDidComplete:(NSString*)file 
{
    NSLog(@"[%@ gremlinImportDidComplete:%@]", self, file);
    exit(0);
}

- (void)gremlinImportDidFail:(NSString*)file 
{
    NSLog(@"[%@ gremlinImportDidFail:%@]", self, file);
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
        NSString* destination = nil;
        if (argc == 3)
            destination = [NSString stringWithUTF8String:argv[2]];

        NSMutableDictionary* info = [NSMutableDictionary dictionary];
        [info setObject:path forKey:@"path"];
        if (destination != nil)
            [info setObject:destination forKey:@"destination"];

        NSLog(@"gremlin: importing %@", info);

        [Gremlin importFileWithInfo:info];
        
        CFRunLoopRun();
    }
	
    [pool drain];
    return 0;
}

// vim:ft=objc
