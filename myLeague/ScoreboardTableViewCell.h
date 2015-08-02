//
//  ScoreboardTableViewCell.h
//  myLeague
//
//  Created by Brandon Hafenrichter on 8/1/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreboardTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userScore;
@property (weak, nonatomic) IBOutlet UIImageView *opponentImage;
@property (weak, nonatomic) IBOutlet UILabel *opponentName;
@property (weak, nonatomic) IBOutlet UILabel *opponentScore;
@property (weak, nonatomic) IBOutlet UILabel *headline;

@end
