//
//  UserService.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 7/26/15.
//  Copyright © 2015 Brandon Hafenrichter. All rights reserved.
//

#import "UserService.h"
#import <Parse/Parse.h>
#import "League.h"

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

+(NSArray*) GetAllUsers{
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    return [query findObjects];
}

+(void) SendLeagueRequest:(NSString *)userId:(PFObject *) sender: (League *)league{
    
    PFObject *request = [[PFObject alloc] initWithClassName:@"LeagueRequest"];
    request[@"LeagueID"] = league.leagueId;
    request[@"InviteeUsername"] = [sender objectForKey:@"username"];
    request[@"InviteeID"] = userId;
    request[@"LeagueName"] = league.leagueName;
    request[@"SenderName"] = [NSString stringWithFormat:@"%@ %@", [sender objectForKey:@"firstName"], [sender  objectForKey:@"lastName"]];
    [request save];
}

+(BOOL) RemoveUser:(NSString *)userId: (NSString *) leagueId{
    PFQuery *query = [PFQuery queryWithClassName:@"UserLeague"];
    [query whereKey:@"LeagueID" containsString:leagueId];
    [query whereKey:@"UserID" containsString:userId];
    PFObject *user = [query getFirstObject];
    user[@"IsDeleted"] = [NSNumber numberWithBool:YES];
    return [user save];
}
@end
