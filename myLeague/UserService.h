//
//  UserService.h
//  myLeague
//
//  Created by Brandon Hafenrichter on 7/26/15.
//  Copyright © 2015 Brandon Hafenrichter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface UserService : NSObject
+(PFObject*) GetUserBriefWithId: (NSString*) userId: (NSString*) leagueId;
+(UIImage*) GetUserPicture: (NSString*) profilePictureUrl;
@end
