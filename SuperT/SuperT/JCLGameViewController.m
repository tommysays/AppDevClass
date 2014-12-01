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
@property NSMutableArray *marks;
@property NSMutableArray *highlighters_p1;
@property NSMutableArray *highlighters_p2;
@property NSIndexPath *curMove;
@property UIImageView *curMark;

// These are viable properties to change via Options.
@property UIColor *kHighlightColor_p1; // Color to highlight next movespace
@property UIColor *kHighlightColor_p2; // Color to highlight current movespace

@end

const NSInteger kMiniSize = 160;
const NSInteger kMarkSize = 40;
const NSTimeInterval kHighlightFadeTime = 0.3;
const CGFloat kHighlightAlpha = 0.4;



@implementation JCLGameViewController

- (void) viewDidLoad{
    [super viewDidLoad];
    self.gameModel = [[JCLGameModel alloc] initWithPlayer1:self.player1 andPlayer2:self.player2];
    self.kHighlightColor_p1 = [UIColor whiteColor];
    self.kHighlightColor_p2 = [UIColor redColor];
    self.model = [JCLModel sharedInstance];
    self.highlighters_p1 = [[NSMutableArray alloc] init];
    self.highlighters_p2 = [[NSMutableArray alloc] init];
    self.marks = [[NSMutableArray alloc] init];
    [self initBoards];
}

- (void) initBoards{
    self.miniBoards = [[NSMutableArray alloc] init];
    
    UIImageView *board = self.mBoard11;
    [self initBoard:board];
    board = self.mBoard21;
    [self initBoard:board];
    board = self.mBoard31;
    [self initBoard:board];
    board = self.mBoard12;
    [self initBoard:board];
    board = self.mBoard22;
    [self initBoard:board];
    board = self.mBoard32;
    [self initBoard:board];
    board = self.mBoard13;
    [self initBoard:board];
    board = self.mBoard23;
    [self initBoard:board];
    board = self.mBoard33;
    [self initBoard:board];
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

#pragma mark Animators

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

#pragma mark Gesture Recognizer

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
        }
    }
}

#pragma mark Button Reactions

- (IBAction)finalizeButtonPressed:(id)sender {
    if (self.curMove){
        [self.gameModel makeMove:self.curMove];
        [self unhighlightLast];
        self.curMove = nil;
        if (self.curMark){
            UIImageView *mark = self.curMark;
            [self.marks addObject:mark];
            self.curMark = nil;
        }
        if (self.gameModel.gameOver){
            NSInteger winner = self.gameModel.winner;
            switch (winner) {
                case 0:
                    [self gameOverWithWinner:self.player1 andLoser:self.player2 wasDraw:YES];
                    break;
                case 1:
                    [self gameOverWithWinner:self.player1 andLoser:self.player2 wasDraw:NO];
                    break;
                case 2:
                    [self gameOverWithWinner:self.player2 andLoser:self.player1 wasDraw:NO];
                default:
                    break;
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

- (IBAction)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1){  // ---------------------- Surrender -------------------------
        if (buttonIndex == 1){
            Player *winner;
            Player *loser;
            if (self.gameModel.isPlayer1Turn){
                winner = self.player2;
                loser = self.player1;
            } else{
                winner = self.player1;
                loser = self.player2;
            }
            [self gameOverWithWinner:winner andLoser:loser wasDraw:NO];
        }
    } else if (alertView.tag == 2){ // ---------------- Game Over -------------------------
        if (buttonIndex == 0){
            [self.navigationController popViewControllerAnimated:YES];
        } else if (buttonIndex == 1){
            // Reset the game and board.
            
            // Reset game model.
            self.gameModel = [[JCLGameModel alloc] initWithPlayer1:self.player1 andPlayer2:self.player2];
            
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
            
            // TODO more reset stuff.
        }
    }
}

- (void) gameOverWithWinner:(Player *)winner andLoser:(Player *)loser wasDraw:(BOOL)isDraw{
    
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
    [score winAgainst:loser.playerID];
    
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


@end
