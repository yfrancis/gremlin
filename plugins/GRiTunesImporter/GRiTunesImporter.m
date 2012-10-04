/*
 *  Created by Youssef Francis on September 25th, 2012.
 */

#import "GRImporterProtocol.h"
#import "GRiTunesImportHelper.h"
#import "GRiTunesMP4Utilities.h"

@interface GRiTunesImporter : NSObject <GRImporter>
@end

@implementation GRiTunesImporter

+ (NSString*)makeTemporaryDirectory
{
    NSString* tmplStr;
    NSString* mkdstr = @"gremlin.XXXXXX";
    tmplStr = [NSTemporaryDirectory() stringByAppendingPathComponent:mkdstr];

    const char *tmplCstr = [tmplStr fileSystemRepresentation];
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

+ (GRImportOperationBlock)newImportBlock
{
    return Block_copy(^(NSDictionary* info, NSError** error)
    {
        NSString* ipath = [info objectForKey:@"path"];
        // create temp directory to house the processed file
        NSString* tempDir = [self makeTemporaryDirectory];

        // determine output path for conversion (or plain copy)
        NSString* filename;
        filename = [[ipath lastPathComponent] stringByDeletingPathExtension];
        NSString* opath = [[tempDir stringByAppendingPathComponent:filename]
                            stringByAppendingPathExtension:@"m4a"];

        // perform the conversion
        NSDictionary* metadata = nil;
        BOOL converted = [GRiTunesMP4Utilities convertFileToM4A:ipath
                                                           dest:opath
                                                       metadata:&metadata
                                                          error:error];

        // if conversion fails, the import cannot continue
        if (converted == NO)
            return NO;

        // return status
        return [GRiTunesImportHelper importAudioFileAtPath:opath
                                              withMetadata:metadata];
    });
}

@end

// vim:ft=objc
