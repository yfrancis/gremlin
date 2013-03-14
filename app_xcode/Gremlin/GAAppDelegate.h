//
//  GAAppDelegate.h
//  Gremlin
//
//  Created by Ian on 11/1/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAActivityViewController.h"
#import "GAHistoryViewController.h"
#import "GAPluginsListViewController.h"
#import <Gremlin/GRManifestListener.h>
@interface GAAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, GRManifestListenerDelegate, UIWebViewDelegate> {
    GAActivityViewController *activityViewController;
    GAHistoryViewController *historyViewController;
    
    UIWebView *adWebView;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

- (void)manifestTasksUpdated:(NSArray*)tasks;
- (void)manifestServerReset;
@end
