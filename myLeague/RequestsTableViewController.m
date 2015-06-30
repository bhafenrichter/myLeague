//
//  RequestsTableViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 6/17/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "RequestsTableViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface RequestsTableViewController ()
@property NSArray *requests;
@end

@implementation RequestsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getRequests];
}

-(void) getRequests {
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    PFQuery *query = [PFQuery queryWithClassName:@"LeagueRequest"];
    [query whereKey:@"InviteeID" containsString:ap.user.userID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            self.requests = [[NSArray alloc] initWithArray:objects];
            [self.tableView reloadData];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.requests.count;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self joinLeague:[[self.requests objectAtIndex:indexPath.row] objectForKey:@"InviteeID"] :[[self.requests objectAtIndex:indexPath.row] objectForKey:@"LeagueID"]];
}

-(void) joinLeague: (NSString*) userID: (NSString*) leagueID {
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    PFObject *league = [PFObject objectWithClassName:@"UserLeague"];
    league[@"UserID"] = userID;
    league[@"LeagueID"] = leagueID;
    league[@"ShortName"] = [NSString stringWithFormat:@"%@. %@", [ap.user.firstName substringToIndex:1], ap.user.lastName];
    league[@"Wins"] = @"0";
    league[@"Losses"] = @"0";
    league[@"PointsScored"] = @"0";
    league[@"PointsAllowed"] = @"0";
    [league saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if(!error){
            PFQuery *requestObject = [PFQuery queryWithClassName:@"LeagueRequest"];
            [requestObject whereKey:@"InviteeID" containsString:userID];
            [requestObject whereKey:@"LeagueID" containsString:leagueID];
            PFObject *cur = [requestObject getFirstObject];
            [cur deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if(!error){
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    //[self performSegueWithIdentifier:@"RequestsLeagueList" sender:self];
                }
            }];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.requests objectAtIndex:indexPath.row] objectForKey:@"LeagueName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"By %@", [[self.requests objectAtIndex:indexPath.row] objectForKey:@"SenderName"]];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
