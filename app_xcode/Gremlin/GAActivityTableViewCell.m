//
//  GAActivityTableViewCell.m
//  Gremlin
//
//  Created by Ian on 11/1/12.
//  Copyright (c) 2012 CocoaNuts. All rights reserved.
//

#import "GAActivityTableViewCell.h"

@implementation GAActivityTableViewCell
@synthesize titleLabel, kindLabel, destinationLabel, iconView, spinner;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setInProgress:(BOOL)inProgress {
    inProgress ? [self.spinner startAnimating] : [self.spinner stopAnimating];
}
@end
