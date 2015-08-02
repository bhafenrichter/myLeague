//
//  ProfileViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 6/21/15.
//  Copyright © 2015 Brandon Hafenrichter. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "StandingsTableViewCell.h"
#import "GameViewController.h"
#import "ScoreboardTableViewController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameTextView;
@property (weak, nonatomic) IBOutlet UILabel *winLossTextView;
@property (weak, nonatomic) IBOutlet UILabel *pointsScoredTextView;
@property (weak, nonatomic) IBOutlet UILabel *pointsAllowedTextView;
@property (weak, nonatomic) IBOutlet UITableView *previousGamesTable;
@property NSArray *previousGames;
@property NSArray *members;
@property NSInteger *selectedGameIndex;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTable];
    [self getMembers];
    [self loadElements];
}

-(void) getMembers{
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    PFQuery *query = [PFQuery queryWithClassName:@"UserLeague"];
    [query whereKey:@"LeagueID" containsString: ap.selectedLeague.leagueId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            self.members = [[NSArray alloc] initWithArray:objects];
            [self setupTable];
        }
    }];

}

-(void) setupTable {
    self.previousGamesTable.delegate = self;
    self.previousGamesTable.dataSource = self;
    self.previousGamesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"userID = %@ OR opponentID = %@", [self.user objectForKey:@"UserID"], [self.user objectForKey:@"UserID"]];
    PFQuery *query = [PFQuery queryWithClassName:@"Game" predicate:predicate];
    [query whereKey:@"LeagueID" containsString:ap.selectedLeague.leagueId];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            if(objects.count > 0){
                self.previousGames = [[NSArray alloc] initWithArray:objects];
            }else{
                self.previousGames = [[NSArray alloc] init];
            }
            [self.previousGamesTable reloadData];
        }
    }];
    
}
- (IBAction)segueToAllGames:(id)sender {
    [self performSegueWithIdentifier:@"ProfileScoreboardSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedGameIndex = indexPath.row;
    [self performSegueWithIdentifier:@"ProfileGameSegue" sender:self];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"StandingsCell";
    StandingsTableViewCell *cell = [self.previousGamesTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(indexPath.row < self.previousGames.count){
        if ((cell == nil) || (![cell isKindOfClass: StandingsTableViewCell.class]))
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StandingsCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        dispatch_async(kBgQueue, ^{
            //gets the name of the player
            if([[[self.previousGames objectAtIndex:indexPath.row] objectForKey:@"userID"] isEqualToString:[self.user objectForKey:@"UserID"]]){
                for(int i = 0; i < self.members.count; i++){
                    if([[[self.previousGames objectAtIndex:indexPath.row] objectForKey:@"opponentID"] isEqualToString:[[self.members objectAtIndex:i] objectForKey:@"UserID"]]){
                        NSURL *imageURL = [NSURL URLWithString:[[self.members objectAtIndex:i] objectForKey:@"ProfilePictureUrl"]];
                        NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.thumbnailImageView.image = [UIImage imageWithData:imageData];
                            cell.thumbnailImageView.layer.cornerRadius = 20;
                            cell.thumbnailImageView.layer.masksToBounds = YES;
                            
                            cell.nameLabel.text = [NSString stringWithFormat:@"Vs. %@",[[self.members objectAtIndex:i] objectForKey:@"ShortName"]];
                            
                            //sets the score
                            cell.winsLabel.text = [[self.previousGames objectAtIndex:indexPath.row] objectForKey:@"userScore"];
                            cell.lossesLabel.text = [[self.previousGames objectAtIndex:indexPath.row] objectForKey:@"opponentScore"];
                        });
                        break;
                    }
                }
            }else{
                for(int i = 0; i < self.members.count; i++){
                    if([[[self.previousGames objectAtIndex:indexPath.row] objectForKey:@"userID"] isEqualToString:[[self.members objectAtIndex:i] objectForKey:@"UserID"]]){
                         NSURL *imageURL = [NSURL URLWithString:[[self.members objectAtIndex:i] objectForKey:@"ProfilePictureUrl"]];
                        NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //async update ui
                            cell.nameLabel.text = [NSString stringWithFormat:@"Vs. %@",[[self.members objectAtIndex:i] objectForKey:@"ShortName"]];
                            
                            cell.thumbnailImageView.image = [UIImage imageWithData:imageData];
                            cell.thumbnailImageView.layer.cornerRadius = 20;
                            cell.thumbnailImageView.layer.masksToBounds = YES;
                            
                            //sets the score
                            cell.winsLabel.text = [[self.previousGames objectAtIndex:indexPath.row] objectForKey:@"userScore"];
                            cell.lossesLabel.text = [[self.previousGames objectAtIndex:indexPath.row] objectForKey:@"opponentScore"];
                        });
                        break;
                    }
                }
            }
        });
        
        
    }
    return cell;
}

#define kGbQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
-(void) loadElements {
    
    dispatch_async(kGbQueue, ^{
        NSURL *url = [NSURL URLWithString: [self.user objectForKey:@"ProfilePictureUrl"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profilePictureImageView.image = image;
            self.profilePictureImageView.layer.cornerRadius = 20;
            self.profilePictureImageView.layer.masksToBounds = YES;
        });
    });

    
    float totalGamesPlayed = [[self.user objectForKey:@"Wins"] intValue] + [[self.user objectForKey:@"Losses"] intValue];
    
    self.nameTextView.text = [self.user objectForKey:@"ShortName"];
    self.winLossTextView.text = [NSString stringWithFormat:@"%@ - %@",[self.user objectForKey:@"Wins"], [self.user objectForKey:@"Losses"]];
    self.pointsAllowedTextView.text = [NSString stringWithFormat:@"%.1f",[[self.user objectForKey:@"PointsAllowed"] floatValue] / totalGamesPlayed];
    self.pointsScoredTextView.text = [NSString stringWithFormat:@"%.1f",[[self.user objectForKey:@"PointsScored"] floatValue] / totalGamesPlayed];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"ProfileGameSegue"]){
        // Make sure your segue name in storyboard is the same as this line
        GameViewController *controller = [segue destinationViewController];
        controller.game = [self.previousGames objectAtIndex:self.selectedGameIndex];
    }else if([[segue identifier] isEqualToString:@"ProfileScoreboardSegue"]){
        ScoreboardTableViewController *sbtvc = [segue destinationViewController];
        sbtvc.games = self.previousGames;
        sbtvc.members = self.members;
    }
}

@end
