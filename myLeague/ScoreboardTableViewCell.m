//
//  ScoreboardTableViewCell.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 8/1/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "ScoreboardTableViewCell.h"

@implementation ScoreboardTableViewCell

@synthesize userImage = _userImage;
@synthesize userName = _userName;
@synthesize userScore = _userScore;

@synthesize opponentImage = _opponentImage;
@synthesize opponentName = _opponentName;
@synthesize opponentScore = _opponentScore;

@synthesize headline = _headline;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
