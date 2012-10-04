#import "GRiTunesMP4Utilities.h"

#import <AVFoundation/AVFoundation.h>
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

+ (NSDictionary*)_metadataForAsset:(AVAsset*)asset
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];

    // scan common metadata keys
    NSArray* commonMetadata = asset.commonMetadata;
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

+ (AVAssetExportSessionStatus)_convertFile:(NSURL*)srcURL
                                    outURL:(NSURL*)outURL
                                outputType:(NSString*)outputType
                                  metadata:(NSDictionary**)mdout
{
    AVAssetExportSession* session;
    NSString* preset = AVAssetExportPresetAppleM4A;
    AVURLAsset* asset = [AVURLAsset assetWithURL:srcURL];
    session = [AVAssetExportSession exportSessionWithAsset:asset 
                                                presetName:preset];

    // if this device cannot produce M4A files, the conversion
    // cannot continue
    if (![self _fileOutput:outputType supportedForSession:session])
        return AVAssetExportSessionStatusFailed;

    session.outputFileType = AVFileTypeAppleM4A;
    session.outputURL = outURL;
    session.metadata = [self _translatedMetadataKeysForAsset:asset];

    NSConditionLock* convLock = [[NSConditionLock alloc] initWithCondition:0];
    [session exportAsynchronouslyWithCompletionHandler:^{
        [convLock lock];
        [convLock unlockWithCondition:1];
    }];

    [convLock lockWhenCondition:1];
    [convLock unlock];
    [convLock release];

    if (mdout != NULL)
        *mdout = [self _metadataForAsset:asset];

    return [session status];
}

+ (BOOL)convertFileToM4A:(NSString*)src 
                    dest:(NSString*)dest
                metadata:(NSDictionary**)mdout
                   error:(NSError**)error
{
    NSFileManager* fm = [NSFileManager defaultManager]; 
    [fm removeItemAtPath:dest error:nil];

    NSURL* srcURL = [NSURL fileURLWithPath:src];
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
        case kAudioFileM4AType:
        case kAudioFileMPEG4Type:
            // if the file is already mpeg-4, don't convert
            // instead, just copy file to output path
            if ([fm copyItemAtPath:src
                            toPath:dest
                             error:error] == YES) {
                // copy failed, import cannot continue
                status = AVAssetExportSessionStatusCompleted;

                // now get the file metadata if the user needs it
                if (mdout != NULL) {
                    NSURL* destURL = [NSURL fileURLWithPath:dest];
                    AVAsset* asset = [AVAsset assetWithURL:destURL];
                    *mdout = [self _metadataForAsset:asset];
                }
            }
            break;
        default: {
            // perform the conversion synchronously
            status = [self _convertFile:srcURL
                                 outURL:[NSURL fileURLWithPath:dest]
                             outputType:AVFileTypeAppleM4A
                               metadata:mdout];
        } break;
    }

    return (status == AVAssetExportSessionStatusCompleted);
}

@end
