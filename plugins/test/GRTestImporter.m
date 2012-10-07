#import "GRImporterProtocol.h"

@interface GRTestImporter : NSObject <GRImporter>
@end

@implementation GRTestImporter

+ (GRImportOperationBlock)newImportBlock
{
    return Block_copy(^(NSDictionary* info, NSError** err)
    {
        BOOL success = [[info objectForKey:@"success"] boolValue];

        return success;
    });
}

@end

// vim:ft=objc
