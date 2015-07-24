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
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserLeague"];
    [query whereKey:@"LeagueID" containsString:self.league.leagueId];
    [query orderByDescending:@"Wins"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            self.members = [[NSArray alloc] initWithArray:objects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            //NSLog(@"%@", self.members);
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

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchLeagueUser" forIndexPath:indexPath];
    
    
    dispatch_async(kBgQueue, ^{
        NSURL * imageURL = [NSURL URLWithString:[[self.members objectAtIndex:indexPath.row] objectForKey:@"ProfilePictureUrl"]];
        NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.textLabel.text = [[self.members objectAtIndex:indexPath.row] objectForKey:@"ShortName"];
            cell.imageView.image = [UIImage imageWithData:imageData];
        });
    });
    
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
