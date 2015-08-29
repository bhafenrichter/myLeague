//
//  SettingsViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 8/13/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "UserService.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureField;
@property (weak, nonatomic) IBOutlet UITableView *leaguesList;
@property NSMutableArray *leagues;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    self.leaguesList.dataSource = self;
    self.leaguesList.delegate = self;
}

- (IBAction)logout:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self performSegueWithIdentifier:@"SettingsLoginSegue" sender:self];
}

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
-(void) setupUI{
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    self.firstNameField.text = ap.user.firstName;
    self.lastNameField.text = ap.user.lastName;
    
    dispatch_async(kBgQueue, ^{
        UIImage *img = [UIImage imageWithData:[UserService GetUserPicture:ap.user.profilePictureUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profilePictureField.image = img;
        });
    });
    
}

-(void) getLeagues{
    
    
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    NSString *userID = ap.user.userID;
    PFQuery *query = [PFQuery queryWithClassName:@"UserLeague"];
    [query whereKey:@"UserID" containsString:userID];
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
            
            //update table
            [self.leaguesList reloadData];
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

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.leaguesList dequeueReusableCellWithIdentifier:@"LeagueCell" forIndexPath:indexPath];
    
    PFObject *curObject = [self.leagues objectAtIndex:indexPath.row];
    cell.textLabel.text = [curObject objectForKey:@"LeagueName"];
    cell.detailTextLabel.text = @" ";
    cell.detailTextLabel.text = [curObject objectForKey:@"LeagueType"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
