//
//  AppDelegate.h
//  myLeague
//
//  Created by Brandon Hafenrichter on 5/14/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "League.h"
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) League *selectedLeague;
@property (strong, nonatomic) User *user;
@end

