#import "GRImporterProtocol.h"

#import <MobileCoreServices/LSApplicationWorkspace.h>
#import <MobileCoreServices/LSApplicationProxy.h>
#import <MobileCoreServices/LSDocumentProxy.h>
#import <MobileCoreServices/LSOpenOperation.h>

@interface GRDocumentImporter : NSObject <GRImporter>
@end

@implementation GRDocumentImporter

+ (GRImportOperationBlock)newImportBlock
{
    return Block_copy(^(NSDictionary* info, NSError** err)
    {
        // Perform the import
        NSString* path = [info objectForKey:@"path"];
        NSURL* url = [NSURL fileURLWithPath:path];

        NSString* type = [info objectForKey:@"UTType"];

        // Get default application
        LSDocumentProxy* doc = [[LSDocumentProxy alloc] initWithName:path
                                                                type:type
                                                            MIMEType:nil];

        NSArray* apps = [[LSApplicationWorkspace defaultWorkspace]
                            applicationsAvailableForOpeningDocument:doc];
        [doc release];

        if (apps.count == 0) {
            if (err != NULL)
                *err = [NSError errorWithDomain:@"gremlin.plugin.import"
                                           code:404
                                       userInfo:info];
            return NO;
        }

        LSApplicationProxy* defaultApp = [apps objectAtIndex:0];
        NSString* appIdentifier = [defaultApp applicationIdentifier];

        NSDictionary* uinf;
        uinf = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                           forKey:@"GRDocumentImport"];
        
        LSOpenOperation* op;
        Class LSOpenOperation_ = objc_getClass("LSOpenOperation"); 
        op = [[LSOpenOperation_ alloc] initForOpeningResource:url
                                             usingApplication:appIdentifier
                                     uniqueDocumentIdentifier:nil
                                                     userInfo:uinf
                                                     delegate:nil];
       
        NSConditionLock* cond = [[NSConditionLock alloc] initWithCondition:0];

        __block BOOL success = NO;
        [op setCompletionBlock:^{
            success = YES;
            [cond lock];
            [cond unlockWithCondition:1];
        }];
        
        [op start];
        
        [cond lockWhenCondition:1];
        [cond unlock];
        [cond release];

        return success;
    });
}

@end

// vim:ft=objc
