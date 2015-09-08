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
#import "UserService.h"

@interface AddUserTableViewController ()
@property NSArray *users;
@end

@implementation AddUserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self queryUsers];
}

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
-(void) queryUsers{
    dispatch_async(kBgQueue, ^{
        self.users = [UserService GetAllUsers];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#define batQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
-(void) sendRequest:(NSString*) userID: (PFObject*) sender{
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    
    dispatch_async(batQueue, ^{
        [UserService SendLeagueRequest:userID :sender: ap.selectedLeague];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                            message:@"Your league request was sent!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    });
    
    
    
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
    [self sendRequest:[[self.users objectAtIndex:indexPath.row] objectId] :[self.users objectAtIndex:indexPath.row]];
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
