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

@interface AddGameViewController : ViewController
@property (weak, nonatomic) IBOutlet MKMapView *gameMapView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UITextField *userScore;
@property (weak, nonatomic) IBOutlet UIImageView *opponentPicture;
@property (weak, nonatomic) IBOutlet UITextField *opponentScore;
@property (weak, nonatomic) IBOutlet UILabel *timeOfGame;
@property (weak, nonatomic) IBOutlet UILabel *dateOfGame;
@property (weak, nonatomic) IBOutlet UITextView *userComments;
@property User *opponent;

-(void)sendDataToAddGame:(User*)selectedUser;
@end
