//
//  GAAppDelegate.h
//  GremlinApp
//
//  Created by Youssef Francis on 10/8/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GAAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
