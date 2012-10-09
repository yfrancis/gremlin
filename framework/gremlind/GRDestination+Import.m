/*
 * Created by Youssef Francis on October 10th, 2012.
 */

#import "GRDestination+Import.h"

@implementation GRDestination (Import)

- (Class<GRImporter>)importerClass
{
    Class Importer = [self.bundle principalClass];
    if ([Importer conformsToProtocol:@protocol(GRImporter)] &&
        [Importer respondsToSelector:@selector(newImportBlock)])
        return (Class<GRImporter>)Importer;
    else
        return Nil;
}

@end
