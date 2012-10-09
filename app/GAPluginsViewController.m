//
//  GAPluginsViewController.m
//  GremlinApp
//
//  Created by Youssef Francis on 10/9/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

#import "GAPluginsViewController.h"
#import "GAPluginsListViewController.h"

@interface GAPluginsViewController ()

@end

@implementation GAPluginsViewController

- (id)init
{
    self = [super init];
    if (self) {
        GAPluginsListViewController* pluginList;
        pluginList = [[GAPluginsListViewController alloc] init];
        [self pushViewController:pluginList animated:NO];
        [pluginList release];
        
        self.tabBarItem.image = [UIImage imageNamed:@"Plugins"];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient
{
    return YES;
}

@end
