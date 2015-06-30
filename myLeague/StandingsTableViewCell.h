//
//  StandingsTableViewCell.h
//  myLeague
//
//  Created by Brandon Hafenrichter on 6/7/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StandingsTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *winsLabel;
@property (nonatomic, weak) IBOutlet UILabel *lossesLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;

@end
