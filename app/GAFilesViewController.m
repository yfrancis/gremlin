//
//  PSFilePickerController.m
//  PSFilePickerController
//
//  Created by Josh Kugelmann on 18/08/12.
//  Copyright (c) 2012 Josh Kugelmann. All rights reserved.
//

#import "GAFilesViewController.h"
#import "GAFilesListViewController.h"

@implementation GAFilesViewController

@synthesize rootDirectory = _rootDirectory;
@synthesize prompt = _prompt;

- (id)init
{
    // If no root directory is specified, default to the home dir   
    self = [self initWithRootDirectory:NSHomeDirectory()];
    
    return self;
}

- (id)initWithRootDirectory:(NSString *)directory
{
    self = [super init];
    
    if (self) {
        _rootDirectory = [directory copy];

        // Set up the inital directory list.
        GAFilesListViewController* directoryList;
        directoryList = [[GAFilesListViewController alloc]
                            initWithDirectoryAtPath:_rootDirectory];
        [self pushViewController:directoryList animated:NO];
        [directoryList release];

        self.title = NSLocalizedString(@"Files", @"Files");
        self.tabBarItem.image = [UIImage imageNamed:@"Files"];
    }
    
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient
{
    return YES;
}

- (void)dealloc
{
    [_rootDirectory release];
    [super dealloc];
}

@end
