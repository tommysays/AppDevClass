//
//  JCLGameViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLGameViewController.h"
#import "JCLGameModel.h"

@interface JCLGameViewController () <UIAlertViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *mBoard11;
@property (weak, nonatomic) IBOutlet UIImageView *mBoard21;
@property (weak, nonatomic) IBOutlet UIImageView *mBoard31;
@property (weak, nonatomic) IBOutlet UIImageView *mBoard12;
@property (weak, nonatomic) IBOutlet UIImageView *mBoard22;
@property (weak, nonatomic) IBOutlet UIImageView *mBoard32;
@property (weak, nonatomic) IBOutlet UIImageView *mBoard13;
@property (weak, nonatomic) IBOutlet UIImageView *mBoard23;
@property (weak, nonatomic) IBOutlet UIImageView *mBoard33;
@property (weak, nonatomic) IBOutlet UIImageView *gameBoard;

- (IBAction)finalizeButtonPressed:(id)sender;
- (IBAction)surrenderButtonPressed:(id)sender;
- (IBAction)exitButtonPressed:(id)sender;

@property JCLGameModel *gameModel;
@property NSArray *miniBoards;

@end

const NSInteger kMiniSize = 160;


@implementation JCLGameViewController

- (void) viewDidLoad{
    [super viewDidLoad];
    self.gameModel = [[JCLGameModel alloc] initWithPlayer1:self.player1 andPlayer2:self.player2];
    
    [self initBoards];
}

- (void) initBoards{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    self.mBoard11.userInteractionEnabled = YES;
    [self.mBoard11 addGestureRecognizer:tap];
    [temp addObject:self.mBoard11];
    self.mBoard12.userInteractionEnabled = YES;
    [self.mBoard12 addGestureRecognizer:tap];
    [temp addObject:self.mBoard12];
    self.mBoard13.userInteractionEnabled = YES;
    [self.mBoard13 addGestureRecognizer:tap];
    [temp addObject:self.mBoard13];
    self.mBoard21.userInteractionEnabled = YES;
    [self.mBoard21 addGestureRecognizer:tap];
    [temp addObject:self.mBoard21];
    self.mBoard22.userInteractionEnabled = YES;
    [self.mBoard22 addGestureRecognizer:tap];
    [temp addObject:self.mBoard22];
    self.mBoard23.userInteractionEnabled = YES;
    [self.mBoard23 addGestureRecognizer:tap];
    [temp addObject:self.mBoard23];
    self.mBoard31.userInteractionEnabled = YES;
    [self.mBoard31 addGestureRecognizer:tap];
    [temp addObject:self.mBoard31];
    self.mBoard32.userInteractionEnabled = YES;
    [self.mBoard32 addGestureRecognizer:tap];
    [temp addObject:self.mBoard32];
    self.mBoard33.userInteractionEnabled = YES;
    [self.mBoard33 addGestureRecognizer:tap];
    [temp addObject:self.mBoard33];
    self.miniBoards = temp;
}

#pragma mark Gesture Recognizer

- (void) tapRecognized:(UITapGestureRecognizer *)recognizer{
    UIView *view = recognizer.view;
    NSInteger index = view.tag;
    if ([self.gameModel isBoardEnabled:index]){
        
    }
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
    // If tag == 1, we are in "Surrender" alert. If tag == 2, we are in "Game Over" alert.
    if (alertView.tag == 1){
        if (buttonIndex == 1){
            JCLPlayer *winner;
            JCLPlayer *loser;
            if (self.gameModel.isPlayer1Turn){
                winner = self.player2;
                loser = self.player1;
            } else{
                winner = self.player1;
                loser = self.player2;
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
