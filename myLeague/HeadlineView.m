//
//  HeadlineView.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 7/15/15.
//  Copyright © 2015 Brandon Hafenrichter. All rights reserved.
//

#import "HeadlineView.h"

@implementation HeadlineView
@synthesize headline = _headline;
@synthesize headlineImage = _headlineImage;

- (void)awakeFromNib {
    // Initialization code
}

+ (id)customView
{
    HeadlineView *headlineView = [[[NSBundle mainBundle] loadNibNamed:@"HeadlineView" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([headlineView isKindOfClass:[HeadlineView class]])
        return headlineView;
    else
        return nil;
}
@end
