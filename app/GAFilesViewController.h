//
//  PSFilePickerController.h
//  PSFilePickerController
//
//  Created by Josh Kugelmann on 18/08/12.
//  Copyright (c) 2012 Josh Kugelmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAFilesDelegate.h"

@interface GAFilesViewController : UINavigationController {
    NSString* _rootDirectory;
    NSString* _prompt;
}

@property (nonatomic, assign) id<UINavigationControllerDelegate, GAFilesDelegate> delegate;
@property (nonatomic, copy) NSString* rootDirectory;
@property (nonatomic, copy) NSString* prompt;

- (id)initWithRootDirectory:(NSString*)directory;

@end
