//
//  LeagueSettingsViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 9/7/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "LeagueSettingsViewController.h"
#import "UserService.h"
#import "LeagueService.h"
#import "AppDelegate.h"
#import "League.h"

@interface LeagueSettingsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *leagueImage;
@property (weak, nonatomic) IBOutlet UITextField *leagueName;
@property (weak, nonatomic) IBOutlet UITextField *leagueType;
@end

@implementation LeagueSettingsViewController
- (IBAction)leaveLeague:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"League Alert" message:@"Are you sure you want to leave this league?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [alert show];
}

- (IBAction)saveChanges:(id)sender {
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    League *myLeague = [[League alloc]init];
    
    myLeague.leagueId = ap.selectedLeague.leagueId;
    myLeague.leagueName = self.leagueName.text;
    myLeague.leagueType = self.leagueType.text;
    //TODO: add league url
    
    if([LeagueService SaveLeague: myLeague]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) { // Set buttonIndex == 0 to handel "Ok"/"Yes" button response
        AppDelegate *ap = [[UIApplication sharedApplication] delegate];
        [UserService RemoveUser:ap.user.userID: ap.selectedLeague.leagueId];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self populateUI];
}

#define batQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
-(void) populateUI{
    dispatch_async(batQueue, ^{
        AppDelegate *ap = [[UIApplication sharedApplication] delegate];
        self.leagueName.text = ap.selectedLeague.leagueName;
        self.leagueType.text = ap.selectedLeague.leagueType;
        
        UIImage *leagueImage = [UserService GetUserPicture:ap.selectedLeague.leagueUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.leagueImage.image = leagueImage;
        });
    });
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
