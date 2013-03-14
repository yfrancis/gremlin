#import <Gremlin/Gremlin.h>
#import "GRiTunesImportAudioActivity.h"

@implementation GRiTunesImportAudioActivity

- (NSString*)activityType
{
	return @"co.cocoanuts.gremlin.activity.import.iTunes.audio";
}

- (NSString*)activityTitle
{
	return @"Import Audio to Music Library";
}

- (UIImage*)activityImage
{
	return [UIImage imageWithContentsOfFile:
		[[NSBundle bundleWithIdentifier:@"co.cocoanuts.gremlin.activities"] 
			pathForResource:@"GremlinAudio" 
					 ofType:@"png"]];
}

- (void)addFileWithInfo:(NSDictionary*)info
{
	NSMutableDictionary* newInfo = [info mutableCopy];
	newInfo[@"mediaKind"] = self.mediaKind ? self.mediaKind : @"song";
	[super addFileWithInfo:newInfo];
}

@end
