//
//  SearchLeagueTableViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 5/31/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "SearchLeagueTableViewController.h"
#import "League.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "User.h"
#import "AddGameViewController.h"

@interface SearchLeagueTableViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *members;
@property League *league;
@property NSInteger *selectedIndex;

@end



@implementation SearchLeagueTableViewController

@synthesize delegate;
-(void)viewWillDisappear:(BOOL)animated
{
    //sends selected member back to addgameviewcontroller
    [delegate sendDataToAddGame:[self.members objectAtIndex:self.selectedIndex]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.members = [[NSMutableArray alloc]init];
    
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    self.league = ap.selectedLeague;
    
    [self getMembersIDs];
    
}

-(void) getMembersIDs {
    PFQuery *query = [PFQuery queryWithClassName:@"UserLeague"];
    [query whereKey:@"LeagueID" containsString:self.league.leagueId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        //get all the users information who are in the league
        if(!error){
            
            for(int i = 0; i < objects.count; i++){
                //gets the user info
                NSString *userID = [[objects objectAtIndex:i] objectForKey:@"UserID"];
                PFQuery *query = [PFQuery queryWithClassName:@"_User"];
                [query whereKey:@"objectId" containsString:userID];
                PFObject *user = [query getFirstObject];
                User *cur = [[User alloc]init];
                cur.username = [user objectForKey:@"username"];
                cur.email = [user objectForKey:@"email"];
                cur.firstName = [user objectForKey:@"firstName"];
                cur.lastName = [user objectForKey:@"lastName"];
                cur.profilePictureUrl = [user objectForKey:@"profilePictureUrl"];
                cur.profileMotto = [user objectForKey:@"profileMotto"];
                cur.userID = [user objectId];
                
                [self.members addObject:cur];
            }
            [self.tableView reloadData];
            
        }else{
            NSLog(@"Error running queue");
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchLeagueUser" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"@% @%",[[self.members objectAtIndex:indexPath.row] firstName], [[self.members objectAtIndex:indexPath.row] lastName]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    //[self performSegueWithIdentifier:@"SearchLeagueAddGame" sender:self];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"SearchLeagueAddGame"]){
        // Make sure your segue name in storyboard is the same as this line
        AddGameViewController *controller = [segue destinationViewController];
        controller.opponent = [self.members objectAtIndex:self.selectedIndex];
    }
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
