//
//  HeadlineView.h
//  myLeague
//
//  Created by Brandon Hafenrichter on 7/15/15.
//  Copyright © 2015 Brandon Hafenrichter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeadlineView : UIView
@property (nonatomic, weak) IBOutlet UILabel *headline;
@property (nonatomic, weak) IBOutlet UIImageView *headlineImage;

+ (id)customView;
@end
