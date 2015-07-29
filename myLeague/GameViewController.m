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
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "StandingsTableViewCell.h"

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
@property (weak, nonatomic) IBOutlet MKMapView *gameLocationMapView;

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
        AppDelegate *ap = [[UIApplication sharedApplication] delegate];
        self.user = [UserService GetUserBriefWithId:[self.game objectForKey:@"userID"] :ap.selectedLeague.leagueId];
        self.opponent = [UserService GetUserBriefWithId:[self.game objectForKey:@"opponentID"]: ap.selectedLeague.leagueId];
        [self getPreviousMatchups];
    });
    
}

#define batQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
-(void) getPreviousMatchups{
    dispatch_async(batQueue, ^{
        self.previousMatchupsTable.dataSource = self;
        self.previousMatchupsTable.delegate = self;
        self.previousMatchups = [GameService GetPreviousGames:self.user :self.opponent];
        [self populateUI];
    });
}

//done on batQueue thread
-(void) populateUI {
    UIImageView *userImage = [UserService GetUserPicture:[self.user objectForKey:@"ProfilePictureUrl"]];
    UIImageView *opponentImage = [UserService GetUserPicture:[self.opponent objectForKey:@"ProfilePictureUrl"]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.userNameLabel.text = [self.user objectForKey:@"ShortName"];
        self.opponentNameLabel.text = [self.opponent objectForKey:@"ShortName"];
        self.userRecordLabel.text = [NSString stringWithFormat:@"(%@ - %@)", [self.user objectForKey:@"Wins"],[self.user objectForKey:@"Losses"]];
        self.opponentRecordLabel.text = [NSString stringWithFormat:@"(%@ - %@)", [self.opponent objectForKey:@"Wins"],[self.opponent objectForKey:@"Losses"]];
        self.userScoreLabel.text = [self.game objectForKey:@"userScore"];
        self.opponentScoreLabel.text = [self.game objectForKey:@"opponentScore"];
        self.userPictureView.image = userImage;
        self.opponentPictureView.image = opponentImage;
        [self.previousMatchupsTable reloadData];
    });
}

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"StandingsCell";
    StandingsTableViewCell *cell = [self.previousMatchupsTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(indexPath.row < self.previousMatchups.count){
        if ((cell == nil) || (![cell isKindOfClass: StandingsTableViewCell.class]))
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StandingsCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        dispatch_async(kBgQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                PFObject *cur = [self.previousMatchups objectAtIndex:indexPath.row];
                if([[cur objectForKey:@"userScore" ] intValue] > [[cur objectForKey:@"opponentScore" ] intValue]){
                    cell.nameLabel.text = [NSString stringWithFormat:@"(W) %@",[self.user objectForKey:@"ShortName"]];
                }else if([[cur objectForKey:@"userScore" ] intValue] == [[cur objectForKey:@"opponentScore" ] intValue]){
                    cell.nameLabel.text = @"Tie";
                }else{
                    cell.nameLabel.text = [NSString stringWithFormat:@"(W) %@",[self.opponent objectForKey:@"ShortName"]];
                }
                cell.winsLabel.text = [[self.previousMatchups objectAtIndex:indexPath.row] objectForKey:@"userScore"];
                cell.lossesLabel.text = [[self.previousMatchups objectAtIndex:indexPath.row] objectForKey:@"opponentScore"];
            });
          
        });
        
        
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
