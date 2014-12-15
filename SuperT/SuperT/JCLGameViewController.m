//
//  JCLGameViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLGameViewController.h"
#import "JCLOptionsViewController.h"
#import "JCLGameModel.h"
#import "JCLModel.h"
#import "SoundManager.h"

#import "ComputerAI.h"
#import "AIEasy.h"
#import "AIMedium.h"

@interface JCLGameViewController () <UIAlertViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *mBoards;
@property (weak, nonatomic) IBOutlet UIImageView *gameBoard;
@property (weak, nonatomic) IBOutlet UILabel *turnLabel;
- (IBAction)positivePressed:(id)sender;
- (IBAction)negativePressed:(id)sender;

- (IBAction)finalizeButtonPressed:(id)sender;
- (IBAction)surrenderButtonPressed:(id)sender;
- (IBAction)exitButtonPressed:(id)sender;

@property JCLModel *model;
@property JCLGameModel *gameModel;
@property SoundManager *soundManager;
@property NSMutableArray *miniBoards;
@property NSMutableArray *marks;
@property NSMutableArray *highlighters_p1;
@property NSMutableArray *highlighters_p2;
@property NSIndexPath *curMove;
@property UIImageView *curMark;
@property ComputerAI *aiPlayer;

// These are viable properties to change via Options.
@property UIColor *kHighlightColor_p1; // Color to highlight next movespace
@property UIColor *kHighlightColor_p2; // Color to highlight current movespace

@end

const NSInteger kMiniSize = 160;
const NSInteger kMarkSize = 40;
const NSTimeInterval kHighlightFadeTime = 0.3;
const CGFloat kHighlightAlpha = 0.4;



@implementation JCLGameViewController

#pragma mark - Initialization

- (void) viewDidLoad{
    [super viewDidLoad];
    
    self.model = [JCLModel sharedInstance];
    self.soundManager = [SoundManager sharedInstance];
    self.gameModel = [[JCLGameModel alloc] initWithPlayer1:self.player1 andPlayer2:self.player2];
    
    self.kHighlightColor_p1 = [UIColor whiteColor];
    self.kHighlightColor_p2 = [UIColor redColor];
    self.highlighters_p1 = [[NSMutableArray alloc] init];
    self.highlighters_p2 = [[NSMutableArray alloc] init];
    self.marks = [[NSMutableArray alloc] init];
    
    if (self.ai){
        [self initAI];
    }
    
    [self updateTurnLabel];
    [self initBoards];
    
    [self.soundManager playStartGame];
}

- (void) initAI{
    NSString *name = self.ai.name;
    if ([name isEqualToString:@"Easy AI"]){
        self.aiPlayer = [[AIEasy alloc] initWithGameModel:self.gameModel];
    } else if ([name isEqualToString:@"Medium AI"]){
        self.aiPlayer = [[AIMedium alloc] initWithGameModel:self.gameModel];
    }
}

- (void) initBoards{
    self.miniBoards = [[NSMutableArray alloc] init];
    
    for (UIImageView *board in self.mBoards){
        [self initBoard:board];
    }
}

- (void) initBoard:(UIImageView *)board{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    board.userInteractionEnabled = YES;
    [board addGestureRecognizer:tap];
    [self.miniBoards addObject:board];
    
    // Add highlighter for p1
    UIView *view = [self addHighlighter:board.frame];
    view.backgroundColor = self.kHighlightColor_p1;
    [self.highlighters_p1 addObject:view];
    
    // Add highlighter for p2
    view = [self addHighlighter:board.frame];
    view.backgroundColor = self.kHighlightColor_p2;
    [self.highlighters_p2 addObject:view];
    
    [self.view bringSubviewToFront:board];
}

- (UIView *) addHighlighter:(CGRect)frame{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:view];
    view.alpha = 0.0;
    return view;
}

#pragma mark - Animators

- (void) highlightMiniBoards:(NSArray *)boardIndeces{
    
    NSArray *highlighters;
    
    if (self.gameModel.isPlayer1Turn)
        highlighters = self.highlighters_p2;
    else
        highlighters = self.highlighters_p1;
    
    // First, unhighlight everything. Then, highlight appropriate boards.
    
    for (NSInteger i = 0; i < [highlighters count]; ++i){
        UIView *view = highlighters[i];
        if (![boardIndeces containsObject:[NSNumber numberWithInteger:i]]){
            [UIView animateWithDuration:kHighlightFadeTime animations:^{
                view.alpha = 0.0;
            }];
        } else{
            [UIView animateWithDuration:kHighlightFadeTime animations:^{
                view.alpha = kHighlightAlpha;
            }];
        }
    }
}

- (void) unhighlightLast{
    NSArray *highlighters;
    
    if (self.gameModel.isPlayer1Turn)
        highlighters = self.highlighters_p2;
    else
        highlighters = self.highlighters_p1;
    
    for (NSInteger i = 0; i < [highlighters count]; ++i){
        UIView *view = highlighters[i];
        [UIView animateWithDuration:kHighlightFadeTime animations:^{
            view.alpha = 0.0;
        }];
    }
}

