//
//  AdvancedStandingsTableViewCell.h
//  
//
//  Created by Brandon Hafenrichter on 6/30/15.
//
//

#import <UIKit/UIKit.h>

@interface AdvancedStandingsTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *winsLabel;
@property (nonatomic, weak) IBOutlet UILabel *lossesLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) IBOutlet UILabel *PPGLabel;
@property (nonatomic, weak) IBOutlet UILabel *PALabel;
@end
