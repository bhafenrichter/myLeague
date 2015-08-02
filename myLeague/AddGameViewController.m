//
//  AddGameViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 5/30/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "AddGameViewController.h"

#import <Parse/Parse.h>
#import "League.h"
#import "AppDelegate.h"
#import "User.h"
#import "SearchLeagueTableViewController.h"

@interface AddGameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *DateDay;
@property (weak, nonatomic) IBOutlet UILabel *DateTime;

@property League *league;
@property bool isBlackFont;
@end

@implementation AddGameViewController
- (IBAction)cancelAddGame:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//called every time the UI is loaded
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
-(void) viewDidAppear:(BOOL)animated {
    if(self.opponent != nil){
        //updates picture and text of opponent
        dispatch_async(kBgQueue, ^{
            NSURL * imageURL = [NSURL URLWithString:[self.opponent objectForKey:@"ProfilePictureUrl"]];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.opponentPicture.image = [UIImage imageWithData:imageData];
                self.opponentPicture.layer.cornerRadius = 20;
                self.opponentPicture.layer.masksToBounds = YES;
                
                self.opponentNameLabel.text = [self.opponent objectForKey:@"ShortName"];
            });
            
        });

    }
    
}
- (IBAction)toggleColor:(id)sender {
    if(self.headline.textColor == [UIColor whiteColor]){
        self.headline.textColor = [UIColor blackColor];
        self.isBlackFont = true;
    }else{
        self.headline.textColor = [UIColor whiteColor];
        self.isBlackFont = false;
    }
    
}

- (IBAction)uploadHeadlinePhoto:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //You can retrieve the actual UIImage
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.headlineImage.image = image;
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}


//called once
#define abcQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMap];
    
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    self.league = ap.selectedLeague;
    self.userNameLabel.text =[NSString stringWithFormat:@"%@. %@", [ap.user.firstName substringToIndex:1], ap.user.lastName];
    if(self.opponent != nil){
        self.opponentNameLabel.text = [self.opponent objectForKey:@"ShortName"];
    }
    
     dispatch_async(abcQueue, ^{
         NSDate *localDate = [NSDate date];
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
         dateFormatter.dateFormat = @"MM/dd/yy";
         NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
         timeFormatter.dateFormat = @"HH:mm";
         
         NSURL * imageURL = [NSURL URLWithString:ap.user.profilePictureUrl];
         NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             self.profilePicture.image = [UIImage imageWithData:imageData];
             self.profilePicture.layer.cornerRadius = 20;
             self.profilePicture.layer.masksToBounds = YES;
             
             self.opponentPicture.layer.cornerRadius = 20;
             self.opponentPicture.layer.masksToBounds = YES;
             
             self.DateDay.text = [dateFormatter stringFromDate: localDate];
             self.DateTime.text = [timeFormatter stringFromDate: localDate];
         });
         
     });
    
    
    // Do any additional setup after loading the view.
}

-(void)sendDataToAddGame:(User*)selectedUser{
    self.opponent = selectedUser;
}

