//
//  AdvancedStandingsTableViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 6/30/15.
//  Copyright © 2015 Brandon Hafenrichter. All rights reserved.
//

#import "AdvancedStandingsTableViewController.h"
#import "AdvancedStandingsTableViewCell.h"
@interface AdvancedStandingsTableViewController ()

@end

@implementation AdvancedStandingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return self.members.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AdvancedStandingsCell";
    AdvancedStandingsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ((cell == nil) || (![cell isKindOfClass: AdvancedStandingsTableViewCell.class]))
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AdvancedStandingsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.nameLabel.text = [[self.members objectAtIndex:indexPath.row] objectForKey:@"ShortName"];
    cell.winsLabel.text = [[self.members objectAtIndex:indexPath.row] objectForKey:@"Wins"];
    cell.lossesLabel.text = [[self.members objectAtIndex:indexPath.row] objectForKey:@"Losses"];
    cell.PPGLabel.text = [[self.members objectAtIndex:indexPath.row] objectForKey:@"PointsScored"];
    cell.PALabel.text = [[self.members objectAtIndex:indexPath.row] objectForKey:@"PointsAllowed"];
    
    NSURL * imageURL = [NSURL URLWithString:[[self.members objectAtIndex:indexPath.row] objectForKey:@"ProfilePictureUrl"]];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    cell.thumbnailImageView.image = [UIImage imageWithData:imageData];
    cell.thumbnailImageView.layer.cornerRadius = 20;
    cell.thumbnailImageView.layer.masksToBounds = YES;
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
