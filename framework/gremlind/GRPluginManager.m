/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRPluginManager.h"
#import <MobileCoreServices/UTType.h>

#ifdef HAVE_BUGSENSE
#import <BugSense/BugSenseCrashController.h>
#endif

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

- (NSArray*)_standardizedResourceArray:(NSArray*)ain
{
    NSMutableArray* tmp = [NSMutableArray array];

    NSString* lower = nil;
    for (NSString* resource in ain) {
        lower = [resource lowercaseString];
        if ([tmp containsObject:lower] == NO)
            [tmp addObject:lower];
    }

    [tmp sortUsingSelector:@selector(compare:)];

    return tmp;
}

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
        // plugin parsing goes inside an exception block because
        // who knows how badly malformed a plugin might be
        @try {
            NSLog(@"found plugin: %@", plugin);

            NSString* fullPath;
            fullPath = [kPluginDirectory stringByAppendingPathComponent:plugin];

            NSLog(@"fullPath: %@", fullPath);
            
            NSBundle* bundle = [NSBundle bundleWithPath:fullPath];
            
            NSLog(@"%@ version check", plugin);
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

            NSLog(@"%@ passed strict version check", plugin);

            // otherwise look for range of supported versions
            float minVersion, maxVersion;
            minVersion = [[bundle objectForInfoDictionaryKey:
                            @"MinimumCFVersionNumber"] floatValue];
            maxVersion = [[bundle objectForInfoDictionaryKey:
                            @"MaximumCFVersionNumber"] floatValue];

            float systemVersion = kCFCoreFoundationVersionNumber;

            if (systemVersion < minVersion || 
                (maxVersion > 0.0f && systemVersion > maxVersion))
                continue;

            NSLog(@"%@ passed range version check", plugin);

            NSString* query = nil;
            NSDictionary* support = nil;

            if (destination != nil) {
                query = @"GRDestinationPriority";
                // if a destination is provided, we want to select
                // a plugin that will import to that destination
                NSDictionary* destDict;
                destDict = [bundle objectForInfoDictionaryKey:@"GRDestination"];

                if (destDict != nil && 
                    ![destDict isKindOfClass:[NSDictionary class]])
                    continue;

                if ([[destDict objectForKey:@"GRDestinationName"]
                        isEqualToString:destination])
                    support = destDict;
            }
            else {
                // otherwise just look for a plugin that supports
                // the type of file being imported
                support = [bundle objectForInfoDictionaryKey:
                            @"GRSupportedTypes"];
                query = (NSString*)type;
            }

            NSLog(@"%@: query = %@, support = %@", plugin, query, support);

            if (support != nil &&
                ![support isKindOfClass:[NSDictionary class]])
                continue;

            NSNumber* priority = [support objectForKey:query];
            if (priority == nil) {
                // maybe this plugin supports all generic file types
                // and/or destinations?
                priority = [support objectForKey:@"GRSupportsAll"];
                
                if (priority == nil)
                    continue;
            }

			if (![priority isKindOfClass:[NSNumber class]])
				continue;

            // check plugin priority
            NSUInteger priorityValue = [priority unsignedIntegerValue];
            if (priorityValue > selectedPluginPriority) {
                // check if the bundle principal class conforms to GRImporter
                Class PrincipalClass = [bundle principalClass];
                NSLog(@"%@ got principalclass: %@", plugin, PrincipalClass);
                
                // plugins must conform to these specs
                Protocol* importProt = @protocol(GRImporter);
                SEL importSel = @selector(newImportBlock);

                if ([PrincipalClass conformsToProtocol:importProt] &&
                    [PrincipalClass respondsToSelector:importSel])
                {   
					// this code section cannot throw an exception, so
					// it is safe to just 'continue' in the exception
					// handler
                    NSLog(@"%@ conforms!", plugin);
                    SelectedPluginClass = (Class<GRImporter>)PrincipalClass;
                    selectedPluginPriority = priorityValue;
                    requiredResources = [bundle objectForInfoDictionaryKey:
                                        	@"GRRequiredResources"];
                }
           }
        }
        @catch (NSException* exc) {
            NSLog(@"Exception encountered while parsing '%@' plugin", plugin);
#ifdef HAVE_BUGSENSE
            BUGSENSE_LOG(exc, plugin);
#endif
        }
    }

    if (resources != NULL && requiredResources != nil)
        *resources = [self _standardizedResourceArray:requiredResources];

    NSLog(@"GRPluginManager: returning class %@", SelectedPluginClass);

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
