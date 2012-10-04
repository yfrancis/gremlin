/*
 * Created by Youssef Francis on October 3rd, 2012.
 */

@interface GRiTunesMP4Utilities

+ (BOOL)convertFileToM4A:(NSString*)src
                    dest:(NSString*)dest
                metadata:(NSDictionary**)mdout
                   error:(NSError**)error;

@end