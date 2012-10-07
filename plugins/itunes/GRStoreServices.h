/*
 *  Created by Youssef Francis on October 3rd, 2012.
 */

@interface SSDownloadMetadata : NSObject
- (id)initWithKind:(NSString*)k;
- (void)setDurationInMilliseconds:(NSNumber*)d;
- (void)setIndexInCollection:(NSNumber*)i;
- (void)setArtworkIsPrerendered:(BOOL)p;
- (void)setTitle:(NSString*)t;
- (void)setArtistName:(NSString*)a;
- (void)setCollectionName:(NSString*)c;
- (void)setGenre:(NSString*)g;
- (void)setPrimaryAssetURL:(NSURL*)u;
- (void)setFullSizeImageURL:(NSURL*)u;
- (void)setReleaseYear:(NSNumber*)releaseYear;
- (void)setSeriesName:(NSString*)name;
- (void)setSeasonNumber:(NSNumber*)number;
- (void)setPurchaseDate:(NSDate*)date;
- (void)setPodcastFeedURL:(NSURL*)url;
- (void)setShortDescription:(NSString*)shortDescription;
- (void)setLongDescription:(NSString*)LongDescription;
@end

@interface SSDownload : NSObject
- (id)initWithDownloadMetadata:(SSDownloadMetadata*)md;
- (void)setDownloadHandler:(id)h completionBlock:(void (^)(void))b;
@end

@interface SSDownloadQueue : NSObject
+ (NSArray*)mediaDownloadKinds;
- (id)initWithDownloadKinds:(NSArray*)k;
- (void)addDownload:(SSDownload*)dl;
@end
