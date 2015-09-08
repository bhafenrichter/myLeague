//
//  UserService.h
//  myLeague
//
//  Created by Brandon Hafenrichter on 7/26/15.
//  Copyright © 2015 Brandon Hafenrichter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "League.h"
#import "User.h"

@interface UserService : NSObject
+(PFObject*) GetUserBriefWithId: (NSString*) userId: (NSString*) leagueId;
+(UIImage*) GetUserPicture: (NSString*) profilePictureUrl;
+(NSArray*) GetAllUsers;
+(void) SendLeagueRequest: (NSString*) userId: (PFObject*) sender: (League*) leagueId;
+(BOOL) RemoveUser: (NSString*) userId: (NSString*) leagueId;
@end
