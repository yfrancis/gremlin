#import <AppSupport/CPDistributedMessagingCenter.h>
#define kCenterPrefix @"co.cocoanuts.GRDocumentImportProxy:"

#ifndef GSEVENT_H
typedef void* GSEventRef;
#endif

%hook UIApplication

- (void)_applicationOpenURL:(id)url event:(GSEventRef)event {
    %log; %orig;
}
- (void)_applicationOpenURL:(id)url payload:(id)payload {
    %log; %orig;
}

- (id)_applicationProxyForURLScheme:(id)urlscheme publicURLsOnly:(BOOL)only {
    %log; return %orig;
}

- (void)_callApplicationResumeHandlersForURL:(id)url payload:(id)payload {
    %log; %orig;
}
- (void)_callInitializationDelegatesForURL:(id)url 
                                   payload:(id)payload 
                                 suspended:(BOOL)suspended {
    %log; %orig;
}
- (BOOL)_canOpenURL:(id)url publicURLsOnly:(BOOL)only {
    %log; return %orig;
}

- (void)applicationOpenURL:(id)url {
    %log; %orig;
}

- (BOOL)canOpenURL:(id)url {
    %log; return %orig;
}

- (BOOL)openURL:(id)url {
    %log; return %orig;
}

%end

@interface UIApplication ()
- (void)_callApplicationResumeHandlersForURL:(id)url payload:(id)payload; 
@end

@interface GRImportProxy : NSObject {
    CPDistributedMessagingCenter* center;
}
@end

@implementation GRImportProxy

- (id)init {
    self = [super init];
    
    if (self) {
        NSString* app = [[NSBundle mainBundle] bundleIdentifier];

        NSString* centerName;
        centerName = [kCenterPrefix stringByAppendingString:app];

        NSLog(@"GRImportProxy started server named: %@", centerName);

        center = [CPDistributedMessagingCenter centerNamed:centerName];
        [center retain];
        [center runServerOnCurrentThread];
        [center registerForMessageName:@"OpenURL"
                                target:self
                              selector:@selector(openURL:userInfo:)];
    }

    return self;
}

- (NSDictionary*)openURL:(NSString*)s userInfo:(NSDictionary*)info {
    NSLog(@"GRImportProxy: openURL: %@, %@", s, info);

    NSURL* url = [NSURL URLWithString:[info objectForKey:@"FileURL"]];
    NSString* launchKey = @"UIApplicationLaunchOptionsURLKey";
    NSDictionary* payload = [NSDictionary dictionaryWithObject:url
                                                        forKey:launchKey];

    UIApplication* app = [%c(UIApplication) sharedApplication];
    [app _callApplicationResumeHandlersForURL:url
                                      payload:payload];

    return [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                       forKey:@"Status"];
}

- (void)dealloc {
    [center release];
    [super dealloc];
}

@end

%ctor {
    GRImportProxy* proxy = [[GRImportProxy alloc] init];
    NSLog(@"started GRImportProxy: %@", proxy);
}
