/*
 *  Created by Youssef Francis on October 3rd, 2012.
 */

#import "GRiTunesImportHelper.h"
#import "GRStoreServices.h"

#define kDownloadsDir [NSHomeDirectory() stringByAppendingPathComponent: \
                        @"Media/Downloads"]

@implementation GRiTunesImportHelper

+ (BOOL)importAudioFileAtPath:(NSString*)path
                 withMetadata:(NSDictionary*)info
{
    // we need to move the files into a sandbox-reachable dir
    NSString* filename = [path lastPathComponent];
    NSString* npath = [kDownloadsDir stringByAppendingPathComponent:filename];
    [[NSFileManager defaultManager] moveItemAtPath:path 
                                            toPath:npath
                                             error:nil];

    SSDownloadMetadata* mtd = [[SSDownloadMetadata alloc] initWithKind:@"song"];
    [mtd setPrimaryAssetURL:[NSURL fileURLWithPath:npath]];

    double duration = [[info objectForKey:@"duration"] doubleValue];
    NSNumber* duration_num = [NSNumber numberWithUnsignedLongLong:duration];

    [mtd setDurationInMilliseconds:duration_num];
    [mtd setArtworkIsPrerendered:NO];

    [mtd setTitle:[info objectForKey:@"title"]];
    [mtd setArtistName:[info objectForKey:@"artist"]];
    [mtd setCollectionName:[info objectForKey:@"albumName"]];
    [mtd setGenre:[info objectForKey:@"type"]];

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
    NSArray* kinds = [SSDownloadQueue mediaDownloadKinds];
    SSDownloadQueue* queue = [[SSDownloadQueue alloc] initWithDownloadKinds:kinds];

    [queue addDownload:dl];
    [queue release];

    NSConditionLock* dlLock = [[NSConditionLock alloc] initWithCondition:0];

    [dl setDownloadHandler:nil completionBlock:^{
        // how do we know if the download failed? look into this
        NSLog(@"download complete?");
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
