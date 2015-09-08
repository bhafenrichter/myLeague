//
//  LeagueService.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 9/3/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "LeagueService.h"
#import <Parse/Parse.h>
@implementation LeagueService
+(BOOL) CreateLeague:(PFObject *)league{
    PFObject *l = [PFObject objectWithClassName:@"League"];
    l[@"LeagueName"] = [league objectForKey:@"LeagueName"];
    l[@"LeagueType"] = [league objectForKey:@"LeagueType"];
    l[@"GameCount"] = @([[league objectForKey:@"GameCount"] intValue]);
    return [l save];
}

+(BOOL) GetLeagueRequestsCount:(NSString *)userId{
    PFQuery *query = [PFQuery queryWithClassName:@"LeagueRequests"];
    [query whereKey:@"InviteeID" containsString:userId];
    return [query countObjects];
}

+(BOOL) SaveLeague:(League *)myLeague{
    PFQuery *query = [PFQuery queryWithClassName:@"League"];
    PFObject *league = [query getObjectWithId:myLeague.leagueId];
    league[@"LeagueName"] = myLeague.leagueName;
    league[@"LeagueType"] = myLeague.leagueType;
    //TODO: IMPLEMENT URL
    return [league save];
}
@end
