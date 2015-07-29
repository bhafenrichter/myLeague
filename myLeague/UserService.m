//
//  UserService.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 7/26/15.
//  Copyright © 2015 Brandon Hafenrichter. All rights reserved.
//

#import "UserService.h"
#import <Parse/Parse.h>

@implementation UserService
+(PFObject*) GetUserBriefWithId:(NSString *)userId: (NSString *) leagueId{
    PFQuery *query = [PFQuery queryWithClassName:@"UserLeague"];
    [query whereKey:@"UserID" containsString:userId];
    [query whereKey:@"LeagueID" containsString:leagueId];
    return [query getFirstObject];
}

+(UIImage*) GetUserPicture:(NSString *)profilePictureUrl{
    NSURL * imageURL = [NSURL URLWithString:profilePictureUrl];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    return [UIImage imageWithData:imageData];
}
@end