- (void) unhighlightAll{
    NSArray *highlighters;
    highlighters = self.highlighters_p1;
    for (NSInteger i = 0; i < [highlighters count]; ++i){
        UIView *view = highlighters[i];
        [UIView animateWithDuration:kHighlightFadeTime animations:^{
            view.alpha = 0.0;
        }];
    }
    highlighters = self.highlighters_p2;
    for (NSInteger i = 0; i < [highlighters count]; ++i){
        UIView *view = highlighters[i];
        [UIView animateWithDuration:kHighlightFadeTime animations:^{
            view.alpha = 0.0;
        }];
    }
}

// Moves the player's mark to the indicated cell.
- (void) moveToCell:(NSInteger)cell inView:(UIView *)view{
    if (self.curMark){
        UIView *mark = self.curMark;
        [UIView animateWithDuration:kHighlightFadeTime animations:^{
            mark.alpha = 0.0;
        } completion:^(BOOL finished) {
            [mark removeFromSuperview];
        }];
    }
    NSInteger player = [self.gameModel isPlayer1Turn];
    self.curMark = [[UIImageView alloc] initWithImage:[self.model markForPlayer:player]];
    self.curMark.contentMode = UIViewContentModeScaleAspectFit;
    self.curMark.tag = [self.gameModel isPlayer1Turn] ? 1 : 2;
    [self.view addSubview:self.curMark];
    NSInteger third = kMiniSize / 3;
    NSInteger cellX = (cell % 3) * third + ((third - kMarkSize) / 2);
    NSInteger cellY = (cell / 3) * third + ((third - kMarkSize) / 2);
    CGRect frame = CGRectMake(view.frame.origin.x + cellX, view.frame.origin.y + cellY, kMarkSize, kMarkSize);
    self.curMark.frame = frame;
    self.curMark.alpha = 0.0;
    [UIView animateWithDuration:kHighlightFadeTime animations:^{
        self.curMark.alpha = 1.0;
    }];
}

- (void) updateTurnLabel{
    NSString *name;
    if ([self.gameModel isPlayer1Turn]){
        name = self.player1.name;
    } else{
        name = self.player2 ? self.player2.name : self.ai.name;
    }
    self.turnLabel.text = [NSString stringWithFormat:@"%@'s turn!", name];
}

#pragma mark - Gesture Recognizer

- (void) tapRecognized:(UITapGestureRecognizer *)recognizer{
    UIView *view = recognizer.view;
    NSInteger boardIndex = view.tag;
    if ([self.gameModel isBoardAvailable:boardIndex]){
        CGPoint pt = [recognizer locationInView:recognizer.view];
        NSInteger third = kMiniSize / 3;
        NSInteger x = pt.x / third;
        NSInteger y = pt.y / third;
        NSInteger cellIndex = y * 3 + x;
        NSIndexPath *cell = [NSIndexPath indexPathForRow:cellIndex inSection:boardIndex];
        if ([self.gameModel isCellEnabled:cell]){
            [self highlightMiniBoards:[self.gameModel boardsForPretendMove:cell]];
            [self moveToCell:cellIndex inView:view];
            self.curMove = cell;
            
            NSInteger turn = self.gameModel.isPlayer1Turn ? 1 : 2;
            [self.soundManager playTapForPlayer:turn];
        }
    }
}

#pragma mark - AI Interaction

- (void) launchAITimer{
    [NSTimer scheduledTimerWithTimeInterval:kAIThinkingDelay target:self selector:@selector(makeAIMove) userInfo:nil repeats:NO];
}

- (void) makeAIMove{
    // Get move from ai.
    NSIndexPath *move = [self.aiPlayer makeMove];
    if (!move){
        // If this occurs, then the AI logic is faulty.
        NSLog(@"Error : Could not make move (ai). Check AI logic.");
    }
    self.curMove = move;
    // Place the move on the board (visually) and highlight the appropriate miniboards.
    UIView *miniboard = self.miniBoards[self.curMove.section];
    [self highlightMiniBoards:[self.gameModel boardsForPretendMove:move]];
    [self moveToCell:move.row inView:miniboard];
    
    // Make another timer that will finalize move.
    [NSTimer scheduledTimerWithTimeInterval:kAIFinalizeDelay target:self selector:@selector(pushFinalize) userInfo:nil repeats:NO];
}

- (void) pushFinalize{
    // Pushes the finalize button.
    [self finalizeButtonPressed:self];
    self.view.userInteractionEnabled = YES;
}
 
#pragma mark - Button Reactions

- (IBAction)positivePressed:(id)sender {
    [self.soundManager playConfirmButton];
}

- (IBAction)negativePressed:(id)sender {
    [self.soundManager playBackButton];
}

