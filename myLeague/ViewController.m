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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tv_username;
@property (weak, nonatomic) IBOutlet UITextField *tv_password;
@property (weak, nonatomic) IBOutlet UIView *enclosedView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;

@end

@implementation ViewController


-(void) viewDidAppear:(BOOL)animated{
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    if([PFUser currentUser] != nil && ap.isLoggedIn == false){
        // Do stuff after successful login.
        PFUser *user = [PFUser currentUser];
        
        ap.user.userID = [user objectId];
        ap.user.username = [user objectForKey:@"username"];
        //TODO: add support later
        ap.user.profilePictureUrl = @"";
        ap.user.email = [user objectForKey:@"email"];
        ap.user.firstName = [user objectForKey:@"firstName"];
        ap.user.lastName = [user objectForKey:@"lastName"];
        ap.user.profileMotto = [user objectForKey:@"profileMotto"];
        ap.user.profilePictureUrl = [user objectForKey:@"profilePictureUrl"];
        ap.isLoggedIn = true;
        [self performSegueWithIdentifier:@"LoginLeagueListSegue" sender:self];
    }

}
- (void)viewDidLoad {
    self.enclosedView.layer.cornerRadius = 10;
    self.enclosedView.layer.masksToBounds = YES;
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
            ap.user.profilePictureUrl = [user objectForKey:@"profilePictureUrl"];
            
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
