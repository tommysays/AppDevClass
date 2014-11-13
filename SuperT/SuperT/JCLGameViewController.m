//
//  JCLGameViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLGameViewController.h"
#import "JCLGameModel.h"

@interface JCLGameViewController () <UIAlertViewDelegate>

- (IBAction)finalizeButtonPressed:(id)sender;
- (IBAction)surrenderButtonPressed:(id)sender;
- (IBAction)exitButtonPressed:(id)sender;
@property JCLGameModel *gameModel;

@end

@implementation JCLGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gameModel = [[JCLGameModel alloc] initWithPlayer1:self.player1 andPlayer2:self.player2];
}

#pragma mark Button Reactions

- (IBAction)finalizeButtonPressed:(id)sender {
    
}

- (IBAction)surrenderButtonPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Surrender"
                                                    message:@"Are you sure?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Yes",
                          nil];
    alert.tag = 1;
    [alert show];
}

- (IBAction)exitButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // If tag == 1, we are in "Surrender" alert. Otherwise, we are in "Game Over" alert.
    if (alertView.tag == 1){
        if (buttonIndex == 1){
            JCLPlayer *winner;
            JCLPlayer *loser;
            if (self.gameModel.isPlayer1Turn){
                
            }
            [self gameOverWithWinner:winner andLoser:loser];
        }
    } else{
        if (buttonIndex == 0){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void) gameOverWithWinner:(JCLPlayer *)winner andLoser:(JCLPlayer *)loser{
    
    // Update player profiles to reflect conclusion
    [JCLPlayer concludeWithWinner:winner andLoser:loser];
    
    // Show a concluding message with an option to rematch.
    NSString *victoryMessage = [NSString stringWithFormat:@"%@ won the game!", [winner nameOfPlayer]];
    NSIndexPath *score = [winner scoresAgainst:loser];
    NSString *scoreMessage = [NSString stringWithFormat:@"Score: %d to %d", score.row   , score.section];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:victoryMessage
                                                    message:scoreMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Back to Main Menu"
                                          otherButtonTitles:@"Rematch?",
                          nil];
    alert.tag = 2;
    [alert show];
}


@end
