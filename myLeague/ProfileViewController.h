//
//  ProfileViewController.h
//  myLeague
//
//  Created by Brandon Hafenrichter on 6/21/15.
//  Copyright © 2015 Brandon Hafenrichter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property PFObject *user;
@end
