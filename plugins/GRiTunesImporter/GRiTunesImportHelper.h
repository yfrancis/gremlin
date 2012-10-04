/*
 *  Created by Youssef Francis on October 3rd, 2012.
 */

@interface GRiTunesImportHelper

+ (BOOL)importAudioFileAtPath:(NSString*)path
				 withMetadata:(NSDictionary*)info;

@end