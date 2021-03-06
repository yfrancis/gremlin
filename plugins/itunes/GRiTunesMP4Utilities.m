#import "GRiTunesMP4Utilities.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation GRiTunesMP4Utilities

+ (AudioFileTypeID)_fileTypeForURL:(NSURL*)url
{
    // open file for reading
    AudioFileID fileID = NULL;
    AudioFileOpenURL((CFURLRef)url, kAudioFileReadPermission, 0, &fileID);

    // if we are unable to retrieve a fileID, then we are unable to
    // read the file for opening, so the import cannot continue
    if (fileID == NULL)
        return 0;

    // read metadata from file
    UInt32 propSize = sizeof(AudioFileTypeID);
    AudioFileTypeID fileType = 0;
    AudioFileGetProperty(fileID, 
                         kAudioFilePropertyFileFormat,
                         &propSize,
                         &fileType);

    // we're done reading from the file, close the fd
    AudioFileClose(fileID);

    return fileType;
}

+ (BOOL)_fileOutput:(NSString*)fileType
supportedForSession:(AVAssetExportSession*)session
{
#if 0
    __block BOOL supported = NO;
    NSConditionLock* suppLock = [[NSConditionLock alloc] initWithCondition:0];
    [session determineCompatibleFileTypesWithCompletionHandler:^(NSArray* all) {
        if ([all containsObject:fileType])
            supported = YES;
        [suppLock lock];
        [suppLock unlockWithCondition:1];
    }];

    [suppLock lockWhenCondition:1];
    [suppLock unlock];
    [suppLock release];

    return supported;
#else
    return YES;
#endif
}

