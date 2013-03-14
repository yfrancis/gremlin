//
//  GAActivityTableViewCell.h
//  Gremlin
//
//  Created by Ian on 11/1/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GAActivityTableViewCell : UITableViewCell {
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *kindLabel;
    IBOutlet UILabel *destinationLabel;
    IBOutlet UIImageView *iconView;
    IBOutlet UIActivityIndicatorView *spinner;
}
@property (readonly) IBOutlet UILabel *titleLabel;
@property (readonly) IBOutlet UILabel *kindLabel;
@property (readonly) IBOutlet UILabel *destinationLabel;
@property (readonly) IBOutlet UIImageView *iconView;
@property (readonly) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, assign) BOOL inProgress;
@end
