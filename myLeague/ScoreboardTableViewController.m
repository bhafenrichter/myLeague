//
//  ScoreboardTableViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 8/1/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "ScoreboardTableViewController.h"
#import "ScoreboardTableViewCell.h"
#import "UserService.h"
#import "GameViewController.h"

@interface ScoreboardTableViewController ()
@property int selectedIndex;
@end

@implementation ScoreboardTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    // Return the number of rows in the section.
    return self.games.count;
}

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ScoreboardTableViewCell";
    ScoreboardTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ((cell == nil) || (![cell isKindOfClass: ScoreboardTableViewCell.class]))
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ScoreboardTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    for(int i = 0; i < self.members.count; i++){
        if([[[self.members objectAtIndex:i] objectForKey:@"UserID"] isEqualToString:[[self.games objectAtIndex:indexPath.row] objectForKey:@"userID"]]){
            cell.userName.text = [[self.members objectAtIndex:i] objectForKey:@"ShortName"];
            dispatch_async(kBgQueue, ^{
                UIImage *userPicData = [UserService GetUserPicture:[[self.members objectAtIndex:i] objectForKey:@"ProfilePictureUrl"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.userImage.layer.cornerRadius = 20;
                    cell.userImage.layer.masksToBounds = YES;
                    cell.userImage.image = userPicData;
                });
            });
        }
    }
    for(int i = 0; i < self.members.count; i++){
        if([[[self.members objectAtIndex:i] objectForKey:@"UserID"] isEqualToString:[[self.games objectAtIndex:indexPath.row] objectForKey:@"opponentID"]]){
            cell.opponentName.text = [[self.members objectAtIndex:i] objectForKey:@"ShortName"];
            dispatch_async(kBgQueue, ^{
                UIImage *userPicData = [UserService GetUserPicture:[[self.members objectAtIndex:i] objectForKey:@"ProfilePictureUrl"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.opponentImage.layer.cornerRadius = 20;
                    cell.opponentImage.layer.masksToBounds = YES;
                    cell.opponentImage.image = userPicData;
                });
            });
            
        }
    }
    cell.userScore.text = [[self.games objectAtIndex:indexPath.row] objectForKey:@"userScore"];
    cell.opponentScore.text = [[self.games objectAtIndex:indexPath.row] objectForKey:@"opponentScore"];
    cell.headline.text = [[self.games objectAtIndex:indexPath.row] objectForKey:@"headlineText"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"ScoreboardGameSegue" sender:self];
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


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ScoreboardGameSegue"])
    {
        GameViewController *gvc = [segue destinationViewController];
        gvc.game = [self.games objectAtIndex:self.selectedIndex];
    }
}

@end
