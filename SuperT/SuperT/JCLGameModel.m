//
//  JCLGameModel.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLGameModel.h"
#import "JCLModel.h"

@interface JCLGameModel ()

@property NSMutableArray *moveHistory;
@property Player *player1;
@property Player *player2;
@property AI *ai;

@property NSMutableArray *enabledBoards;
@property NSArray *availableBoards;
@property NSMutableArray *boards;
@property JCLModel *model;


@end

@implementation JCLGameModel

#pragma mark - Initialization

+ (id) sharedInstance{
    static id singleton;
    @synchronized(self){
        if (!singleton){
            singleton = [[self alloc] init];
        }
    }
    return singleton;
}

- (id) init{
    self = [super init];
    if (self){
        [self initLists];
        [self initBoards];
        self.isPlayer1Turn = YES;
        self.lastBoardWasWon = NO;
        self.gameOver = NO;
        self.winner = 0;
        self.model = [JCLModel sharedInstance];
    }
    return self;
}

- (void) initBoards{
    self.enabledBoards = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 9; ++i){
        [self.enabledBoards addObject:[NSNumber numberWithInt:-1]];
    }
    
    self.boards = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 9; ++i){
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (NSInteger j = 0; j < 9; ++j){
            [temp addObject:[NSNumber numberWithInt:-1]];
        }
        [self.boards addObject:temp];
    }
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 9; ++i){
        [temp addObject:[NSNumber numberWithInteger:i]];
    }
    self.availableBoards = temp;
}

- (id) initWithPlayer1:(Player *)player1 andPlayer2:(Player *)player2{
    self = [self init];
    if (self){
        self.player1 = player1;
        self.player2 = player2;
    }
    return self;
}

- (id) initWithPlayer1:(Player *)player1 andAI:(AI *)ai{
    self = [self init];
    if (self){
        self.player1 = player1;
        self.ai = ai;
    }
    return self;
}

- (void) initLists{
    self.moveHistory = [[NSMutableArray alloc] init];
}

#pragma mark - Accessors

- (BOOL) isBoardAvailable:(NSInteger)index{
    if ([self.availableBoards containsObject:[NSNumber numberWithInteger:index]])
        return true;
    return false;
}

- (BOOL) isCellEnabled:(NSIndexPath *)path{
    NSArray *miniBoard = self.boards[path.section];
    return ([self isBoardEnabled:path.section] && [miniBoard[path.row] integerValue] == -1);
}

- (BOOL) isBoardEnabled:(NSInteger)index{
    if ([self.enabledBoards[index] integerValue] > -1) {
        return false;
    }
    return true;
}

- (NSArray *) allEnabledBoards{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 9; ++i){
        if ([self isBoardEnabled:i])
            [temp addObject:[NSNumber numberWithInteger:i]];
    }
    return temp;
}

- (NSArray *) allAvailableBoards{
    return self.availableBoards;
}

- (NSArray *) wholeBoard{
    return self.boards;
}

- (BOOL) wasLastBoardWon{
    return self.lastBoardWasWon;
}

- (NSArray *) boardsForPretendMove:(NSIndexPath *)move{
    NSInteger cell = move.row;
    
    NSInteger toFill = self.isPlayer1Turn ? 1 : 2;
    NSMutableArray *miniBoard = [self.boards objectAtIndex:move.section];
    NSInteger curFill = [miniBoard[move.row] integerValue];
    
    // Fake the move
    miniBoard[move.row] = [NSNumber numberWithInteger:toFill];
    
    [self evaluateMiniBoard:move.row];
    
    NSArray *toReturn;
    if ([self isBoardEnabled:cell]){
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        [temp addObject:[NSNumber numberWithInteger:cell]];
        toReturn = temp;
    } else{
        toReturn = [self allEnabledBoards];
    }
    
    // Undo the move
    miniBoard[move.row] = [NSNumber numberWithInteger:curFill];
    
    return toReturn;
}

#pragma mark - Mutators

- (void) recordMove:(NSIndexPath *)move withMark:(NSString *)mark andFill:(NSInteger)fill{
    // Record the move
    NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
    [entry setObject:move forKey:@"move"];
    [entry setObject:mark forKey:@"player"];
    [self.moveHistory addObject:entry];
    
    // Actually make the move
    NSMutableArray *miniBoard = [self.boards objectAtIndex:move.section];
    miniBoard[move.row] = [NSNumber numberWithInteger:fill];
}

