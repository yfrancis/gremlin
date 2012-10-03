/*
 *  Created by Youssef Francis on September 25th, 2012.
 */

#import "GRImporterProtocol.h"

@interface @@PROJECTNAME@@ : NSObject <GRImporter>
@end

@implementation @@PROJECTNAME@@

/*
 * Generate a Block that will perform the import operation.
 *
 * @discussion
 *      You are not to do any of the actual importing here, instead you should
 *      generate a GRImportOperationBlock containing the import logic and
 *      return it. Gremlin will take care of scheduling the import task for
 *      execution, as well as informing the user of the import result.
 *
 *      The import block takes 2 arguments:
 *
 *      @param info NSDictionary* containing at least the following metadata:
 *          - "path" -> (NSString) full path to file to import
 *          - "name" -> (NSString) human-readable short name for the file
 *          - "type" -> (NSString) universal type identifier for the file
 *
 *      @param error NSError** containing reference to an NSError variable
 *          to be filled in case an error is encountered. This param is
 *          guaranteed to be non-NULL; however, error info is not always
 *          available so use of this variable is not required
 *      
 *      N.B. This method is not expected to return until the import process has
 *      completed (whether successfully or otherwise). Your import block
 *      should return YES if an import was successful, or NO if it failed
 *      for some reason. In many cases imports are performed asynchronously,
 *      if a completionBlock is available, you should wait until it is called
 *      before returning. Otherwise, you can optimistically assume the import
 *      was successful and return YES to gremlin.
 *
 *
 * @return a Block containing the import logic
 *
 */
+ (GRImportOperationBlock)newImportBlock
{
    return Block_copy(^(NSDictionary* info, NSError** error)
    {
        BOOL success = NO;
        // perform the import
        
        // return status
        return success;
    });
}

@end

// vim:ft=objc
