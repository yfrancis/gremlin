@interface SSDownloadMetadata : NSObject
@property (copy) NSString* bundleIdentifier;
@end

@interface IPodLibraryItem : NSObject
@property (copy) SSDownloadMetadata* itemMetadata;
@property (copy) NSString* itemDownloadIdentifier;
@end

%hook IPodLibrary

static NSMutableArray* _imported;

- (void)_addLibraryItem:(IPodLibraryItem*)item toMusicLibrary:(id)library error:(NSError**)error
{
	SSDownloadMetadata* metadata = [item itemMetadata];
	if ([[metadata bundleIdentifier] isEqualToString:@"co.cocoanuts.gremlin.gritunesimporter"]) {
		[metadata setBundleIdentifier:nil];
		NSString* identifier = [item itemDownloadIdentifier];
		if ([_imported containsObject:identifier])
			return;
		[_imported addObject:identifier];
	}

	%orig;
}

%end

%ctor
{
	_imported = [NSMutableArray new];
	%init;
}
