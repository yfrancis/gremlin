#import <Preferences/Preferences.h>

@interface prefsListController: PSListController {
}
@end

@implementation prefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"prefs" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
