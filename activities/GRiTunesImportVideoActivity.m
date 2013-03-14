#import <Gremlin/Gremlin.h>
#import "GRiTunesImportVideoActivity.h"

@implementation GRiTunesImportVideoActivity

- (NSString*)activityType
{
	return @"co.cocoanuts.gremlin.activity.import.iTunes.video";
}

- (NSString*)activityTitle
{
	return @"Import to Videos";
}

- (UIImage*)activityImage
{
	return [UIImage imageWithContentsOfFile:
		[[NSBundle bundleWithIdentifier:@"co.cocoanuts.gremlin.activities"] 
			pathForResource:@"Gremlin" 
					 ofType:@"png"]];
}

- (void)addFileWithInfo:(NSDictionary*)info
{
	NSMutableDictionary* newInfo = [info mutableCopy];
	newInfo[@"mediaKind"] = self.mediaKind ? self.mediaKind : @"music-video";
	[super addFileWithInfo:newInfo];
}

@end
