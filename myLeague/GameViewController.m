//
//  GameViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 7/26/15.
//  Copyright © 2015 Brandon Hafenrichter. All rights reserved.
//

#import "GameViewController.h"
#import <Parse/Parse.h>
#import "GameService.h"
#import "UserService.h"

@interface GameViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userPictureView;
@property (weak, nonatomic) IBOutlet UIImageView *opponentPictureView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userRecordLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentRecordLabel;
@property (weak, nonatomic) IBOutlet UILabel *userScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentScoreLabel;
@property (weak, nonatomic) IBOutlet UITableView *previousMatchupsTable;
//@property (weak, nonatomic) IBOutlet MKMapView *gameLocationMapView;

@property PFObject *user;
@property PFObject *opponent;
@property NSArray *previousMatchups;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getUsersInformation];
}

#define braQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
-(void) getUsersInformation {
    dispatch_async(braQueue, ^{
        self.user = [UserService GetUserWithId:[self.game objectForKey:@"userID"]];
        self.opponent = [UserService GetUserWithId:[self.game objectForKey:@"opponentID"]];
        [self getPreviousMatchups];
    });
    
}

#define batQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
-(void) getPreviousMatchups{
    dispatch_async(batQueue, ^{
        self.previousMatchups = [GameService GetPreviousGames:self.user :self.opponent];
        [self populateUI];
    });
}

//done on batQueue thread
-(void) populateUI {
    [self.previousMatchupsTable reloadData];
    self.userNameLabel.text = [self.user objectForKey:@"ShortName"];
    self.opponentNameLabel.text = [self.opponent objectForKey:@"ShortName"];
    self.userRecordLabel.text = [NSString stringWithFormat:@"(%@ - %@)", [self.user objectForKey:@"Wins"],[self.user objectForKey:@"Losses"]];
    self.opponentRecordLabel.text = [NSString stringWithFormat:@"(%@ - %@)", [self.opponent objectForKey:@"Wins"],[self.opponent objectForKey:@"Losses"]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
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
