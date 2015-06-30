//
//  ViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 5/14/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "MMDrawerController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tv_username;
@property (weak, nonatomic) IBOutlet UITextField *tv_password;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)validateUser:(id)sender {
    
    [PFUser logInWithUsernameInBackground:self.tv_username.text password:self.tv_password.text block:^(PFUser *user, NSError *error) {
        if (user) {
            // Do stuff after successful login.
            AppDelegate *ap = [[UIApplication sharedApplication] delegate];
            ap.user.userID = [user objectId];
            ap.user.username = [user objectForKey:@"username"];
            //TODO: add support later
            ap.user.profilePictureUrl = @"";
            ap.user.email = [user objectForKey:@"email"];
            ap.user.firstName = [user objectForKey:@"firstName"];
            ap.user.lastName = [user objectForKey:@"lastName"];
            ap.user.profileMotto = [user objectForKey:@"profileMotto"];
            
            
            [self performSegueWithIdentifier:@"LoginLeagueListSegue" sender:self];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid User"
                                                            message:@"The user credentials you entered were invalid. Please try again."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LoginLeagueListSegue"]) {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
