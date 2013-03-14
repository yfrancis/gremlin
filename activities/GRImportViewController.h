//
//  GRImportViewController.h
//  Gremlin
//
//  Created by Nicolas Haunold on 3/8/13.
//  Copyright (c) 2013 Nicolas Haunold. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GRImportViewControllerCompletionBlock)(BOOL hasBeenCanceled);

@interface GRImportViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) GRImportViewControllerCompletionBlock completionBlock;
@property (nonatomic, assign) BOOL showKindSelector;

+ (NSDictionary*)humanizedMediaKinds;
- (id)initWithDictionary:(NSDictionary*)importDict completion:(GRImportViewControllerCompletionBlock)completion;

@end
