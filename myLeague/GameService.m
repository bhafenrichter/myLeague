//
//  GameService.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 7/26/15.
//  Copyright © 2015 Brandon Hafenrichter. All rights reserved.
//

#import "GameService.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@implementation GameService

+(NSArray*) GetPreviousGames:(PFObject *)user1 :(PFObject *)user2 {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(userID = %@ AND opponentID = %@) OR (userID = %@ AND opponentID = %@)", [user1 objectForKey:@"UserID"], [user2 objectForKey:@"UserID"], [user2 objectForKey:@"UserID"], [user1 objectForKey:@"UserID"]];
    PFQuery *query = [PFQuery queryWithClassName:@"Game" predicate:predicate];
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    [query whereKey:@"LeagueID" containsString:ap.selectedLeague.leagueId];
    [query orderByDescending:@"updatedAt"];
    return [query findObjects];
}

@end
