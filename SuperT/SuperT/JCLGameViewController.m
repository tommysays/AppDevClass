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
@property NSMutableArray *highlighters_p1;
@property NSMutableArray *highlighters_p2;
@property UIColor *kHighlightColor_p1; // Color to highlight next movespace
@property UIColor *kHighlightColor_p2; // Color to highlight current movespace
@property NSIndexPath *curMove;
@property UIImageView *curMark;
@property UIColor *curHighlightColor;

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
    self.curHighlightColor = self.kHighlightColor_p1;
    self.model = [JCLModel sharedInstance];
    self.highlighters_p1 = [[NSMutableArray alloc] init];
    self.highlighters_p2 = [[NSMutableArray alloc] init];
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
        self.curMark = nil;
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
        } else if (buttonIndex == 1){
            // Reset game for rematch.
            self.gameModel = [[JCLGameModel alloc] initWithPlayer1:self.player1 andPlayer2:self.player2];
            [self unhighlightAll];
            // TODO more reset stuff.
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
                                          cancelButtonTitle:@"Back to Player Select"
                                          otherButtonTitles:@"Rematch?",
                          nil];
    alert.tag = 2;
    [alert show];
}


@end
