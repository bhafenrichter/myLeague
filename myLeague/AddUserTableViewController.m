//
//  AddUserTableViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 6/13/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "AddUserTableViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "NewsFeedViewController.h"

@interface AddUserTableViewController ()
@property NSArray *users;
@end

@implementation AddUserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self queryUsers];
}

-(void) queryUsers{
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            self.users = [[NSArray alloc] initWithArray:objects];
            [self.tableView reloadData];
        }else{
            NSLog(error);
        }
    }];
}

-(void) sendRequest:(NSString*) userID: (NSString*) username{
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    
    PFObject *request = [[PFObject alloc] initWithClassName:@"LeagueRequest"];
    request[@"LeagueID"] = ap.selectedLeague.leagueId;
    request[@"InviteeUsername"] = username;
    request[@"InviteeID"] = userID;
    request[@"LeagueName"] = ap.selectedLeague.leagueName;
    request[@"SenderName"] = [NSString stringWithFormat:@"%@ %@", ap.user.firstName, ap.user.lastName];
    [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(!error){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                            message:@"User has been successfully added!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NSLog(error);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.users objectAtIndex:indexPath.row] objectForKey:@"username"];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self sendRequest:[[self.users objectAtIndex:indexPath.row] objectId] :[[self.users objectAtIndex:indexPath.row] username]];
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
