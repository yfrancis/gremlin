//
//  GAActivityViewController.m
//  GremlinApp
//
//  Created by Youssef Francis on 10/9/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

#import "GAActivityViewController.h"
#import "GAActivityListViewController.h"

@interface GAActivityViewController ()

@end

@implementation GAActivityViewController

- (id)init
{
    self = [super init];
    if (self) {
        GAActivityListViewController* activityList;
        activityList = [[GAActivityListViewController alloc] init];
        [self pushViewController:activityList animated:NO];
        [activityList release];
        
        self.tabBarItem.image = [UIImage imageNamed:@"Activity"];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient
{
    return YES;
}

@end
