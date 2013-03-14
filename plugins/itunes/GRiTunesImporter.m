/*
 *  Created by Youssef Francis on September 25th, 2012.
 */

#include <unistd.h>

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

    const char* tmplCstr = [tmplStr fileSystemRepresentation];
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

+ (NSDictionary*)_metadataForAsset:(AVURLAsset*)asset
{
    if (asset == nil)
        return nil;

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
            [dict setObject:value forKey:mdi.commonKey];
    }

    // other metadata without a common representation
    NSArray* availableFormats = [asset availableMetadataFormats];
    for (NSString* fmt in availableFormats) {
        NSArray* md = [asset metadataForFormat:fmt];

        for (AVMetadataItem* item in md) {
            if (item.commonKey != nil) {
                id value = item.value;
                
                // artwork has special handling
                if ([item.commonKey isEqualToString:AVMetadataCommonKeyArtwork]) {
                    NSData* imageData = nil;
                    if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3])
                        imageData = [value objectForKey:@"data"];
                    else if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes])
                        imageData = value;
                    
                    if (imageData != nil)
                        [dict setObject:imageData forKey:@"imageData"];
                }
                else if ([value isKindOfClass:[NSString class]] ||
                         [value isKindOfClass:[NSNumber class]]) {
                    [dict setObject:value forKey:item.commonKey];
                }
            }
            else {
                NSString* keyName = (NSString*)item.key;
                if ([item.key isKindOfClass:[NSNumber class]]) {
                    NSUInteger keyNumber = ntohl([(NSNumber*)item.key unsignedIntegerValue]);
                    keyName = [NSString stringWithFormat:@"%.4s", (char*)&keyNumber];
                }

                if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3] &&
                    [keyName isEqualToString:AVMetadataID3MetadataKeyTrackNumber]) {
                    [dict setObject:[item numberValue] forKey:@"trackNumber"];
                }
                else if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes] &&
                        [keyName isEqualToString:AVMetadataiTunesMetadataKeyTrackNumber]) {
                    int16_t trackData[4];
                    [item.dataValue getBytes:trackData length:sizeof(trackData)];
                    
                    int16_t trackNumber = ntohs(trackData[1]);
                    if (trackNumber) 
                        [dict setObject:[NSNumber numberWithInt:trackNumber] forKey:@"trackNumber"];

                    int16_t trackCount = ntohs(trackData[2]);
                    if (trackCount)
                        [dict setObject:[NSNumber numberWithInt:trackCount] forKey:@"trackCount"];
                }
            }
        }
    }

    // we also need the duration in ms
    CMTime duration = asset.duration;
    uint64_t ms = CMTimeGetSeconds(duration) * 1000;
    if (ms > 0)
        [dict setObject:[NSNumber numberWithUnsignedLongLong:ms]
                 forKey:@"duration"];

    // most basic requirement for metadata is a title
    if ([[dict objectForKey:@"title"] length] == 0) {
        NSString* path = [asset.URL path];
        NSString* title = [[path lastPathComponent]
                            stringByDeletingPathExtension]; 
        [dict setObject:title forKey:@"title"];

    }

    if ([[dict objectForKey:@"artist"] length] == 0) {
        [dict setObject:@"Unknown Artist" forKey:@"artist"];
    }

    if ([[dict objectForKey:@"albumName"] length] == 0) {
        [dict setObject:@"Unknown Album" forKey:@"albumName"];
    }

    return dict;
}

