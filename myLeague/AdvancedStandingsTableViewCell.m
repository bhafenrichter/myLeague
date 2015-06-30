//
//  AdvancedStandingsTableViewCell.m
//  
//
//  Created by Brandon Hafenrichter on 6/30/15.
//
//

#import "AdvancedStandingsTableViewCell.h"

@implementation AdvancedStandingsTableViewCell
@synthesize nameLabel = _nameLabel;
@synthesize winsLabel = _winsLabel;
@synthesize lossesLabel = _lossesLabel;
@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize PPGLabel = _PPG;
@synthesize PALabel = _PA;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
