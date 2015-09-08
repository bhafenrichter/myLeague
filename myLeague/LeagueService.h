//
//  LeagueService.h
//  myLeague
//
//  Created by Brandon Hafenrichter on 9/3/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "League.h"
#import <Parse/Parse.h>

@interface LeagueService : NSObject
+(bool) CreateLeague: (PFObject *) league;
+(bool) GetLeagueRequestsCount: (NSString *) userId;
+(bool) SaveLeague: (League *) myLeague;
@end
