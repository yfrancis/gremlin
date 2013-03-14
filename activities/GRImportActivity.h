#import <UIKit/UIKit.h>

@interface GRImportActivity : UIActivity

@property (nonatomic, retain) NSMutableArray* files;

- (void)addFileWithInfo:(NSDictionary*)info;

@end
