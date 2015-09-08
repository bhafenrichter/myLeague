//
//  LeaguesListViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 5/24/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import <Parse/Parse.h>
#import "LeaguesListViewController.h"
#import "NewsFeedViewController.h"
#import "AppDelegate.h"
#import "League.h"
#import "LeagueService.h"
#import "UserService.h"

@interface LeaguesListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *leagueList;
@property NSMutableArray *leagues;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *requestButton;
@property NSInteger *selectedLeagueIndex;
@end

@implementation LeaguesListViewController

-(void) viewDidAppear:(BOOL)animated {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    NSString *userID = ap.user.userID;
    ;
    
    //table setup
    self.leagueList.delegate = self;
    self.leagueList.dataSource = self;
    self.leagueList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self getLeagues];
}

-(void) getLeagues{
    self.leagueList.layer.cornerRadius = 10;
    self.leagueList.layer.masksToBounds = YES;
    
    
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    NSString *userID = ap.user.userID;
    PFQuery *query = [PFQuery queryWithClassName:@"UserLeague"];
    [query whereKey:@"UserID" containsString:userID];
    [query whereKey:@"IsDeleted" equalTo:[NSNumber numberWithBool:NO]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSArray *leagueIDs = [[NSArray alloc] initWithArray:objects];
            self.leagues = [[NSMutableArray alloc] init];
            for(int i = 0; i < leagueIDs.count; i++){
                PFQuery *query = [PFQuery queryWithClassName:@"League"];
                PFObject *league = [query getObjectWithId:[[leagueIDs objectAtIndex:i] objectForKey:@"LeagueID"]];
                [self.leagues addObject:league];
            }
            
            //update table and request
            [self.leagueList reloadData];
            
            self.requestButton.title = [NSString stringWithFormat:@"Requests (%i)",[LeagueService GetLeagueRequestsCount:userID]];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
}

//table
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.leagues.count;
}

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.leagueList dequeueReusableCellWithIdentifier:@"LeagueCell" forIndexPath:indexPath];

    PFObject *curObject = [self.leagues objectAtIndex:indexPath.row];
    cell.textLabel.text = [curObject objectForKey:@"LeagueName"];
    cell.detailTextLabel.text = @" ";
    cell.detailTextLabel.text = [curObject objectForKey:@"LeagueType"];
    
    
    dispatch_async(kBgQueue, ^{
        AppDelegate *ap = [[UIApplication sharedApplication] delegate];
        UIImage *leagueImage = [UserService GetUserPicture: [curObject objectForKey:@"LeaguePictureUrl"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = leagueImage;
        });
    });
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedLeagueIndex = indexPath.row;
    [self performSegueWithIdentifier:@"LeagueListLeagueOverview" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"LeagueListLeagueOverview"]){
        // Make sure your segue name in storyboard is the same as this line
        NewsFeedViewController *controller = [segue destinationViewController];
        PFQuery *query = [PFQuery queryWithClassName:@"League"];
        
        //gets the league based on the table selected
        PFObject *object = [query getObjectWithId:[[self.leagues objectAtIndex:self.selectedLeagueIndex] objectId]];

        League *selected = [[League alloc]init];
        selected.leagueId = [ object objectId];
        selected.leagueName = [object objectForKey:@"LeagueName"];
        selected.leagueMotto = [object objectForKey:@"LeagueMotto"];
        selected.leagueType = [object objectForKey:@"LeagueType"];
        selected.gameCount = [object objectForKey:@"GameCount"];
        selected.leagueUrl = [object objectForKey:@"LeaguePictureUrl"];
        AppDelegate *ap = [[UIApplication sharedApplication] delegate];
        ap.selectedLeague = selected;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
