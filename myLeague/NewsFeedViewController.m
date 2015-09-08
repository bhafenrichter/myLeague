//
//  NewsFeedViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 5/27/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "NewsFeedViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "League.h"
#import "StandingsTableViewCell.h"
#import "ProfileViewController.h"
#import "AdvancedStandingsTableViewController.h"
#import "HeadlineView.h"
#import "ScoreboardTableViewController.h"
#import "LeagueSettingsViewController.h"

@interface NewsFeedViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *actionBarTitle;
@property (weak, nonatomic) IBOutlet UIView *gameView;
@property (weak, nonatomic) IBOutlet UITableView *standingsTable;
@property (weak, nonatomic) IBOutlet UIImageView *headlineImage;
@property (weak, nonatomic) IBOutlet UILabel *headlineText;
@property (weak, nonatomic) IBOutlet UILabel *headlineScore;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;

@property NSArray *recentGames;    //array of uiviews
@property int selectedProfileIndex;
@property NSString *userLeagueId;
@end

@implementation NewsFeedViewController

-(void) viewDidAppear:(BOOL)animated {
    //get selected leagueid
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    self.league = ap.selectedLeague;

    NSLog(@"%@", self.league.leagueName);
    self.actionBarTitle.title = self.league.leagueName;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query whereKey:@"LeagueID" containsString:self.league.leagueId];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error){
        if(!error){
            //league page needs to be updated
            if(count != self.league.gameCount){
                //refresh league game count
                PFQuery *leagueQuery = [PFQuery queryWithClassName:@"League"];
                PFObject *league = [leagueQuery getObjectWithId:self.league.leagueId];
                league[@"GameCount"] = @(count);
                ap.selectedLeague.gameCount = count;
                [league saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                    if(!error){
                        //refresh page
                        [self setupStandingsTable];
                        [self setupNavBar];
                        [self createScoreboard: true];
                    }
                }];
            }else{
                [self createScoreboard:false];
            }
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initialSetup];
    [self setupNavBar];
    [self createScoreboard: true];
}

-(void) initialSetup {
    self.standingsTable.dataSource = self;
    self.standingsTable.delegate = self;
    
    //get selected leagueid
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    self.league = ap.selectedLeague;
    self.navigationBar.title = self.league.leagueName;
    
    //rounds corners
    self.gameView.layer.cornerRadius = 10;
    self.gameView.layer.masksToBounds = YES;
    
    self.standingsTable.layer.cornerRadius = 10;
    self.standingsTable.layer.masksToBounds = YES;
}

-(void) setupStandingsTable{
    self.standingsTable.rowHeight = 40;
    self.standingsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    PFQuery *query = [PFQuery queryWithClassName:@"UserLeague"];
    [query whereKey:@"LeagueID" containsString:self.league.leagueId];
    [query orderByDescending:@"Wins"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            self.members = [[NSArray alloc] initWithArray:objects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.standingsTable reloadData];
            });
        }
    }];
}

- (IBAction)addGame:(id)sender {
    [self performSegueWithIdentifier:@"LeagueAddGame" sender:self];
}

-(void) createScoreboard: (bool) isQuery {
    //get games from database
    //if(isQuery){
        PFQuery *query = [PFQuery queryWithClassName:@"Game"];
        [query whereKey:@"LeagueID" containsString:self.league.leagueId];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if(!error){
                self.recentGames = [[NSArray alloc] initWithArray:objects];
                [self beginTicker: 0];
            }
            else{
                NSLog(@"%@", error);
            }
            
        }];
    //}else{
        //[self beginTicker: 0];
    //}
    
}

//#define batQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
-(void) beginTicker: (int) index{
    if(index >= self.recentGames.count){
        index = 0;
    }
    
    if([[[self.recentGames objectAtIndex:index] objectForKey:@"headlineColor"] isEqualToString:@"white"]){
        self.headlineText.textColor = [UIColor whiteColor];
        self.headlineScore.textColor = [UIColor whiteColor];
    }else{
        self.headlineText.textColor = [UIColor blackColor];
        self.headlineScore.textColor = [UIColor blackColor];
    }
    
    self.headlineText.text = [[self.recentGames objectAtIndex:index] objectForKey:@"headlineText"];
    [self.headlineText setAlpha:0.0f];
    self.headlineScore.text = [self generateHeadlineScore: [self.recentGames objectAtIndex:index]];
    self.headlineText.numberOfLines = 0;
    [self.headlineText sizeToFit];
    
    PFFile *headlineImageFile = [[self.recentGames objectAtIndex:index] objectForKey:@"headlineImage"];
    [headlineImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
             self.headlineImage.image = [UIImage imageWithData:data];
        }else{
            self.headlineImage.image = [UIImage imageNamed:@"blank-user"];
        }
    }];
    //fade in
    [UIView animateWithDuration:3.0f animations:^{
        [self.headlineText setAlpha:1.0f];
        [self.headlineImage setAlpha:1.0f];
        [self.headlineScore setAlpha:1.0f];
    } completion:^(BOOL finished) {
        //fade out
        [UIView animateWithDuration:3.0f animations:^{
            [self.headlineText setAlpha:0.0f];
            [self.headlineImage setAlpha:0.0f];
            [self.headlineScore setAlpha:0.0f];
        } completion:^(BOOL finished){
            if(finished)
                [self beginTicker: index + 1];
        }];
    }];
}

