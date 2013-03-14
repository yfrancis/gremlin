/*
 *  Created by Youssef Francis on October 3rd, 2012.
 */

@interface SSDownloadAsset : NSObject
- (id)initWithURLRequest:(NSURLRequest*)request;
@end

@interface SSDownloadMetadata : NSObject
 @property(retain) NSString* kind;

- (id)initWithKind:(NSString*)k;
- (id)initWithDictionary:(id)dictionary;
- (void)setValue:(id)value forMetadataKey:(id)metadataKey;
- (void)_setValue:(id)value forTopLevelKey:(id)topLevelKey;
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
- (void)setFileExtension:(NSString*)ext;
- (void)setBundleIdentifier:(id)identifier;
- (void)setComposerName:(id)name;
- (NSURL*)fullSizeImageURL;
- (id)seriesName;
- (int)keyStyle;
- (void)setKeyStyle:(int)s;
- (NSDictionary*)dictionary;
- (NSDictionary*)newDownloadProperties;
@property(assign) BOOL shouldDownloadAutomatically;
@property(assign, getter=isAutomaticDownload) BOOL automaticDownload;
@end

@interface SSDownloadPhase : NSObject
-(int)phaseType;
@end

@interface SSDownloadStatus : NSObject
-(SSDownloadPhase*)activePhase;
-(float)percentComplete;
@end

@interface SSDownload : NSObject
@property(readonly, assign, nonatomic) id downloadIdentifier;
- (id)initWithDownloadMetadata:(SSDownloadMetadata*)md;
- (void)setValuesWithStoreDownloadMetadata:(id)storeDownloadMetadata;
- (void)setDownloadHandler:(id)h completionBlock:(void (^)(void))b;
- (SSDownloadStatus*)status;
- (BOOL)isCancelable;
- (BOOL)addAsset:(id)asset forType:(id)type;
@end

@interface SSDownloadManager : NSObject

+(id)IPodDownloadManager;	// 0x40d4d
-(void)addObserver:(id)obs;
-(void)removeObserver:(id)obs;
-(NSArray*)downloads;
-(NSArray*)activeDownloads;
-(id)managerOptions;
-(void)cancelDownloads:(id)downloads completionBlock:(id)block;
-(void)cancelAllDownloadsWithCompletionBlock:(id)block;
-(void)insertDownloads:(id)downloads beforeDownload:(id)download completionBlock:(id)block;
-(void)setDownloads:(id)downloads completionBlock:(id)block;
-(void)addDownloads:(id)downloads completionBlock:(id)block;
@end

@interface SSDownloadQueue : NSObject
-(id)initWithDownloadManagerOptions:(id)downloadManagerOptions;
+ (NSArray*)mediaDownloadKinds;
- (id)initWithDownloadKinds:(NSArray*)k;
- (void)addDownload:(SSDownload*)dl;
- (SSDownloadManager*)downloadManager;
- (void)setDownloadManager:(SSDownloadManager*)downloadManager;
-(BOOL)cancelDownload:(id)download;
@end