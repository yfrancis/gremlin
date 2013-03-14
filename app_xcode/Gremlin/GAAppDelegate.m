//
//  GAAppDelegate.m
//  Gremlin
//
//  Created by Ian on 11/1/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

#import "GAAppDelegate.h"


@implementation GAAppDelegate

- (void)manifestTasksUpdated:(NSArray*)tasks
{
    [activityViewController manifestTasksUpdated:tasks];
    [historyViewController update];
}
- (void)manifestServerReset
{
    
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}
#define AD_URL @"http://s3.amazonaws.com/www.cocoanuts.co/gremlin/gremlin-ads.html" //@"http://www.cocoanuts.co/gremlin/gremlin-ads.html"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    activityViewController = [[[GAActivityViewController alloc] initWithNibName:@"GAActivityViewController" bundle:nil] autorelease];
    historyViewController = [[[GAHistoryViewController alloc] initWithNibName:@"GAHistoryViewController" bundle:nil] autorelease];
    UIViewController *pluginsController = [[[GAPluginsListViewController alloc] initWithNibName:@"GAPluginsListViewController" bundle:nil] autorelease];
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = @[activityViewController, historyViewController, pluginsController];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    CGRect adFrame = CGRectMake(0,self.tabBarController.view.frame.size.height-44-54,self.tabBarController.view.frame.size.width, 44);
    adWebView = [[UIWebView alloc] initWithFrame:adFrame];
    adWebView.scrollView.scrollEnabled = NO;
    adWebView.delegate = self;
    adWebView.scalesPageToFit = YES;
    [self.tabBarController.view addSubview:adWebView];
    
    [adWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:AD_URL]]];
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(adWebView.frame.size.width-25, -5, 24,24)];
    [closeButton setImage:[UIImage imageNamed:@"x"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAdView:) forControlEvents:UIControlEventTouchUpInside];
    [adWebView addSubview:closeButton];
    [closeButton release];
    [adWebView release];
    return YES;
}
- (void)closeAdView:(UIControl *)sender
{
    [adWebView setHidden:YES];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlStr = [[request URL] absoluteString];
    NSLog(@"Load?: %@", urlStr);
    if ([[[request URL] absoluteString] isEqualToString:AD_URL] || [urlStr rangeOfString:@"smaato"].location != NSNotFound)
    {
        return YES;
    }
    [[UIApplication sharedApplication] openURL:[request URL]];
    return NO;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [adWebView setHidden:YES];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    [GRManifestListener stopListening];
    [activityViewController didResignActive];
    [historyViewController didResignActive];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // show the ad view 1 in 5 times
    long rand = random();
    if (rand % 5 == 0) {
        [adWebView setHidden:NO];
    }
    
    [GRManifestListener startListening:self];
    [historyViewController update];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [GRManifestListener stopListening];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
