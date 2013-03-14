//
//  GAActivityViewController.h
//  Gremlin
//
//  Created by Ian on 11/1/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GAHistoryViewController : UITableViewController {
    NSDictionary *importKindDictionary;
    NSDictionary *iconDictionary;
    NSArray *history;
}
- (void)didBecomeActive;
- (void)didResignActive;
- (void)update;
@end
