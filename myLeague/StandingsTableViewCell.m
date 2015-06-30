//
//  StandingsTableViewCell.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 6/7/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "StandingsTableViewCell.h"

@implementation StandingsTableViewCell
@synthesize nameLabel = _nameLabel;
@synthesize winsLabel = _winsLabel;
@synthesize lossesLabel = _lossesLabel;
@synthesize thumbnailImageView = _thumbnailImageView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