- (IBAction)finalizeButtonPressed:(id)sender {
    if (self.curMove){
        NSInteger turn = self.gameModel.isPlayer1Turn ? 1 : 2;
        [self.gameModel makeMove:self.curMove];
        [self unhighlightLast];
        self.curMove = nil;
        
        // If the current player's mark has been placed, save it to the board and reset mark.
        if (self.curMark){
            UIImageView *mark = self.curMark;
            [self.marks addObject:mark];
            self.curMark = nil;
        }
        
        if (self.gameModel.gameOver){
            NSInteger winner = self.gameModel.winner;
            Player *p2 = self.player2 ? self.player2 : self.ai;
            
            switch (winner) {
                case 0:
                    [self gameOverWithWinner:self.player1 andLoser:p2 wasDraw:YES];
                    break;
                case 1:
                    [self gameOverWithWinner:self.player1 andLoser:p2 wasDraw:NO];
                    break;
                case 2:
                    [self gameOverWithWinner:p2 andLoser:self.player1 wasDraw:NO];
                default:
                    break;
            }
        } else{
            [self.soundManager playFinalizeForPlayer:turn];
            [self updateTurnLabel];
            // If this is single player game and it is AI's turn, launch the AI timer.
            if (self.ai && !self.gameModel.isPlayer1Turn){
                self.view.userInteractionEnabled = NO;
                [self launchAITimer];
            }
        }
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't move."
                                                        message:@"You must place a move before you can finalize it."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        alert.tag = 3;
        [alert show];
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

#pragma mark - Alert Reactions

- (IBAction)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1){  // ---------------------- Surrender -------------------------
        if (buttonIndex == 1){
            Player *winner;
            Player *loser;
            if (self.gameModel.isPlayer1Turn){
                winner = self.player2 ? self.player2 : self.ai;
                loser = self.player1;
            } else{
                winner = self.player1;
                loser = self.player2 ? self.player2 : self.ai;
            }
            [self gameOverWithWinner:winner andLoser:loser wasDraw:NO];
        }
    } else if (alertView.tag == 2){ // ---------------- Game Over -------------------------
        if (buttonIndex == 0){
            // User wants to go back to player chooser.
            [self.soundManager playBackButton];
            [self.navigationController popViewControllerAnimated:YES];
        } else if (buttonIndex == 1){
            // Reset the game and board.
            
            // Reset game model.
            self.gameModel = [[JCLGameModel alloc] initWithPlayer1:self.player1 andPlayer2:self.player2];
            
            // Reset AI
            [self initAI];
            
            // Unhighlight everything.
            [self unhighlightAll];
            
            // Remove all marks from board, including any temporary ones (curMark).
            if (self.curMark){
                [self.curMark removeFromSuperview];
                self.curMark = nil;
            }
            for (UIImageView *view in self.marks){
                [view removeFromSuperview];
            }
            
            // Play the start game sound again.
            [self.soundManager playStartGame];
        }
    }
}

- (void) gameOverWithWinner:(Player *)winner andLoser:(Player *)loser wasDraw:(BOOL)isDraw{
    
    [self.soundManager playGameOver];
    Score *score = [self.model scoreBetweenPlayers:@[winner, loser]];
    
    if (isDraw){
        // Game was a draw.
        // Show a concluding message with an option to rematch.
        NSString *victoryMessage = [NSString stringWithFormat:@"No one won the game!"];
        NSString *scoreMessage = [NSString stringWithFormat:@"Score: %d to %d", [score winsForPlayerID:winner.playerID], [score winsForPlayerID:loser.playerID]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:victoryMessage
                                                        message:scoreMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Back to Player Select"
                                              otherButtonTitles:@"Rematch?",
                              nil];
        alert.tag = 2;
        [alert show];
        return;
    }
    // Otherwise, game concluded with a winner.
    
    // Update player profiles to reflect conclusion.
    [self.model updateScore:score withWinner:winner];
    
    // Show a concluding message with an option to rematch.
    NSString *victoryMessage = [NSString stringWithFormat:@"%@ won the game!", winner.name];
    NSString *scoreMessage = [NSString stringWithFormat:@"Score: %d to %d", [score winsForPlayerID:winner.playerID]  , [score winsForPlayerID:loser.playerID]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:victoryMessage
                                                    message:scoreMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Back to Player Select"
                                          otherButtonTitles:@"Rematch?",
                          nil];
    alert.tag = 2;
    [alert show];
}

#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"GameToOptions"]){
        JCLOptionsViewController *destController = segue.destinationViewController;
        destController.gameController = self;
    }
}

#pragma mark - Reset Marks

- (void) resetMarks{
    for (UIImageView *mark in self.marks){
        mark.image = [self.model markForPlayer:mark.tag];
    }
    if (self.curMark){
        self.curMark.image = [self.model markForPlayer:self.curMark.tag];
    }
}

@end
