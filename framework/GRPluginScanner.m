/*
 * Created by Youssef Francis on September 26th, 2012.
 */

#import "GRPluginScanner.h"
#import <MobileCoreServices/UTType.h>
#import <MobileCoreServices/UTCoreTypes.h>

#define kPluginDirectory @"/Library/Gremlin/Plugins"
#define kCFBundleDocumentTypesKey @"CFBundleDocumentTypes"
#define kLSItemContentTypesKey @"LSItemContentTypes"
#define kLSHandlerRankKey @"LSHandlerRank"
#define kGRRequiredCFVersionNumbersKey @"RequiredCFVersionNumbers"
#define kGRMinimumCFVersionNumberKey @"MinimumCFVersionNumber"
#define kGRMaximumCFVersionNumberKey @"MaximumCFVersionNumber"

@implementation GRPluginScanner

+ (BOOL)pluginBundlePassesVersionCheck:(NSBundle*)bundle
{
    // first check if plugin has strict version requirements
    NSArray* strict = [bundle objectForInfoDictionaryKey:
                        kGRRequiredCFVersionNumbersKey];
    if (strict != nil) {
        NSNumber* currentVersion;
        currentVersion = [NSNumber numberWithFloat:
                          kCFCoreFoundationVersionNumber];
        if (![strict containsObject:currentVersion])
            return NO;
    }
    
    // otherwise look for range of supported versions
    float minVersion, maxVersion;
    minVersion = [[bundle objectForInfoDictionaryKey:
                   kGRMinimumCFVersionNumberKey] floatValue];
    maxVersion = [[bundle objectForInfoDictionaryKey:
                   kGRMaximumCFVersionNumberKey] floatValue];
    
    float systemVersion = kCFCoreFoundationVersionNumber;
    if (systemVersion < minVersion ||
        (maxVersion > 0.0f && systemVersion > maxVersion))
        return NO;
    
    return YES;
}

+ (BOOL)pluginBundle:(NSBundle*)bundle
        supportsType:(const CFStringRef)type
                rank:(NSString**)rank
{
    // maybe use LS API from MobileCoreServices to do this?
    NSArray* types;
    types = [bundle objectForInfoDictionaryKey:kCFBundleDocumentTypesKey];
        
    for (NSDictionary* typeDict in types) {
        NSArray* utis = [typeDict objectForKey:kLSItemContentTypesKey];
        if ([utis containsObject:(NSString*)type] ||
            [utis containsObject:(NSString*)kUTTypeData]) {
            if (rank != NULL)
                *rank = [typeDict objectForKey:kLSHandlerRankKey];
            return YES;
        }
    }
    
    return NO;
}

+ (const CFStringRef)copyUTTypeForFile:(NSString*)file
{
    CFStringRef extension = (CFStringRef)[file pathExtension];
    return UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                 extension,
                                                 NULL);
}

+ (NSArray*)availableDestinationsForFile:(NSString*)path
{
    const CFStringRef type = [self copyUTTypeForFile:path];
    
    NSMutableArray* destinations = [NSMutableArray array];
    
    NSString* plugs = [[NSBundle mainBundle] pathForResource:kPluginDirectory
                                                      ofType:nil];
        
    NSError* err = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* plugins = [fm contentsOfDirectoryAtPath:plugs
                                               error:&err];
    
    if (plugins == nil || err != nil)
        return nil;
    
    for (NSString* plugin in plugins) {
        // plugin parsing goes inside an exception block because
        // who knows how badly malformed a plugin might be
        @try {
            NSString* fullPath;
            fullPath = [plugs stringByAppendingPathComponent:plugin];
            NSBundle* bundle = [NSBundle bundleWithPath:fullPath];
            
            // check if this plugin is supported on this system version
            if (![self pluginBundlePassesVersionCheck:bundle])
                continue;

            // check if this plugin can handle this file type, if
            // path is passed as nil, we are just checking for all
            // available plugins on this system
            NSString* rank = nil;
            if (path != nil) {
                if (![self pluginBundle:bundle supportsType:type rank:&rank])
                    continue;
            }
            
            // plugin passed all checks, add it to list of potential plugins
            GRDestination* destination;
            destination = [GRDestination destinationForBundle:bundle rank:rank];
            [destinations addObject:destination];
        }
        @catch (NSException* exc) {
            NSLog(@"Exception encountered while parsing '%@' plugin", plugin);
        }
    }

    // sort the destinations by rank before returning them
    [destinations sortUsingSelector:@selector(compare:)];
    
    if (type != NULL)
        CFRelease(type);

    return destinations;
}

+ (GRDestination*)defaultDestinationForFile:(NSString*)path
{
    NSArray* available = [self availableDestinationsForFile:path];
    if (available.count > 0)
        return [available objectAtIndex:0];
    return nil;
}

+ (NSArray*)allAvailableDestinations
{
    return [self availableDestinationsForFile:nil];
}

@end
