//
//  CreateLeagueViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 6/1/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "CreateLeagueViewController.h"
#import <Parse/Parse.h>
#import "League.h"
#import "AppDelegate.h"
#import "LeagueService.h"

@interface CreateLeagueViewController ()

@property (weak, nonatomic) IBOutlet UITextField *leagueName;
@property (weak, nonatomic) IBOutlet UITextField *leagueType;
@property (weak, nonatomic) IBOutlet UISwitch *isPrivateSwitch;


@end

@implementation CreateLeagueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)createLeague:(id)sender {
    if([self.leagueName.text length] > 0 && [self.leagueType.text length] > 0){
        //create league
        PFObject *league = [PFObject objectWithClassName:@"League"];
        league[@"LeagueName"] = self.leagueName.text;
        league[@"LeagueType"] = self.leagueType.text;
        league[@"GameCount"] = @(0);
        
        bool success = [LeagueService CreateLeague: league];
        
             if(!success){
                 AppDelegate *ap = [[UIApplication sharedApplication] delegate];
                 
                 //add user to league
                 PFObject *userLeague = [PFObject objectWithClassName:@"UserLeague"];
                 userLeague[@"UserID"] = ap.user.userID;
                 userLeague[@"LeagueID"] = [league objectId];
                 userLeague[@"ShortName"] = [NSString stringWithFormat:@"%@. %@", [ap.user.firstName substringToIndex:1], ap.user.lastName];
                 userLeague[@"Wins"] = @"0";
                 userLeague[@"PointsAllowed"] = @"0";
                 userLeague[@"PointsScored"] = @"0";
                 userLeague[@"Losses"] = @"0";
                 userLeague[@"IsDeleted"] = [NSNumber numberWithBool:NO];
                 userLeague[@"ProfilePictureUrl"] = ap.user.profilePictureUrl;
                 [userLeague saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                     if(!error){
                         NSLog(@"Assigned user %@ to %@", ap.user.userID, [league objectForKey:@"LeagueName"]);
                         League *selected = [[League alloc]init];
                         selected.leagueId = [league objectId];
                         selected.leagueName = [league objectForKey:@"LeagueName"];
                         selected.leagueMotto = [league objectForKey:@"LeagueMotto"];
                         selected.leagueType = [league objectForKey:@"LeagueType"];
                         
                         ap.selectedLeague = selected;
                         
                         [self.navigationController popViewControllerAnimated:YES];

                     }else{
                         NSLog(@"Error Creating League");
                     }
                 }];
             }
    }else{
        //don't create league
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