// Makes a move on the board, record the move, and returns whether or not a mini-board was won.
- (BOOL) makeMove:(NSIndexPath *)move{
    NSString *mark = @"";
    NSInteger toFill = -1;
    if (self.isPlayer1Turn){
        toFill = 1;
        mark = [NSString stringWithFormat:@"%@ plays x", self.player1.name];
    } else{
        toFill = 2;
        // Records either player2's name or name of ai.
        NSString *name = self.player2 ? self.player2.name : self.ai.name;
        mark = [NSString stringWithFormat:@"%@ plays o", name];
    }
    [self recordMove:move withMark:mark andFill:toFill];
    [self evaluateMiniBoard:move.section];
    [self evaluateGameOver];
    self.availableBoards = [self boardsForPretendMove:move];
    
    // If the move was not the game-winning move, switch player turns.
    if (!self.gameOver){
        self.isPlayer1Turn = !self.isPlayer1Turn;
    }

    return self.lastBoardWasWon;
}

#pragma mark - Misc.

// Evaluates whether or not the game has reached a conclusion.
- (void) evaluateGameOver{
    NSInteger fill = -1;
    NSArray *board = self.enabledBoards;
    NSNumber *neg1 = [NSNumber numberWithInteger:-1];
    if (board[0] != neg1 &&
        ((board[0] == board[1] && board[0] == board[2]) ||
         (board[0] == board[3] && board[0] == board[6])))
    {
        fill = [board[0] integerValue];
    } else if (board[8] != neg1 &&
               ((board[8] == board[7] && board[8] == board[6]) ||
                (board[8] == board[5] && board[8] == board[2])))
    {
        fill = [board[8] integerValue];
    } else if (board[4] != neg1 &&
               (
                (board[4] == board[0] && board[4] == board[8]) ||
                (board[4] == board[1] && board[4] == board[7]) ||
                (board[4] == board[2] && board[4] == board[6]) ||
                (board[4] == board[3] && board[4] == board[5])))
    {
        fill = [board[4] integerValue];
    } else if ([self gameIsCompletelyFilled])
    {
        fill = 0;
    }
    
    if (fill >= 0){
        self.gameOver = YES;
        self.winner = fill;
    }
}

// Evaluates whether or not a mini-board has concluded.
- (void) evaluateMiniBoard:(NSInteger)index{
    NSInteger fill = -1;
    NSArray *miniBoard = [self.boards objectAtIndex:index];
    NSNumber *neg1 = [NSNumber numberWithInteger:-1];
    
    // If a winning move was played, or if the miniboard ended in a draw,
    // set enabledBoards to the winning player's fill value (1 or 2), or 0 for draw.
    
    // Normally I don't format like this, but XCode wouldn't cooperate with me otherwise.
    if (miniBoard[0] != neg1 &&
        ((miniBoard[0] == miniBoard[1] && miniBoard[0] == miniBoard[2]) ||
         (miniBoard[0] == miniBoard[3] && miniBoard[0] == miniBoard[6])))
    {
        fill = [miniBoard[0] integerValue];
    } else if (miniBoard[8] != neg1 &&
               ((miniBoard[8] == miniBoard[7] && miniBoard[8] == miniBoard[6]) ||
                (miniBoard[8] == miniBoard[5] && miniBoard[8] == miniBoard[2])))
    {
        fill = [miniBoard[8] integerValue];
    } else if (miniBoard[4] != neg1 &&
               (
                (miniBoard[4] == miniBoard[0] && miniBoard[4] == miniBoard[8]) ||
                (miniBoard[4] == miniBoard[1] && miniBoard[4] == miniBoard[7]) ||
                (miniBoard[4] == miniBoard[2] && miniBoard[4] == miniBoard[6]) ||
                (miniBoard[4] == miniBoard[3] && miniBoard[4] == miniBoard[5])))
    {
        fill = [miniBoard[4] integerValue];
    } else if ([self miniBoardIsCompletelyFilled:index])
    {
        fill = 0;
    }
    
    self.enabledBoards[index] = [NSNumber numberWithInteger:fill];
    if (fill >= 0){
        self.lastBoardWasWon = YES;
    } else{
        self.lastBoardWasWon = NO;
    }
}

- (BOOL) gameIsCompletelyFilled{
    NSArray *board = self.enabledBoards;
    NSNumber *neg1 = [NSNumber numberWithInteger:-1];

    if (board[0] != neg1 &&
        board[1] != neg1 &&
        board[2] != neg1 &&
        board[3] != neg1 &&
        board[4] != neg1 &&
        board[5] != neg1 &&
        board[6] != neg1 &&
        board[7] != neg1)
        return true;
    
    return false;
}

- (BOOL) miniBoardIsCompletelyFilled:(NSInteger)index{
    NSArray *miniBoard = [self.boards objectAtIndex:index];
    NSNumber *neg1 = [NSNumber numberWithInteger:-1];
    
    if (miniBoard[0] != neg1 &&
        miniBoard[1] != neg1 &&
        miniBoard[2] != neg1 &&
        miniBoard[3] != neg1 &&
        miniBoard[4] != neg1 &&
        miniBoard[5] != neg1 &&
        miniBoard[6] != neg1 &&
        miniBoard[7] != neg1)
        return true;
    
    return false;
}

@end