-(NSString*) generateHeadlineScore: (PFObject*) game{
    NSMutableString *headline = [[NSMutableString alloc]init];
    for(int i = 0; i < self.members.count; i++){
        if([[[self.members objectAtIndex:i] objectForKey:@"UserID"] isEqualToString:[game objectForKey:@"userID"]]){
            [headline appendString:[[self.members objectAtIndex:i] objectForKey:@"ShortName"]];
            [headline appendString:@" "];
            [headline appendString:[game objectForKey:@"userScore"]];
        }
    }
    [headline appendString:@", "];
    for(int i = 0; i < self.members.count; i++){
        if([[[self.members objectAtIndex:i] objectForKey:@"UserID"] isEqualToString:[game objectForKey:@"opponentID"]]){
            [headline appendString:[[self.members objectAtIndex:i] objectForKey:@"ShortName"]];
            [headline appendString:@" "];
            [headline appendString:[game objectForKey:@"opponentScore"]];
        }
    }
    return headline;
}

-(void) setupNavBar {
    self.actionBarTitle.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(addGameSegue)];
    self.actionBarTitle.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backSegue)];
}

-(void)backSegue {
    [self performSegueWithIdentifier:@"LeagueLeagueList" sender:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.members count] + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row != 0){
        self.selectedProfileIndex = indexPath.row - 1;
        [self performSegueWithIdentifier:@"NewsFeedProfileSegue" sender:self];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"NewsFeedProfileSegue"])
    {
        ProfileViewController *pvc = [segue destinationViewController];
        pvc.user = [self.members objectAtIndex:self.selectedProfileIndex];
    }else if([[segue identifier] isEqualToString:@"NewsFeedAdvancedStandingsSegue"]){
        AdvancedStandingsTableViewController *astvc = [segue destinationViewController];
        astvc.members = self.members;
    }else if([[segue identifier] isEqualToString:@"NewsFeedScoreboardSegue"]){
        ScoreboardTableViewController *stvc = [segue destinationViewController];
        stvc.games = self.recentGames;
        stvc.members = self.members;
    }else if([[segue identifier] isEqualToString:@"NewsFeedLeagueSettingsSegue"]){
        LeagueSettingsViewController *lsvc = [segue destinationViewController];
        lsvc.userLeagueId = self.userLeagueId;
    }
}

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StandingsCell";
    StandingsTableViewCell *cell = [self.standingsTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ((cell == nil) || (![cell isKindOfClass: StandingsTableViewCell.class]))
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StandingsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    //draws the first row
    if(indexPath.row == 0){
        cell.nameLabel.text = @"Name";
        cell.winsLabel.text = @"W";
        cell.lossesLabel.text = @"L";
    }else{
        //highlight user if thats the one currently logged in
        AppDelegate *ap = [[UIApplication sharedApplication] delegate];
        if([[[self.members objectAtIndex:indexPath.row - 1] objectForKey:@"UserID"] isEqualToString:ap.user.userID]){
            cell.backgroundColor = [UIColor yellowColor];
            self.userLeagueId = [[self.members objectAtIndex:indexPath.row - 1] objectId];
        }
        
        
        cell.nameLabel.text = [[self.members objectAtIndex:indexPath.row - 1] objectForKey:@"ShortName"];
        cell.winsLabel.text = [[self.members objectAtIndex:indexPath.row - 1] objectForKey:@"Wins"];
        cell.lossesLabel.text = [[self.members objectAtIndex:indexPath.row - 1] objectForKey:@"Losses"];
        
        dispatch_async(kBgQueue, ^{
            cell.thumbnailImageView.image = nil; // or cell.poster.image = [UIImage imageNamed:@"placeholder.png"];
            
            NSURL * imageURL = [NSURL URLWithString:[[self.members objectAtIndex:indexPath.row - 1] objectForKey:@"ProfilePictureUrl"]];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        StandingsTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell){
                            updateCell.thumbnailImageView.image = image;
                            cell.thumbnailImageView.layer.cornerRadius = 20;
                            cell.thumbnailImageView.layer.masksToBounds = YES;
                        }
                    });
                }
            }
        });
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
