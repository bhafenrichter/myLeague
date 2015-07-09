//
//  NewsFeedViewController.h
//  myLeague
//
//  Created by Brandon Hafenrichter on 5/27/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "ViewController.h"
#import "League.h"

@interface NewsFeedViewController : ViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) League *league;
@property (retain, nonatomic) NSArray *members;
@end