-(void) setupMap{
    dispatch_async(kBgQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            CLLocationCoordinate2D location = [[[self.gameMapView userLocation] location] coordinate];
        });
    });
}
#define batQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (IBAction)submitGame:(id)sender {
    //user can't be equal and score can't IMPLEMENT TIES
    if(![self.userNameLabel.text  isEqualToString:self.opponentNameLabel.text] &&
       ![self.userScore.text isEqualToString:self.opponentScore.text] &&
       ![self.userNameLabel.text  isEqual: @""] &&
       ![self.userScore.text  isEqual: @""] &&
       ![self.opponentNameLabel.text  isEqual: @""] &&
       ![self.opponentScore.text  isEqual: @""]){
        
        dispatch_async(batQueue, ^{
            AppDelegate *ap = [[UIApplication sharedApplication] delegate];
            
            PFObject *game = [PFObject objectWithClassName:@"Game"];
            game[@"LeagueID"] = self.league.leagueId;
            game[@"userID"] = ap.user.userID;
            game[@"opponentID"] = [self.opponent objectForKey:@"UserID"];
            game[@"userScore"] = self.userScore.text;
            game[@"opponentScore"] = self.opponentScore.text;
            game[@"headlineText"] = self.headline.text;
            
            if(self.isBlackFont){
                game[@"headlineColor"] = @"black";
            }else{
                game[@"headlineColor"] = @"white";
            }
            
            
            NSData *imageData = UIImageJPEGRepresentation(self.headlineImage.image,0.5);
            PFFile *imageFile = [PFFile fileWithName:@"headline.png" data:imageData];
            
            game[@"headlineImage"] = imageFile;
            //[game setValue:@"location" forKey:@""];
            
            [game saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Saved.");
                    [self updateUsers];
                } else {
                    NSLog(@"%@", error);
                }
            }];
        });
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Submission"
                                                        message:@"There was an error while submitting your request, please try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void) updateUsers {
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    
    //increment user
    PFQuery *query = [PFQuery queryWithClassName:@"UserLeague"];
    [query whereKey:@"UserID" containsString:ap.user.userID];
    [query whereKey:@"LeagueID" containsString:self.league.leagueId];
    PFObject *user = [query getFirstObject];
    if(self.userScore.text.intValue > self.opponentScore.text.intValue){
        NSString *userWins = user[@"Wins"];
        int wins = userWins.intValue;
        wins++;
        user[@"Wins"] = [NSString stringWithFormat:@"%d",wins];
        int pointsScored = [[user objectForKey:@"PointsScore"] intValue] + [self.userScore.text intValue];
        user[@"PointsScored"] = [NSString stringWithFormat:@"%d",pointsScored];
        int pointsAllowed = [[user objectForKey:@"PointsAllowed"] intValue] + [self.opponentScore.text intValue];
        user[@"PointsAllowed"] = [NSString stringWithFormat:@"%d",pointsAllowed];

        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if(succeeded){
                PFQuery *opponentQuery = [PFQuery queryWithClassName:@"UserLeague"];
                [opponentQuery whereKey:@"UserID" containsString:[self.opponent objectForKey:@"UserID"]];
                [opponentQuery whereKey:@"LeagueID" containsString:self.league.leagueId];
                PFObject *opponent = [opponentQuery getFirstObject];
                NSString *opponentLosses = opponent[@"Losses"];
                int losses = opponentLosses.intValue;
                losses++;
                opponent[@"Losses"] = [NSString stringWithFormat:@"%d",losses];
                int pointsScored = [[opponent objectForKey:@"PointsScored"] intValue] + [self.opponentScore.text intValue];
                opponent[@"PointsScored"] = [NSString stringWithFormat:@"%d",pointsScored];
                int pointsAllowed = [[opponent objectForKey:@"PointsAllowed"] intValue] + [self.userScore.text intValue];
                opponent[@"PointsAllowed"] = [NSString stringWithFormat:@"%d",pointsAllowed];
                [opponent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if(!error){
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
                
            }
        }];
    }else{
        NSString *userLosses = user[@"Losses"];
        int wins = userLosses.intValue;
        wins++;
        user[@"Losses"] = [NSString stringWithFormat:@"%d",wins];
        int pointsScored = [[user objectForKey:@"PointsScore"] intValue] + [self.userScore.text intValue];
        user[@"PointsScored"] = [NSString stringWithFormat:@"%d",pointsScored];
        int pointsAllowed = [[user objectForKey:@"PointsAllowed"] intValue] + [self.opponentScore.text intValue];
        user[@"PointsAllowed"] = [NSString stringWithFormat:@"%d",pointsAllowed];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if(succeeded){
                //saves opponent
                PFQuery *opponentQuery = [PFQuery queryWithClassName:@"UserLeague"];
                [opponentQuery whereKey:@"UserID" containsString:[self.opponent objectForKey:@"UserID"]];
                [opponentQuery whereKey:@"LeagueID" containsString:self.league.leagueId];
                PFObject *opponent = [opponentQuery getFirstObject];
                NSString *opponentWins = opponent[@"Wins"];
                int wins = opponentWins.intValue;
                int losses = [[opponent objectForKey:@"Losses"] intValue];
                wins++;
                opponent[@"Wins"] = [NSString stringWithFormat:@"%d",wins];
                int pointsScored = [[opponent objectForKey:@"PointsScored"] intValue] + [self.opponentScore.text intValue];
                opponent[@"PointsScored"] = [NSString stringWithFormat:@"%d",pointsScored];
                int pointsAllowed = [[opponent objectForKey:@"PointsAllowed"] intValue] + [self.userScore.text intValue];
                opponent[@"PointsAllowed"] = [NSString stringWithFormat:@"%d",pointsAllowed];
                
                [opponent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if(!error){
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }
        }];
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if ([touch view] == self.opponentPicture)
    {
        //add your code for image touch here
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        
        SearchLeagueTableViewController *acontrollerobject = (SearchLeagueTableViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"SearchLeagueTableViewController"];
        acontrollerobject.delegate = self; // protocol listener
        [self.navigationController pushViewController:acontrollerobject animated:YES];
    }
    
    [self.view endEditing:true];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"AddGameSearchLeague"])
    {
        SearchLeagueTableViewController *sltvc = segue.destinationViewController;

    }
}


@end
