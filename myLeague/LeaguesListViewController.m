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

@interface LeaguesListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *leagueList;
@property NSArray *leagues;
@property NSInteger *selectedLeagueIndex;
@end

@implementation LeaguesListViewController

-(void) viewDidAppear:(BOOL)animated {
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    NSString *userID = ap.user.userID;
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserLeague"];
    [query whereKey:@"UserID" containsString:userID];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error){
        if(!error){
            
        }
    }];
    
    [self getLeagues];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            //NSLog(@"Successfully retrieved %lu leagues.", (unsigned long) objects.count);
            self.leagues = [[NSArray alloc] initWithArray:objects];
            
            //update table
            [self.leagueList reloadData];
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

    dispatch_async(kBgQueue, ^{
        PFObject *curObject = [self.leagues objectAtIndex:indexPath.row];
        NSString *leagueID = [curObject objectForKey:@"LeagueID"];
        
        PFQuery *query = [PFQuery queryWithClassName:@"League"];
        PFObject *cur = [query getObjectWithId:leagueID];
        
        //NSLog(@"League Object: %@", cur);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.textLabel.text = [cur objectForKey:@"LeagueName"];
            cell.detailTextLabel.text = [cur objectForKey:@"LeagueType"];
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
        PFObject *object = [query getObjectWithId:[[self.leagues objectAtIndex:self.selectedLeagueIndex] objectForKey:@"LeagueID"]];

        League *selected = [[League alloc]init];
        selected.leagueId = [[self.leagues objectAtIndex:self.selectedLeagueIndex] objectForKey:@"LeagueID"];
        selected.leagueName = [object objectForKey:@"LeagueName"];
        selected.leagueMotto = [object objectForKey:@"LeagueMotto"];
        selected.leagueType = [object objectForKey:@"LeagueType"];
        selected.gameCount = [object objectForKey:@"GameCount"];
        AppDelegate *ap = [[UIApplication sharedApplication] delegate];
        ap.selectedLeague = selected;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
