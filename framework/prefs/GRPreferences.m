#import <Preferences/Preferences.h>

@interface GRPreferencesListController : PSListController

@end

@implementation GRPreferencesListController

- (void)viewDidBecomeVisible
{
    NSLog(@"%@ did become visible!", self);
    [super viewDidBecomeVisible];
}

- (id)specifiers {
    if (_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"GRPreferences" target:self] retain];
    }
    return _specifiers;
}
@end

// vim:ft=objc
