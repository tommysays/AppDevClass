//
//  JCLGameViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLGameViewController.h"
#import "JCLGameModel.h"
#import "JCLModel.h"

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

@property JCLModel *model;
@property JCLGameModel *gameModel;
@property NSMutableArray *miniBoards;
@property NSMutableArray *highlighters;
@property UIColor *kHighlightColor;
@property NSIndexPath *curMove;
@property UIImageView *curMark;

@end

const NSInteger kMiniSize = 160;
const NSTimeInterval kHighlightFadeTime = 0.3;
const CGFloat kHighlightAlpha = 0.3;


@implementation JCLGameViewController

- (void) viewDidLoad{
    [super viewDidLoad];
    self.gameModel = [[JCLGameModel alloc] initWithPlayer1:self.player1 andPlayer2:self.player2];
    self.kHighlightColor = [UIColor whiteColor];
    self.model = [JCLModel sharedInstance];
    [self initBoards];
}

- (void) initBoards{
    self.miniBoards = [[NSMutableArray alloc] init];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    self.mBoard11.userInteractionEnabled = YES;
    [self.mBoard11 addGestureRecognizer:tap];
    [self.miniBoards addObject:self.mBoard11];
    [self addHighlighter:self.mBoard11.frame];
    
    self.mBoard12.userInteractionEnabled = YES;
    [self.mBoard12 addGestureRecognizer:tap];
    [self.miniBoards addObject:self.mBoard12];
    
    self.mBoard13.userInteractionEnabled = YES;
    [self.mBoard13 addGestureRecognizer:tap];
    [self.miniBoards addObject:self.mBoard13];
    
    self.mBoard21.userInteractionEnabled = YES;
    [self.mBoard21 addGestureRecognizer:tap];
    [self.miniBoards addObject:self.mBoard21];
    
    self.mBoard22.userInteractionEnabled = YES;
    [self.mBoard22 addGestureRecognizer:tap];
    [self.miniBoards addObject:self.mBoard22];
    
    self.mBoard23.userInteractionEnabled = YES;
    [self.mBoard23 addGestureRecognizer:tap];
    [self.miniBoards addObject:self.mBoard23];
    
    self.mBoard31.userInteractionEnabled = YES;
    [self.mBoard31 addGestureRecognizer:tap];
    [self.miniBoards addObject:self.mBoard31];
    
    self.mBoard32.userInteractionEnabled = YES;
    [self.mBoard32 addGestureRecognizer:tap];
    [self.miniBoards addObject:self.mBoard32];
    
    self.mBoard33.userInteractionEnabled = YES;
    [self.mBoard33 addGestureRecognizer:tap];
    [self.miniBoards addObject:self.mBoard33];
}

- (void) addHighlighter:(CGRect)frame{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = self.kHighlightColor;
    [self.view addSubview:view];
    view.alpha = 0.0;
    
}

#pragma mark Animators

- (void) highlightMiniBoards:(NSArray *)boardIndeces{
    
    // First, unhighlight everything. Then, highlight appropriate boards.
    
    for (NSInteger i = 0; i < [self.highlighters count]; ++i){
        UIView *view = self.highlighters[i];
        [UIView animateWithDuration:kHighlightFadeTime animations:^{
            view.alpha = 0.0;
        } completion:^(BOOL finished) {
            if ([boardIndeces containsObject:[NSNumber numberWithInteger:i]]){
                [UIView animateWithDuration:kHighlightFadeTime animations:^{
                    view.alpha = kHighlightAlpha;
                }];
            }
        }];
    }
}

- (void) removeAllHighlights{
    for (NSInteger i = 0; i < [self.highlighters count]; ++i){
        UIView *view = self.highlighters[i];
        [UIView animateWithDuration:kHighlightFadeTime animations:^{
            view.alpha = 0.0;
        }];
    }
}

// Moves the player's mark to the indicated cell.
- (void) moveToCell:(NSIndexPath *)cell{
    if (!self.curMark){
        NSInteger player = [self.gameModel isPlayer1Turn];
        UIImageView *mark = [[UIImageView alloc] initWithImage:[self.model markForPlayer:[player]]];
        mark.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:mark];
    }
}

#pragma mark Gesture Recognizer

- (void) tapRecognized:(UITapGestureRecognizer *)recognizer{
    UIView *view = recognizer.view;
    NSInteger boardIndex = view.tag;
    if ([self.gameModel isBoardEnabled:boardIndex]){
        CGPoint pt = [recognizer locationInView:recognizer.view];
        NSInteger third = kMiniSize / 3;
        NSInteger x = pt.x / third;
        NSInteger y = pt.y / third;
        NSInteger cellIndex = y * 3 + x;
        NSIndexPath *cell = [NSIndexPath indexPathForRow:cellIndex inSection:boardIndex];
        if ([self.gameModel isCellEnabled:cell]){
            [self highlightMiniBoards:[self.gameModel boardsForPretendMove:cell]];
            [self moveToCell:cell];
            self.curMove = cell;
        }
    }
}

#pragma mark Button Reactions

- (IBAction)finalizeButtonPressed:(id)sender {
    if (self.curMove){
        [self.gameModel makeMove:self.curMove];
        [self removeAllHighlights];
        self.curMove = nil;
    } else{
        // Maybe throw an alert, saying that user must make a move before finalizing.
    }
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
