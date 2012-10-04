#import "GRImporterProtocol.h"

@class PLAssetsSaver;
@interface PLAssetsSaver
+ (id)sharedAssetsSaver;
- (void)_saveVideoAtPath:(NSString*)path 
              properties:(NSDictionary*)props 
         completionBlock:(void(^)(void))block;
@end

@interface GRVideoImporter : NSObject <GRImporter>
@end

@implementation GRVideoImporter

+ (GRImportOperationBlock)newImportBlock
{
    return Block_copy(^(NSDictionary* info, NSError** err)
    {
        __block BOOL success = NO;
        NSConditionLock* cond = [[NSConditionLock alloc] initWithCondition:0];

        @try {
            // Perform the import
            NSString* path = [info objectForKey:@"path"];
            [[PLAssetsSaver sharedAssetsSaver] _saveVideoAtPath:path
                                                     properties:nil
                                                completionBlock:^{
                [cond lock];
                success = YES;
                [cond unlockWithCondition:1];
            }];
        }
        @catch (NSException* e) {
            [cond lock];
            [cond unlockWithCondition:1];
        }

        [cond lockWhenCondition:1];
        [cond unlock];
        [cond release];
        
        return success;
    });
}

@end