+ (NSArray*)_translatedMetadataKeysForAsset:(AVAsset*)asset
                           externalMetadata:(NSDictionary*)external
{
    NSDictionary* itunesKeys;
    itunesKeys = [NSDictionary dictionaryWithObjectsAndKeys:
        AVMetadataiTunesMetadataKeySongName,    AVMetadataCommonKeyTitle,
        AVMetadataiTunesMetadataKeyArtist,      AVMetadataCommonKeyArtist,
        AVMetadataiTunesMetadataKeyAlbum,       AVMetadataCommonKeyAlbumName,
        AVMetadataiTunesMetadataKeyAuthor,      AVMetadataCommonKeyAuthor,
        AVMetadataiTunesMetadataKeyDescription, AVMetadataCommonKeyDescription,
        AVMetadataiTunesMetadataKeyCoverArt,    AVMetadataCommonKeyArtwork,
        nil];

    // AVAssetExportPresetAppleM4A does not pass metadata from source to output
    // we need to scan for ID3 metadata and convert it to itunes metadata
    // where possible (i.e. for keys in the common keyspace)
    BOOL didSetExternalTitle = NO;
    NSArray* sourceMetadata = [asset commonMetadata];
    for (AVMutableMetadataItem* mdi in sourceMetadata) {
        if ([mdi.commonKey isEqualToString:AVMetadataCommonKeyTitle]) {
            NSLog(@"found title key, setting title = %@", [external objectForKey:@"title"]);
            mdi.value = [external objectForKey:@"title"];
            didSetExternalTitle = YES;
        }

        NSString* key = [itunesKeys objectForKey:mdi.commonKey];
        if (key != nil) {
            // we have to do a bit of extra work for artwork if the source
            // stores the cover art in the ID3 format
            if ([mdi.commonKey isEqualToString:AVMetadataCommonKeyArtwork] &&
                [mdi.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
                NSDictionary* info = (NSDictionary*)mdi.value;
                mdi.value = (NSData*)[info objectForKey:@"data"];
            }

            // order of operations here actually matters, first
            // update the key, _then_ update the keySpace
            mdi.key = key;
            mdi.keySpace = AVMetadataKeySpaceiTunes;
        }
    }

    if (!didSetExternalTitle) {
        NSLog(@"did not find title key, setting title = %@", [external objectForKey:@"title"]);
        AVMutableMetadataItem* t = [AVMutableMetadataItem metadataItem];
        t.key = AVMetadataCommonKeyTitle;
        t.keySpace = AVMetadataKeySpaceCommon;
        t.value = [external objectForKey:@"title"];
        sourceMetadata = [[sourceMetadata mutableCopy] autorelease];
        [(NSMutableArray*)sourceMetadata addObject:t];
    }

    return sourceMetadata;
}

+ (AVAssetExportSessionStatus)_convertAsset:(AVAsset*)asset
                                     outURL:(NSURL*)outURL
                                   metadata:(NSDictionary*)metadata
                                 outputType:(NSString*)outputType
                                  timeRange:(CMTimeRange)timeRange
{
    AVAssetExportSession* session;
    NSString* preset = AVAssetExportPresetAppleM4A;
    session = [AVAssetExportSession exportSessionWithAsset:asset 
                                                presetName:preset];

    // if this device cannot produce M4A files, the conversion
    // cannot continue
    if (![self _fileOutput:outputType supportedForSession:session])
        return AVAssetExportSessionStatusFailed;

    // if this asset has no audio tracks, we cannot continue
    NSArray* tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    if ([tracks count] == 0)
        return AVAssetExportSessionStatusFailed;

    session.outputFileType = AVFileTypeAppleM4A;
    session.outputURL = outURL;
    session.metadata = [self _translatedMetadataKeysForAsset:asset 
                                            externalMetadata:metadata];

    if (!CMTimeRangeEqual(kCMTimeRangeZero, timeRange)) {
        // client has specified a time range, first check
        // if its valid and has definite bounds
        if (CMTIMERANGE_IS_INDEFINITE(timeRange))
            return AVAssetExportSessionStatusFailed;

        session.timeRange = timeRange;

        // create 333ms fade
        CMTime fadeTime = CMTimeMake((int64_t)1, 3);
        
        // set up fade in
        CMTime startFadeInTime = timeRange.start;
        CMTime endFadeInTime = CMTimeAdd(startFadeInTime, fadeTime);

        CMTimeRange fadeInTimeRange;
        fadeInTimeRange = CMTimeRangeFromTimeToTime(startFadeInTime,
                                                    endFadeInTime);

        // set up fade out
        CMTime endFadeOutTime = CMTimeAdd(timeRange.start, timeRange.duration);
        CMTime startFadeOutTime = CMTimeSubtract(endFadeOutTime, fadeTime);

        CMTimeRange fadeOutTimeRange;
        fadeOutTimeRange = CMTimeRangeFromTimeToTime(startFadeOutTime,
                                                     endFadeOutTime);

        // get the first audio track
        AVAssetTrack* atrack = [tracks objectAtIndex:0];

        // setup audio mix
        AVMutableAudioMix* exportAudioMix = [AVMutableAudioMix audioMix];
        AVMutableAudioMixInputParameters* inMix;
        inMix = [AVMutableAudioMixInputParameters
                    audioMixInputParametersWithTrack:atrack];
        CMTime fst_ = CMTimeSubtract(timeRange.start, CMTimeMakeWithSeconds(1, 1000));
        [inMix setVolume:0.0 atTime:fst_];
        [inMix setVolumeRampFromStartVolume:0.0
                                toEndVolume:1.0
                                  timeRange:fadeInTimeRange];
        [inMix setVolumeRampFromStartVolume:1.0
                                toEndVolume:0.0
                                  timeRange:fadeOutTimeRange];

        NSArray* mixParams = [NSArray arrayWithObject:inMix];
        exportAudioMix.inputParameters = mixParams;
        
        session.audioMix = exportAudioMix;
    }

    NSConditionLock* convLock = [[NSConditionLock alloc] initWithCondition:0];
    [session exportAsynchronouslyWithCompletionHandler:^{
        [convLock lock];
        [convLock unlockWithCondition:1];
    }];

    [convLock lockWhenCondition:1];
    [convLock unlock];
    [convLock release];

    return [session status];
}

+ (BOOL)_assetIsVideo:(AVAsset*)asset
{
    // enumerate all tracks, if one with
    // video mediaType is found, return YES
    __block BOOL isVideo = NO;

    NSArray* tracks = asset.tracks;
    [tracks enumerateObjectsUsingBlock:^(id assetTrack,
                                         NSUInteger idx,
                                         BOOL* stop) {
        AVAssetTrack* track = (AVAssetTrack*)assetTrack;
        if ([track.mediaType isEqualToString:AVMediaTypeVideo] ||
            [track.mediaType isEqualToString:AVMediaTypeMuxed]) {
            isVideo = YES;
            *stop = YES;
        }
    }];

    return isVideo;
}

+ (BOOL)convertAsset:(AVURLAsset*)asset
                dest:(NSString*)dest
            metadata:(NSDictionary*)metadata
           timeRange:(CMTimeRange)timeRange
               error:(NSError**)error
{
    NSFileManager* fm = [NSFileManager defaultManager]; 
    [fm removeItemAtPath:dest error:nil];

    NSURL* srcURL = asset.URL;
    AudioFileTypeID fileType = [self _fileTypeForURL:srcURL];

    AVAssetExportSessionStatus status;
    status = AVAssetExportSessionStatusFailed;
    switch (fileType) {
        case 0:
            // special case where the filetype could not
            // be determined, import cannot continue
            if (error != NULL)
                *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:NSFileNoSuchFileError
                                         userInfo:nil];
            break;
        default:
            // perform the conversion synchronously
            status = [self _convertAsset:asset
                                  outURL:[NSURL fileURLWithPath:dest]
                                metadata:metadata
                              outputType:AVFileTypeAppleM4A
                               timeRange:timeRange];
            break;
    }

    return (status == AVAssetExportSessionStatusCompleted);
}

@end
