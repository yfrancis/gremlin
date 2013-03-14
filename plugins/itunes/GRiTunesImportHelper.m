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

+ (SSDownloadMetadata*)_downloadMetadataForItemAtPath:(NSString*)path
                                            mediaKind:(NSString*)mediaKind
                                         withMetadata:(NSDictionary*)info

{
    SSDownloadMetadata* mtd = [[SSDownloadMetadata alloc] initWithKind:mediaKind];

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
    [mtd setComposerName:@"Gremlin"];
    [mtd setBundleIdentifier:@"co.cocoanuts.gremlin.gritunesimporter"];

    // descriptions
    [mtd setShortDescription:[info objectForKey:@"shortDescription"]];
    [mtd setLongDescription:[info objectForKey:@"longDescription"]];

    NSData* imageData = [info objectForKey:@"imageData"];
    if (imageData != nil) {
        // if we have cover art, we write it to file next to
        // the media asset, and tell SS where to find it
        NSString* ap = [[path stringByDeletingPathExtension] 
                            stringByAppendingPathExtension:@"jpg"];
        [imageData writeToFile:ap atomically:NO];
        [mtd setFullSizeImageURL:[NSURL fileURLWithPath:ap]];
    }

    return [mtd autorelease];
}

+ (SSDownload*)_downloadWithDownloadMetadata:(SSDownloadMetadata*)mtd
                                        path:(NSString*)filePath
{
    [mtd setPrimaryAssetURL:[NSURL fileURLWithPath:filePath]];

    SSDownload* dl = [[SSDownload alloc] initWithDownloadMetadata:mtd];
    [[self downloadQueue] addDownload:dl];

    return [dl autorelease];
}

+ (void)_waitForDownloadCompletion:(SSDownload*)download
{
    NSConditionLock* dlLock = [[NSConditionLock alloc] initWithCondition:0];

    [download setDownloadHandler:nil completionBlock:^{
        [dlLock lock];
        [dlLock unlockWithCondition:1];
    }];

    [dlLock lockWhenCondition:1];
    [dlLock unlock];
    [dlLock release];
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
    
    NSString* tmpPrefix, *uniqueName, *filename, *sandboxPath;
    filename = [path lastPathComponent];
    tmpPrefix = [[path stringByDeletingLastPathComponent] lastPathComponent];
    uniqueName = [tmpPrefix stringByAppendingString:filename];
    sandboxPath = [kDownloadsDir stringByAppendingPathComponent:uniqueName];

    [[NSFileManager defaultManager] createDirectoryAtPath:kDownloadsDir 
                              withIntermediateDirectories:YES 
                                               attributes:nil
                                                    error:nil];

    // we need to move the files into a sandbox-reachable dir
    NSError* error = nil;
    if (![[NSFileManager defaultManager] moveItemAtPath:path 
                                                 toPath:sandboxPath
                                                  error:&error]) {
        NSLog(@"error moving file to sandbox-readable dir: %@", error);
        return NO;
    }

    SSDownloadMetadata* mtd = [self _downloadMetadataForItemAtPath:sandboxPath
                                                         mediaKind:mediaKind
                                                      withMetadata:info];

    SSDownload* dl = [self _downloadWithDownloadMetadata:mtd path:sandboxPath];
    if (dl != nil) {
        [self _waitForDownloadCompletion:dl];

        // [[NSFileManager defaultManager] removeItemAtPath:sandboxPath 
        //                                            error:nil];

        return YES;
    }

    return NO;
}

@end