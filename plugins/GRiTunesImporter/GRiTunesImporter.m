/*
 *  Created by Youssef Francis on September 25th, 2012.
 */

#import "GRImporterProtocol.h"
#import "GRiTunesImportHelper.h"
#import "GRiTunesMP4Utilities.h"

#import <AVFoundation/AVFoundation.h>

@interface GRiTunesImporter : NSObject <GRImporter>
@end

@implementation GRiTunesImporter

+ (NSString*)_makeTemporaryDirectory
{
    NSString* tmplStr;
    NSString* mkdstr = @"gremlin.XXXXXX";
    tmplStr = [NSTemporaryDirectory() stringByAppendingPathComponent:mkdstr];

    const char *tmplCstr = [tmplStr fileSystemRepresentation];
    char* tmpNameCstr = (char*)malloc(strlen(tmplCstr) + 1);
    strcpy(tmpNameCstr, tmplCstr);
    char* result = mkdtemp(tmpNameCstr);

    if (!result) {
        free(tmpNameCstr);
        return nil;
    }

    NSString* ret = [[NSFileManager defaultManager]
        stringWithFileSystemRepresentation:tmpNameCstr
                                    length:strlen(result)];

    free(tmpNameCstr);

    return ret;
}

+ (NSDictionary*)_metadataForAsset:(AVAsset*)asset
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];

    // scan common metadata keys
    NSArray* commonMetadata = [asset commonMetadata];
    for (AVMetadataItem* mdi in commonMetadata) {
        id value = mdi.value;
        
        // artwork has special handling
        if ([mdi.commonKey isEqualToString:AVMetadataCommonKeyArtwork]) {
            NSData* imageData = nil;
            if ([mdi.keySpace isEqualToString:AVMetadataKeySpaceID3])
                imageData = [value objectForKey:@"data"];
            else if ([mdi.keySpace isEqualToString:AVMetadataKeySpaceiTunes])
                imageData = value;
            
            if (imageData != nil)
                [dict setObject:imageData forKey:@"imageData"];
        }
        else if ([value isKindOfClass:[NSString class]])
            [dict setObject:value
                     forKey:mdi.commonKey];
    }

    // we also need the duration in ms
    CMTime duration = asset.duration;
    uint64_t ms = CMTimeGetSeconds(duration) * 1000;
    [dict setObject:[NSNumber numberWithUnsignedLongLong:ms]
        forKey:@"duration"];
    
    return dict;
}

+ (GRImportOperationBlock)newImportBlock
{
    return Block_copy(^(NSDictionary* info, NSError** error)
    {
        NSString* opath = nil;
        NSString* ipath = [info objectForKey:@"path"];
        NSString* mediaKind = [info objectForKey:@"mediaKind"];
        if (mediaKind == nil)
            mediaKind = @"song";

        NSURL* iURL = [NSURL fileURLWithPath:ipath];
        AVAsset* asset = [AVURLAsset assetWithURL:iURL];
        NSDictionary* metadata = [self _metadataForAsset:asset];

        // create temp directory to house the processed file
        NSString* tempDir = [self _makeTemporaryDirectory];

        // flag to indicate if preprocessing was successful
        BOOL status = NO;

        if ([mediaKind isEqualToString:@"song"]) {
            // determine output path for conversion (or plain copy)
            NSString* fname;
            fname = [[ipath lastPathComponent] stringByDeletingPathExtension];
            opath = [[tempDir stringByAppendingPathComponent:fname]
                        stringByAppendingPathExtension:@"m4a"];

            // perform the conversion
            status = [GRiTunesMP4Utilities convertAsset:asset
                                                   dest:opath
                                                  error:error];
        }
        // TODO: set up custom handling for each of these types
        // where appropriate (some may not require it)
        else if ([mediaKind isEqualToString:@"music-video"]) {

        }
        else if ([mediaKind isEqualToString:@"feature-movie"]) {

        }
        else if ([mediaKind isEqualToString:@"tv-episode"]) {

        }
        else if ([mediaKind isEqualToString:@"podcast"]) {
            // determine output path for copy
            NSString* fname;
            fname = [ipath lastPathComponent];
            opath = [tempDir stringByAppendingPathComponent:fname];

            // copy the file to temp
            NSFileManager* fm = [NSFileManager defaultManager];
            status = [fm copyItemAtURL:iURL
                                 toURL:[NSURL fileURLWithPath:opath]
                                 error:error];
        }
        else if ([mediaKind isEqualToString:@"videoPodcast"]) {
             
        }

        // if preprocessing was successful, attempt to import into itunes
        if (status == YES) {
            // return status
            status = [GRiTunesImportHelper importAudioFileAtPath:opath
                                                       mediaKind:mediaKind
                                                    withMetadata:metadata];
        }

        // clean-up: remove temp dir created at start of import
        NSFileManager* fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:tempDir error:nil];

        return status;
    });
}

@end

// vim:ft=objc
