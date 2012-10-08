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
    NSArray* sourceMetadata = [asset commonMetadata];
    for (AVMutableMetadataItem* mdi in sourceMetadata) {
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

    return sourceMetadata;
}

+ (AVAssetExportSessionStatus)_convertAsset:(AVAsset*)asset
                                     outURL:(NSURL*)outURL
                                 outputType:(NSString*)outputType
                                      range:(NSRange)range
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
    session.metadata = [self _translatedMetadataKeysForAsset:asset];

    if (NSMaxRange(range) > 0) {
        CMTime startTime = CMTimeMake((int64_t)floor(range.location), 1);
        CMTime duration = CMTimeMake((int64_t)ceil(range.length), 1);
        session.timeRange = CMTimeRangeMake(startTime, duration);

        // create 500ms fade
        CMTime fadeTime = CMTimeMake((int64_t)1, 3);
        
        // set up fade in
        CMTime startFadeInTime = startTime;
        CMTime endFadeInTime = CMTimeAdd(startFadeInTime, fadeTime);

        CMTimeRange fadeInTimeRange;
        fadeInTimeRange = CMTimeRangeFromTimeToTime(startFadeInTime,
                                                    endFadeInTime);

        // set up fade out
        CMTime endFadeOutTime = CMTimeAdd(startTime, duration);
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
        CMTime fst_ = CMTimeSubtract(startTime, CMTimeMakeWithSeconds(1, 1000));
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
    [tracks enumerateObjectsUsingBlock:^(AVAssetTrack* track,
                                         NSUInteger idx,
                                         BOOL* stop) {
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
               range:(NSRange)range
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
        //case kAudioFileM4AType:
        //case kAudioFileMPEG4Type:
            // first check if the original asset is a video,
            // because we will have to demux it
            //if ([self _assetIsVideo:asset] == NO) { 
                // if the file is already mpeg-4, don't convert
                // instead, just copy file to output path
                //if ([fm copyItemAtURL:srcURL
                //                toURL:[NSURL fileURLWithPath:dest]
                //                error:error] == YES) {
                //    status = AVAssetExportSessionStatusCompleted;
                //}
                //break;
            //}
            // if the asset is a video, continue to default case
        default:
            // perform the conversion synchronously
            status = [self _convertAsset:asset
                                  outURL:[NSURL fileURLWithPath:dest]
                              outputType:AVFileTypeAppleM4A
                                   range:range];
            break;
    }

    return (status == AVAssetExportSessionStatusCompleted);
}

@end
