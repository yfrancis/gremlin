/*
 *  Created by Youssef Francis on October 3rd, 2012.
 */

@interface GRiTunesImportHelper : NSObject

+ (BOOL)importAudioFileAtPath:(NSString*)path
                    mediaKind:(NSString*)mediaKind
                 withMetadata:(NSDictionary*)info;

@end
