//
//  AddGameViewController.h
//  myLeague
//
//  Created by Brandon Hafenrichter on 5/30/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/Mapkit.h>
#import "User.h"
#import <Parse/Parse.h>

@interface AddGameViewController : ViewController <UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *gameMapView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UITextField *userScore;
@property (weak, nonatomic) IBOutlet UIImageView *opponentPicture;
@property (weak, nonatomic) IBOutlet UITextField *opponentScore;
@property (weak, nonatomic) IBOutlet UILabel *timeOfGame;
@property (weak, nonatomic) IBOutlet UILabel *dateOfGame;
@property (weak, nonatomic) IBOutlet UITextView *headline;
@property (weak, nonatomic) IBOutlet UIImageView *headlineImage;
@property PFObject *opponent;
@property (weak, nonatomic) IBOutlet UIButton *toggleColor;

-(void)sendDataToAddGame:(User*)selectedUser;
@end
