#import "GRImporterProtocol.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#define NSDataReadingMappedAlways (1UL << 3)

@class PLAssetsSaver;
@interface PLAssetsSaver
+ (id)sharedAssetsSaver;
- (void)queueJobData:(id)d completionBlock:(void (^)(id,id))block;
@end

@interface GRPhotoImporter : NSObject <GRImporter>
@end

@implementation GRPhotoImporter

+ (GRImportOperationBlock)newImportBlock
{
    return Block_copy(^(NSDictionary* info, NSError** err)
    {
        @try {
            NSString* path = [info objectForKey:@"path"];
            CFStringRef utt = (CFStringRef)[info objectForKey:@"UTType"]; 
            
            NSData* imageData = nil;
            SEL mappedDataSel = @selector(dataWithContentsOfMappedFile:);
            if ([NSData respondsToSelector:mappedDataSel])
                imageData = [NSData dataWithContentsOfMappedFile:path];
            else {
                NSError *error = nil;
                NSDataReadingOptions readOptions = NSDataReadingMappedAlways;
                imageData = [NSData dataWithContentsOfFile:path 
                                                   options:readOptions
                                                     error:&error];
            }
            
            NSNumber* yes = [NSNumber numberWithBool:YES];
            NSString* jobType = @"ImageJob";
            NSNumber* assetType = [NSNumber numberWithInt:3];
            NSString* extension = [[path pathExtension] uppercaseString];
            NSMutableDictionary* job;
            job = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                yes,       @"CreatePreviewWellThumbnail",
                yes,       @"kPLImageWriterAddAssetToCameraRoll",
                yes,       @"kPLImageWriterPhotoStreamImageForPublishing",
                yes,       @"PLAssetsSaverNotifyForPictureWasTakenOrChanged",
                yes,       @"QueueEnforcement",
                assetType, @"kPLImageWriterSavedAssetTypeKey",
                extension, @"FileExtension",
                imageData, @"ImageData",
                jobType,   @"JobType",
                utt,       @"Type",
                nil];

            NSData* jobData = [NSKeyedArchiver archivedDataWithRootObject:job];
            [job release];
            
            NSConditionLock* cond;
            cond = [[NSConditionLock alloc] initWithCondition:0];
            
            __block BOOL success = NO;
            [[PLAssetsSaver sharedAssetsSaver] queueJobData:jobData
                                            completionBlock:^(id x1, id x2) 
            {
                // detect success/failure here somehow
                success = YES;
                [cond lock];
                [cond unlockWithCondition:1];
            }];

            [cond lockWhenCondition:1];
            [cond unlock];
            [cond release];

            return success;
        }
        @catch (...) {
            if (err != NULL)
                *err = [NSError errorWithDomain:@"gremlin.plugin.import"
                                           code:500
                                       userInfo:info];
            return NO;
        }
    });
}

@end
