//
//  AdvancedStandingsTableViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 6/30/15.
//  Copyright © 2015 Brandon Hafenrichter. All rights reserved.
//

#import "AdvancedStandingsTableViewController.h"
#import "AdvancedStandingsTableViewCell.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"

@interface AdvancedStandingsTableViewController ()
@property int selectedIndex;
@end

@implementation AdvancedStandingsTableViewController

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.members.count + 1;
}

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AdvancedStandingsCell";
    AdvancedStandingsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ((cell == nil) || (![cell isKindOfClass: AdvancedStandingsTableViewCell.class]))
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AdvancedStandingsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    //highlight user if thats the one currently logged in
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    
    if(indexPath.row == 0){
        cell.nameLabel.text = @"Name";
        cell.winsLabel.text = @"W";
        cell.lossesLabel.text = @"L";
        cell.PPGLabel.text = @"PS";
        cell.PALabel.text = @"PA";
    }else{
        dispatch_async(kBgQueue, ^{
            NSURL * imageURL = [NSURL URLWithString:[[self.members objectAtIndex:indexPath.row - 1] objectForKey:@"ProfilePictureUrl"]];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.thumbnailImageView.image = [UIImage imageWithData:imageData];
                cell.thumbnailImageView.layer.cornerRadius = 20;
                cell.thumbnailImageView.layer.masksToBounds = YES;
            });
            
        });
        
        if([[[self.members objectAtIndex:indexPath.row - 1] objectForKey:@"UserID"] isEqualToString:ap.user.userID]){
            cell.backgroundColor = [UIColor yellowColor];
        }
        
        cell.nameLabel.text = [[self.members objectAtIndex:indexPath.row - 1] objectForKey:@"ShortName"];
        cell.winsLabel.text = [[self.members objectAtIndex:indexPath.row - 1] objectForKey:@"Wins"];
        cell.lossesLabel.text = [[self.members objectAtIndex:indexPath.row - 1] objectForKey:@"Losses"];
        cell.PPGLabel.text = [[self.members objectAtIndex:indexPath.row - 1] objectForKey:@"PointsScored"];
        cell.PALabel.text = [[self.members objectAtIndex:indexPath.row - 1] objectForKey:@"PointsAllowed"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row != 0){
        self.selectedIndex = indexPath.row - 1;
        [self performSegueWithIdentifier:@"StandingsProfileSegue" sender:self];
    }
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"StandingsProfileSegue"])
    {
        ProfileViewController *pvc = [segue destinationViewController];
        pvc.user = [self.members objectAtIndex:self.selectedIndex - 1];
    }
}

@end
