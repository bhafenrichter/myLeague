//
//  NewsFeedViewController.m
//  myLeague
//
//  Created by Brandon Hafenrichter on 5/27/15.
//  Copyright (c) 2015 Brandon Hafenrichter. All rights reserved.
//

#import "NewsFeedViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "League.h"
#import "MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "SWRevealViewController.h"
#import "StandingsTableViewCell.h"
#import "ProfileViewController.h"
#import "AdvancedStandingsTableViewController.h"

@interface NewsFeedViewController ()
@property (weak, nonatomic) IBOutlet UITableView *NewsFeedTable;
@property (weak, nonatomic) IBOutlet UINavigationItem *actionBarTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *gameScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *gamePageControl;
@property (weak, nonatomic) IBOutlet UIView *gameView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *gameLoadingWheel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButton;
@property (weak, nonatomic) IBOutlet UITableView *standingsTable;

@property NSMutableArray *recentGamesScoreboard;    //array of uiviews
@property int selectedProfileIndex;
@end

@implementation NewsFeedViewController

-(void) viewDidAppear:(BOOL)animated {
    //get selected leagueid
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    self.league = ap.selectedLeague;
    NSLog(@"%@", self.league.leagueName);
    self.actionBarTitle.title = self.league.leagueName;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query whereKey:@"LeagueID" containsString:self.league.leagueId];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error){
        if(!error){
            if(count != self.league.gameCount){
                //refresh league game count
                PFQuery *leagueQuery = [PFQuery queryWithClassName:@"League"];
                PFObject *league = [leagueQuery getObjectWithId:self.league.leagueId];
                league[@"GameCount"] = @(count);
                ap.selectedLeague.gameCount = count;
                [league saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                    if(!error){
                        //refresh page
                        [self setupStandingsTable];
                        [self setupNavBar];
                        [self createScoreboard];
                    }
                }];
            }
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.standingsTable.dataSource = self;
    self.standingsTable.delegate = self;
    
    
    //get selected leagueid
    AppDelegate *ap = [[UIApplication sharedApplication] delegate];
    self.league = ap.selectedLeague;
    NSLog(@"%@", self.league.leagueName);
    self.actionBarTitle.title = self.league.leagueName;
    
    self.gameView.layer.cornerRadius = 10;
    self.gameView.layer.masksToBounds = YES;
    
    [self setupStandingsTable];
    [self setupNavBar];
    [self createScoreboard];
}

-(void) setupStandingsTable{
    self.standingsTable.rowHeight = 40;
    self.standingsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    PFQuery *query = [PFQuery queryWithClassName:@"UserLeague"];
    [query whereKey:@"LeagueID" containsString:self.league.leagueId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            self.members = [[NSArray alloc] initWithArray:objects];
            [self.standingsTable reloadData];
            NSLog(@"%@", self.members);
        }
    }];
}

- (IBAction)addGame:(id)sender {
    [self performSegueWithIdentifier:@"LeagueAddGame" sender:self];
}

-(void) setupGameWidget {
    //clears screen
    for (UIView *subview in self.gameScrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    self.gameScrollView.backgroundColor = [UIColor clearColor];
    self.gameScrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack; //Scroll bar style
    self.gameScrollView.showsHorizontalScrollIndicator = NO;
    //dont forget to set delegate in .h file
    [self.gameScrollView setDelegate:self];
    
    UIView *ViewOne = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.gameScrollView.frame.size.width, self.gameScrollView.frame.size.height)];
    
    if(self.recentGamesScoreboard.count > 0){
        [ViewOne addSubview: [self.recentGamesScoreboard objectAtIndex:0]];
    }
    
    
    UIView *ViewTwo = [[UIView alloc] initWithFrame:CGRectMake(self.gameScrollView.frame.size.width, 0, self.gameScrollView.frame.size.width, self.gameScrollView.frame.size.height)];
    
    if(self.recentGamesScoreboard.count > 1){
        [ViewTwo addSubview: [self.recentGamesScoreboard objectAtIndex:1]];
    }
    
    UIView *ViewThree = [[UIView alloc] initWithFrame:CGRectMake(self.gameScrollView.frame.size.width * 2, 0, self.gameScrollView.frame.size.width, self.gameScrollView.frame.size.height)];
    
    if(self.recentGamesScoreboard.count > 2){
        [ViewThree addSubview: [self.recentGamesScoreboard objectAtIndex:2]];
    }
    
    //add all views to array
    NSMutableArray *viewsArray = [[NSMutableArray alloc] initWithObjects:ViewOne, ViewTwo, ViewThree, nil];
    
    self.gamePageControl.numberOfPages = viewsArray.count;
    self.gamePageControl.currentPage = 0;
    self.gamePageControl.backgroundColor = [UIColor clearColor];
    [self.gamePageControl setTintColor:[UIColor blackColor]];
    
    for(int i = 0; i < viewsArray.count; i++)
    {
        CGRect frame;
        frame.origin.x = (self.gameScrollView.frame.size.width *i) + 10;
        frame.origin.y = 0;
        frame.size = CGSizeMake(self.gameScrollView.frame.size.width - 20,     self.gameScrollView.frame.size.height);
        
        UIView *view = [[UIView alloc] initWithFrame:frame];
        view = [viewsArray objectAtIndex:i];
        [self.gameScrollView addSubview:view];
        
        
        self.gameScrollView.contentSize = CGSizeMake(self.gameScrollView.frame.size.width*viewsArray.count, self.gameScrollView.frame.size.height);
    }
    self.gameLoadingWheel.hidden = true;
}

