#import "GRImporterProtocol.h"

#import <AddressBook/ABVCardParser.h>
#import <AddressBook/ABAddressBook.h>

typedef void* CPRecordRef;

@interface GRContactImporter : NSObject <GRImporter>
@end

@implementation GRContactImporter

+ (GRImportOperationBlock)newImportBlock
{
    return Block_copy(^(NSDictionary* info, NSError** err)
    {
        BOOL success = NO;
        ABAddressBookRef addressBook = NULL;

        @try {
            // Perform the import
            NSString* path = [info objectForKey:@"path"];
            NSData* data = [NSData dataWithContentsOfFile:path];
            ABVCardParser* parser = [[ABVCardParser alloc] initWithData:data];
            NSArray* people = [parser sortedPeopleAndProperties:nil];
            [parser release];

            addressBook = ABAddressBookCreate();

            for (id person in people)
                ABAddressBookAddRecord(addressBook,
                                       (CPRecordRef)person,
                                       NULL);
            
            ABAddressBookSave(addressBook, NULL);

            success = YES;
        }
        @catch (...) {
            // maybe try to pull out an error here or generate one?
            if (err != NULL)
                *err = [NSError errorWithDomain:@"gremlin.plugin.import"
                                           code:400
                                       userInfo:info];
        }
        @finally {
            if (addressBook != NULL) 
                CFRelease(addressBook);
        }

        return success;
    });
}

@end

// vim:ft=objc
