//
//  GAActivityViewController.h
//  Gremlin
//
//  Created by Ian on 11/1/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GAActivityViewController : UITableViewController {
    NSDictionary *importKindDictionary;
    NSDictionary *iconDictionary;
    NSArray *activeTasks;
}
- (void)manifestTasksUpdated:(NSArray*)tasks;
- (void)manifestServerReset;

- (void)didResignActive;
@end
