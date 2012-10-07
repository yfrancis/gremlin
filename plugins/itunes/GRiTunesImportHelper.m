/*
 *  Created by Youssef Francis on October 3rd, 2012.
 */

#import "GRiTunesImportHelper.h"
#import "GRStoreServices.h"

#define kDownloadsDir [NSHomeDirectory() stringByAppendingPathComponent: \
                        @"Media/Downloads"]

@implementation GRiTunesImportHelper

+ (SSDownloadQueue*)downloadQueue
{
    static dispatch_once_t once;
    static SSDownloadQueue* downloadQueue;
    dispatch_once(&once, ^{
        NSArray* kinds = [SSDownloadQueue mediaDownloadKinds];
        downloadQueue = [[SSDownloadQueue alloc] initWithDownloadKinds:kinds];
        [downloadQueue retain]; // Apple sends an extra release >_>
    });
    return downloadQueue;
}

+ (BOOL)importAudioFileAtPath:(NSString*)path
                    mediaKind:(NSString*)mediaKind
                 withMetadata:(NSDictionary*)info
{
    // if the provided metadata does not at least contain a track
    // then we should bail out quickly, as this is not a supported
    // scenario (StoreServices will not choke, it'll instead just
    // fail silently, which is far worse)
    if ([[info objectForKey:@"title"] length] == 0)
        return NO;
    
    // we need to move the files into a sandbox-reachable dir
    NSString* filename = [path lastPathComponent];
    NSString* npath = [kDownloadsDir stringByAppendingPathComponent:filename];
    [[NSFileManager defaultManager] moveItemAtPath:path 
                                            toPath:npath
                                             error:nil];

    SSDownloadMetadata* mtd;
    mtd = [[SSDownloadMetadata alloc] initWithKind:mediaKind];

    // podcast handling
    if ([mediaKind isEqualToString:@"podcast"] ||
        [mediaKind isEqualToString:@"videoPodcast"]) {
        NSURL* fURL = [NSURL URLWithString:[info objectForKey:@"podcastURL"]];
        [mtd setPodcastFeedURL:fURL];
        [mtd setIndexInCollection:[info objectForKey:@"episodeNumber"]];
        [mtd setCollectionName:[info objectForKey:@"podcastName"]];
    }
    else {
        // songs + movies + tv shows
        if ([mediaKind isEqualToString:@"song"]) {
            [mtd setCollectionName:[info objectForKey:@"albumName"]];
        }
        else if ([mediaKind isEqualToString:@"feature-movie"]) {
 
        }
        else if ([mediaKind isEqualToString:@"tv-episode"]) {
            NSNumber* sNum = [info objectForKey:@"seasonNumber"];
            [mtd setSeasonNumber:sNum];
            [mtd setSeriesName:[info objectForKey:@"seriesName"]];
            [mtd setIndexInCollection:[info objectForKey:@"episodeNumber"]];
        }
    }

    [mtd setPrimaryAssetURL:[NSURL fileURLWithPath:npath]];

    double duration = [[info objectForKey:@"duration"] doubleValue];
    NSNumber* duration_num = [NSNumber numberWithUnsignedLongLong:duration];

    // implementation-specific metadata
    [mtd setDurationInMilliseconds:duration_num];
    [mtd setArtworkIsPrerendered:NO];

    // core metadata
    [mtd setTitle:[info objectForKey:@"title"]];
    [mtd setArtistName:[info objectForKey:@"artist"]];
    [mtd setGenre:[info objectForKey:@"type"]];
    [mtd setReleaseYear:[info objectForKey:@"year"]];
    [mtd setPurchaseDate:[NSDate date]];

    // descriptions
    [mtd setShortDescription:[info objectForKey:@"shortDescription"]];
    [mtd setLongDescription:[info objectForKey:@"longDescription"]];

    NSData* imageData = [info objectForKey:@"imageData"];
    if (imageData != nil) {
        // if we have cover art, we write it to file next to
        // the media asset, and tell SS where to find it
        NSString* ap = [[npath stringByDeletingPathExtension] 
                            stringByAppendingPathExtension:@"jpg"];
        [imageData writeToFile:ap atomically:NO];
        [mtd setFullSizeImageURL:[NSURL fileURLWithPath:ap]];
    }

    SSDownload* dl = [[SSDownload alloc] initWithDownloadMetadata:mtd];
    SSDownloadQueue* queue = [self downloadQueue];

    [queue addDownload:dl];

    NSConditionLock* dlLock = [[NSConditionLock alloc] initWithCondition:0];

    [dl setDownloadHandler:nil completionBlock:^{
        // how do we know if the download failed? look into this
        [dlLock lock];
        [dlLock unlockWithCondition:1];
    }];

    [dlLock lockWhenCondition:1];
    [dlLock unlock];
    [dlLock release];

    [dl release];

    return YES;
}

@end
