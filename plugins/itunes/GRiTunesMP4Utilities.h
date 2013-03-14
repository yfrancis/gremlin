/*
 * Created by Youssef Francis on October 3rd, 2012.
 */

#import <AVFoundation/AVFoundation.h>

@interface GRiTunesMP4Utilities : NSObject

+ (BOOL)convertAsset:(AVURLAsset*)asset
                dest:(NSString*)dest
            metadata:(NSDictionary*)metadata
           timeRange:(CMTimeRange)timeRange
               error:(NSError**)error;

@end
