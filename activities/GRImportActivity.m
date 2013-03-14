#import <Gremlin/Gremlin.h>
#import "GRImportActivity.h"
#import "GRImportViewController.h"

@implementation GRImportActivity

- (NSString*)activityType
{
	return @"co.cocoanuts.gremlin.activity.import";
}

- (NSString*)activityTitle
{
	return @"Import";
}

- (UIImage*)activityImage
{
	return [UIImage imageWithContentsOfFile:
		[[NSBundle bundleWithIdentifier:@"co.cocoanuts.gremlin.activities"] 
			pathForResource:@"Gremlin" 
					 ofType:@"png"]];
}

- (BOOL)canPerformWithActivityItems:(NSArray*)activityItems
{
	for (id item in activityItems) {
		if ([item isKindOfClass:[NSDictionary class]]) {
			if (item[@"GRImportActivityInfo"] && item[@"path"]) {
				if ([Gremlin availableDestinationsForFile:item[@"path"]].count > 0)
					return YES;
			}
		}
		else if ([item isKindOfClass:[NSURL class]]) {
			NSURL* URL = item;
			if ([URL isFileURL] && [[NSFileManager defaultManager] fileExistsAtPath:URL.path])
				return YES;
		}
	}

	return NO;
}

- (void)addFileWithInfo:(NSDictionary*)info
{
	[_files addObject:info];
}

- (void)prepareWithActivityItems:(NSArray*)activityItems
{
	self.files = [NSMutableArray new];

	for (id item in activityItems) {
		if ([item isKindOfClass:[NSDictionary class]]) {
			if (item[@"GRImportActivityInfo"] && item[@"path"]) {
				[self addFileWithInfo:item];
				return;
			}
		}
		else if ([item isKindOfClass:[NSURL class]]) {
			NSURL* URL = item;
			if ([URL isFileURL] && [[NSFileManager defaultManager] fileExistsAtPath:URL.path]) {
				[self addFileWithInfo:@{@"path": URL.path}];
				return;
			}
		}
	}
}

- (UIViewController*)activityViewController
{
	if (!_files.count)
		return nil;

	NSDictionary* file = self.files[0];
	UIViewController* importVC = [[GRImportViewController alloc] initWithDictionary:file completion:^(BOOL canceled) {
		if (!canceled)
			[self performActivity];
		else
			[self activityDidFinish:NO];
	}];

	return [[UINavigationController alloc] initWithRootViewController:importVC];
}

- (void)cancelImport:(id)sender
{
	[self activityDidFinish:NO];
}

- (void)completeImport:(id)sender
{
	[self performActivity];
}

- (void)performActivity
{
	BOOL success = NO;
	if (_files.count > 0) {
		[Gremlin importFiles:_files];
		success = YES;
	}

	[self activityDidFinish:success];
}

@end
