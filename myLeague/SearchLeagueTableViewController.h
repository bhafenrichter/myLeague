//
//  SearchLeagueTableViewController.h
//  myLeague
//
//  Created by Brandon Hafenrichter on 5/31/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "User.h"

@protocol senddataProtocol <NSObject>

@end

@interface SearchLeagueTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

//sends data back
@property(nonatomic,assign)id delegate;
@property NSMutableArray *members;
@end
