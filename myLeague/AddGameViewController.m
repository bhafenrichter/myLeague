//
//  AddGameViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 5/30/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "AddGameViewController.h"

#import <Parse/Parse.h>
#import "League.h"
#import "AppDelegate.h"
#import "User.h"
#import "SearchLeagueTableViewController.h"

@interface AddGameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *DateDay;
@property (weak, nonatomic) IBOutlet UILabel *DateTime;

@property League *league;
@end

@implementation AddGameViewController
- (IBAction)cancelAddGame:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//called every time the UI is loaded
-(void) viewDidAppear:(BOOL)animated {
    if(self.opponent != nil){
        self.opponentNameLabel.text = [NSString stringWithFormat:@"%@. %@", [self.opponent.firstName substringToIndex:1], self.opponent.lastName];
    }
    
}

//called once 
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMap];
    
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    self.league = ap.selectedLeague;
    self.userNameLabel.text =[NSString stringWithFormat:@"%@. %@", [ap.user.firstName substringToIndex:1], ap.user.lastName];
    if(self.opponent != nil){
        self.opponentNameLabel.text = [NSString stringWithFormat:@"%@. %@", [self.opponent.firstName substringToIndex:1], self.opponent.lastName];
    }
    
    NSDate *localDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/yy";
    self.DateDay.text = [dateFormatter stringFromDate: localDate];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    
    
    self.DateTime.text = [timeFormatter stringFromDate: localDate];
    
    // Do any additional setup after loading the view.
}

-(void)sendDataToAddGame:(User*)selectedUser{
    self.opponent = selectedUser;
}

-(void) setupMap{
    CLLocationCoordinate2D location = [[[self.gameMapView userLocation] location] coordinate];
    
}
- (IBAction)submitGame:(id)sender {
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    
    PFObject *game = [PFObject objectWithClassName:@"Game"];
    game[@"LeagueID"] = self.league.leagueId;
    game[@"userID"] = ap.user.userID;
    game[@"opponentID"] = self.opponent.userID;
    game[@"userScore"] = self.userScore.text;
    game[@"opponentScore"] = self.opponentScore.text;
    game[@"userComments"] = self.userComments.text;
    game[@"opponentComments"] = @"";
    //[game setValue:@"location" forKey:@""];
    
    [game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Saved.");
            [self updateUsers];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

-(void) updateUsers {
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    
    //increment user
    PFQuery *query = [PFQuery queryWithClassName:@"UserLeague"];
    [query whereKey:@"UserID" containsString:ap.user.userID];
    [query whereKey:@"LeagueID" containsString:self.league.leagueId];
    PFObject *user = [query getFirstObject];
    if(self.userScore.text.intValue > self.opponentScore.text.intValue){
        NSString *userWins = user[@"Wins"];
        int wins = userWins.intValue;
        wins++;
        user[@"Wins"] = [NSString stringWithFormat:@"%d",wins];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if(succeeded){
                PFQuery *opponentQuery = [PFQuery queryWithClassName:@"UserLeague"];
                [opponentQuery whereKey:@"UserID" containsString:self.opponent.userID];
                [opponentQuery whereKey:@"LeagueID" containsString:self.league.leagueId];
                PFObject *opponent = [opponentQuery getFirstObject];
                NSString *opponentLosses = opponent[@"Losses"];
                int losses = opponentLosses.intValue;
                losses++;
                opponent[@"Losses"] = [NSString stringWithFormat:@"%d",losses];
                [opponent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if(!error){
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
                
            }
        }];
    }else{
        NSString *userLosses = user[@"Losses"];
        int wins = userLosses.intValue;
        wins++;
        user[@"Losses"] = [NSString stringWithFormat:@"%d",wins];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if(succeeded){
                PFQuery *opponentQuery = [PFQuery queryWithClassName:@"UserLeague"];
                [opponentQuery whereKey:@"UserID" containsString:self.opponent.userID];
                [opponentQuery whereKey:@"LeagueID" containsString:self.league.leagueId];
                PFObject *opponent = [opponentQuery getFirstObject];
                NSString *opponentWins = opponent[@"Wins"];
                int wins = opponentWins.intValue;
                wins++;
                opponent[@"Losses"] = [NSString stringWithFormat:@"%d",wins];
                [opponent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if(!error){
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }
        }];
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if ([touch view] == self.opponentPicture)
    {
        //add your code for image touch here
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        
        SearchLeagueTableViewController *acontrollerobject = (SearchLeagueTableViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"SearchLeagueTableViewController"];
        acontrollerobject.delegate = self; // protocol listener
        [self.navigationController pushViewController:acontrollerobject animated:YES];
    }
    
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
