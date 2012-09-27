/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRPluginManager.h"
#import <MobileCoreServices/UTType.h>

#define kPluginDirectory @"/Library/Gremlin/Plugins"

@implementation GRPluginManager

+ (GRPluginManager*)sharedManager
{
    static dispatch_once_t once;
    static GRPluginManager* sharedManager;
    dispatch_once(&once, ^{
            sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (oneway void)release {}
- (NSUInteger)retainCount { return NSUIntegerMax; }
- (id)retain { return self; }
- (id)autorelease {return self; }

- (Class<GRImporter>)_defaultImporterClassForType:(const CFStringRef)type
                                      destination:(NSString*)destination
                                requiredResources:(NSArray**)resources
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSError* err = nil;
    NSArray* plugins = [fm contentsOfDirectoryAtPath:kPluginDirectory
                                               error:&err];
    
    if (plugins == nil || err != nil)
        return Nil;

    Class<GRImporter> SelectedPluginClass = Nil;
    NSUInteger selectedPluginPriority = 0;
    NSArray* requiredResources = nil;
    
    for (NSString* plugin in plugins) {
        NSLog(@"found plugin: %@", plugin);

        NSString* fullPath;
        fullPath = [kPluginDirectory stringByAppendingPathComponent:plugin];

        NSLog(@"fullPath: %@", fullPath);
        
        NSBundle* bundle = [NSBundle bundleWithPath:fullPath];
        
        NSLog(@"version check");
        // check if this plugin is supported on this system version
        // first check if plugin has strict version requirements
        NSArray* strict = [bundle objectForInfoDictionaryKey:
                            @"RequiredCFVersionNumbers"];
        if (strict != nil) {
            NSNumber* currentVersion;
            currentVersion = [NSNumber numberWithFloat:
                                kCFCoreFoundationVersionNumber];
            if ([strict containsObject:currentVersion] == NO)
                continue;
        }

        NSLog(@"passed strict version check");

        // otherwise look for range of supported versions
        float minVersion, maxVersion;
        minVersion = [[bundle objectForInfoDictionaryKey:
                        @"MinimumCFVersionNumber"] floatValue];
        maxVersion = [[bundle objectForInfoDictionaryKey:
                        @"MaximumCFVersionNumber"] floatValue];

        if (kCFCoreFoundationVersionNumber < minVersion || 
            (maxVersion > 0.0f && kCFCoreFoundationVersionNumber > maxVersion))
            continue;

        NSLog(@"passed range version check");

        NSString* query = nil;
        NSDictionary* support = nil;

        if (destination != nil) {
            query = @"GRDestinationPriority";
            // if a destination is provided, we want to select
            // a plugin that will import to that destination
            if ([[bundle objectForInfoDictionaryKey:@"GRDestination"]
                    isEqualToString:destination])
                support = [bundle infoDictionary];
        }
        else {
            // otherwise just look for a plugin that supports
            // the type of file being imported
            support = [bundle objectForInfoDictionaryKey:
                        @"GRSupportedTypes"];
            query = (NSString*)type;
        }

        NSNumber* priority = [support objectForKey:query];
        if (priority == nil) {
            // maybe this plugin supports all generic file types
            // and/or destinations?
            priority = [support objectForKey:@"GRSupportsAll"];
            
            if (priority == nil) {
                NSLog(@"plugin does not provide what we need!");
                continue;
            }
        }

        // check plugin priority
        NSUInteger priorityValue = [priority unsignedIntegerValue];
        if (priorityValue > selectedPluginPriority) {
            // check if the bundle principal class conforms to GRImporter
            Class PrincipalClass = [bundle principalClass];
            NSLog(@"got principalclass: %@", PrincipalClass);
            if ([PrincipalClass conformsToProtocol:@protocol(GRImporter)] == NO)
                continue;
            NSLog(@"class conforms!");
            SelectedPluginClass = (Class<GRImporter>)PrincipalClass;
            selectedPluginPriority = priorityValue;
            requiredResources = [bundle objectForInfoDictionaryKey:
                                    @"GRRequiredResources"];
       }
    }

    if (resources != NULL  && requiredResources != nil)
        *resources = requiredResources;

    NSLog(@"returning class: %@", SelectedPluginClass);

    return SelectedPluginClass;
}

- (const CFStringRef)_UTTypeForFile:(NSString*)file
{
    CFStringRef extension = (CFStringRef)[file pathExtension];
    return UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                extension,
                                                NULL);
}

- (Class<GRImporter>)importerClassForTask:(GRTask*)task
                        requiredResources:(NSArray**)resources
{
    const CFStringRef type = [self _UTTypeForFile:task.path];
    return [self _defaultImporterClassForType:type
                                  destination:task.destination
                            requiredResources:resources];
}

@end
