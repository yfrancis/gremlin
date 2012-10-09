//
//  PSDirectoryPickerDelegate.h
//  PSFilePickerController
//
//  Created by Josh Kugelmann on 26/08/12.
//  Copyright (c) 2012 Josh Kugelmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GAFilesController;

@protocol GAFilesDelegate <UINavigationControllerDelegate>

@optional
- (void)directoryPickerController:(GAFilesController *)picker didFinishPickingDirectoryAtPath:(NSString *)path;
- (void)directoryPickerControllerDidCancel:(GAFilesController *)picker;

@end