-(void) createScoreboard {
    self.recentGamesScoreboard = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query whereKey:@"LeagueID" containsString:self.league.leagueId];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            int multipler = self.gameScrollView.frame.size.width;
            for(int i = 0; i < 3; i++){
                CGRect frame;
                frame.origin.x = (i) + 10;
                frame.origin.y = 0;
                frame.size = CGSizeMake(self.gameScrollView.frame.size.width - 20,     self.gameScrollView.frame.size.height);
                
                UIView *cur = [[UIView alloc] initWithFrame:frame];
                
                UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 250, 15)];
                header.textColor = [UIColor blackColor];
                NSDate *date = [[objects objectAtIndex:i] createdAt];
                header.text = [NSDateFormatter localizedStringFromDate:date
                                                             dateStyle:NSDateFormatterShortStyle
                                                             timeStyle:NSDateFormatterShortStyle];
                [cur addSubview:header];
                
                UILabel *homeTeam = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 250, 15)];
                homeTeam.textColor=[UIColor blackColor];
                PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
                PFObject *user1 = [userQuery getObjectWithId:[[objects objectAtIndex:i] objectForKey:@"userID"]];
                homeTeam.text = [NSString stringWithFormat:@"%@ %@", [user1 objectForKey:@"firstName"], [user1 objectForKey:@"lastName"]];
                [cur addSubview:homeTeam];
                
                UILabel *awayTeam = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 250, 15)];
                awayTeam.textColor=[UIColor blackColor];
                PFObject *user2 = [userQuery getObjectWithId:[[objects objectAtIndex:i] objectForKey:@"opponentID"]];
                awayTeam.text = [NSString stringWithFormat:@"%@ %@", [user2 objectForKey:@"firstName"], [user2 objectForKey:@"lastName"]];
                [cur addSubview:awayTeam];
                
                UILabel *homeTeamScore = [[UILabel alloc] initWithFrame:CGRectMake(275, 50, 250, 15)];
                homeTeamScore.textColor=[UIColor blackColor];
                homeTeamScore.text = [[objects objectAtIndex:i] objectForKey:@"userScore"];
                [cur addSubview:homeTeamScore];
                
                UILabel *awayTeamScore = [[UILabel alloc] initWithFrame:CGRectMake(275, 100, 250, 15)];
                awayTeamScore.textColor=[UIColor blackColor];
                awayTeamScore.text = [[objects objectAtIndex:i] objectForKey:@"opponentScore"];
                [cur addSubview:awayTeamScore];
                
                
                [self.recentGamesScoreboard addObject:cur];
            }
            //gather data and then populate uiviews
            [self setupGameWidget];
        }
            else{
                NSLog(@"%@", error);
            }
        
    }];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    
    //int page = floor((scrollView.contentOffset.x - pageWidth*0.3) / pageWidth) + 1);
    
    self.gamePageControl.currentPage = (int)scrollView.contentOffset.x / (int)pageWidth;
}

-(void) setupNavBar {
    self.actionBarTitle.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(addGameSegue)];
    self.actionBarTitle.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backSegue)];
}

-(void)backSegue {
    [self performSegueWithIdentifier:@"LeagueLeagueList" sender:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.members count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedProfileIndex = indexPath.row;
    [self performSegueWithIdentifier:@"NewsFeedProfileSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"NewsFeedProfileSegue"])
    {
        ProfileViewController *pvc = [segue destinationViewController];
        pvc.user = [self.members objectAtIndex:self.selectedProfileIndex];
    }else if([[segue identifier] isEqualToString:@"NewsFeedAdvancedStandingsSegue"]){
        AdvancedStandingsTableViewController *astvc = [segue destinationViewController];
        astvc.members = self.members;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StandingsCell";
    StandingsTableViewCell *cell = [self.standingsTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ((cell == nil) || (![cell isKindOfClass: StandingsTableViewCell.class]))
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StandingsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.nameLabel.text = [[self.members objectAtIndex:indexPath.row] objectForKey:@"ShortName"];
    cell.winsLabel.text = [[self.members objectAtIndex:indexPath.row] objectForKey:@"Wins"];
    cell.lossesLabel.text = [[self.members objectAtIndex:indexPath.row] objectForKey:@"Losses"];
    
    NSURL * imageURL = [NSURL URLWithString:[[self.members objectAtIndex:indexPath.row] objectForKey:@"ProfilePictureUrl"]];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    cell.thumbnailImageView.image = [UIImage imageWithData:imageData];
    cell.thumbnailImageView.layer.cornerRadius = 20;
    cell.thumbnailImageView.layer.masksToBounds = YES;
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