+ (NSDictionary*)_outputMetadataForAsset:(AVURLAsset*)asset
                                userData:(NSDictionary*)user
{
    NSMutableDictionary* outDict;
    // no user info provided, return metdata from file
    if (user == nil) {
        outDict = [NSMutableDictionary dictionaryWithDictionary:
                    [self _metadataForAsset:asset]];
    }
    else {
        // if client does not want us to merge metadata
        if ([[user objectForKey:@"replace"] boolValue] == YES)
            outDict = [NSMutableDictionary dictionaryWithDictionary:user];
        else {
            // otherwise client wants us to combine the
            // user-provided metadata with the data on
            // disk, with priority given to the user data
            NSDictionary* dmd = [self _metadataForAsset:asset];
            outDict = [NSMutableDictionary dictionaryWithDictionary:dmd];

            // now apply all key-value pairs from user dict onto whatever
            // outDict is, we don't care if the key already exists, user
            // data always takes priority (i.e. if the user doesn't want
            // to override a key they should not provide a value for it)
            for (NSString* key in [user allKeys])
                [outDict setObject:[user objectForKey:key] forKey:key];
        }
    }

    // title is required, if one isn't provided, use the filename
    if ([[outDict objectForKey:@"title"] length] == 0) {
        NSString* filename = [[asset.URL absoluteString] lastPathComponent];
        [outDict setObject:[filename stringByDeletingPathExtension]
                    forKey:@"title"];
    }

    return outDict;
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
        AVURLAsset* asset = [AVURLAsset assetWithURL:iURL];

        NSDictionary* userMetadata = [info objectForKey:@"metadata"];
        NSDictionary* metadata = [self _outputMetadataForAsset:asset
                                                      userData:userMetadata];

        if (metadata == nil) {
            // if no metadata, we cannot import, bail out
            NSLog(@"GRiTunesImporter: no metadata found for import: %@", info);
            if (error != NULL)
                *error = [NSError errorWithDomain:@"gremlin"
                                             code:404
                                         userInfo:info];
            return NO;
        }

        // create temp directory to house the processed file
        NSString* tempDir = [self _makeTemporaryDirectory];

        // flag to indicate if preprocessing was successful
        BOOL status = NO;

        if ([mediaKind isEqualToString:@"song"] ||
            [mediaKind isEqualToString:@"ringtone"] ||
			[mediaKind isEqualToString:@"tone"]) {
            // determine output path for conversion (or plain copy)
            NSString* fname;
            fname = [[ipath lastPathComponent] stringByDeletingPathExtension];

            BOOL isSong = [mediaKind isEqualToString:@"song"];
            NSString* ext = isSong ? @"m4a" : @"m4r";
            opath = [[tempDir stringByAppendingPathComponent:fname]
                        stringByAppendingPathExtension:ext];

            CMTimeRange timeRange;
            CFDictionaryRef rangeDict;
            rangeDict = (CFDictionaryRef)[metadata objectForKey:@"timeRange"];
            if (rangeDict != NULL) {
                timeRange = CMTimeRangeMakeFromDictionary(rangeDict);
            }
            else {
                timeRange = kCMTimeRangeZero;
            }

			if (!CMTimeRangeEqual(timeRange, kCMTimeRangeZero)) {
				CMTime duration = timeRange.duration;
				double duration_s = (double)duration.value/(double)duration.timescale;

				NSMutableDictionary* tempMd = [metadata mutableCopy];
				[tempMd setObject:[NSNumber numberWithDouble:duration_s] forKey:@"duration"];
				metadata = [[tempMd copy] autorelease];
			}

            // perform the conversion
            status = [GRiTunesMP4Utilities convertAsset:asset
                                                   dest:opath
                                               metadata:metadata
                                              timeRange:timeRange
                                                  error:error];
        }
        // TODO: use a supportedTypes dictionary for checks
        else if ([mediaKind isEqualToString:@"podcast"] ||
                 [mediaKind isEqualToString:@"videoPodcast"] ||
                 [mediaKind isEqualToString:@"music-video"] ||
                 [mediaKind isEqualToString:@"feature-movie"] ||
                 [mediaKind isEqualToString:@"tv-episode"]) {
            // determine output path for copy
            NSString* fname = [ipath lastPathComponent];
            opath = [tempDir stringByAppendingPathComponent:fname];

            // copy the file to temp
            NSFileManager* fm = [NSFileManager defaultManager];
            status = [fm copyItemAtURL:iURL
                                 toURL:[NSURL fileURLWithPath:opath]
                                 error:error];
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
