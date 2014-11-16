//
//  JCLGameModel.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLGameModel.h"

@interface JCLGameModel ()

@property NSMutableArray *moveHistory;
@property JCLPlayer *player1;
@property JCLPlayer *player2;

@property NSMutableArray *enabledBoards;
@property NSMutableArray *boards;
@property NSArray *availableBoards;


@end

@implementation JCLGameModel

#pragma mark Initialization

- (id) init{
    self = [super init];
    if (self){
        [self initLists];
        [self initBoards];
        self.isPlayer1Turn = YES;
        self.lastBoardWasWon = NO;
        self.gameOver = NO;
        self.winner = 0;
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

- (id) initWithPlayer1:(JCLPlayer *)player1 andPlayer2:(JCLPlayer *)player2{
    self = [self init];
    if (self){
        self.player1 = player1;
        self.player2 = player2;
    }
    return self;
}

- (void) initLists{
    self.moveHistory = [[NSMutableArray alloc] init];
}

#pragma mark Accessors

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

- (BOOL) wasLastBoardWon{
    return self.lastBoardWasWon;
}

- (NSArray *) boardsForPretendMove:(NSIndexPath *)move{
    NSInteger cell = move.row;
    if ([self isBoardEnabled:cell]){
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        [temp addObject:[NSNumber numberWithInteger:cell]];
        return temp;
    } else{
        NSLog(@"All enabled boards are now available.");
        return [self allEnabledBoards];
    }
}

#pragma mark Mutators

- (void) recordMove:(NSIndexPath *)move withMark:(NSString *)mark andFill:(NSInteger)fill{
    NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
    [entry setObject:move forKey:@"move"];
    [entry setObject:mark forKey:@"player"];
    [self.moveHistory addObject:entry];
    NSMutableArray *miniBoard = [self.boards objectAtIndex:move.section];
    miniBoard[move.row] = [NSNumber numberWithInteger:fill];
}

// Makes a move on the board, record the move, and returns whether or not a mini-board was won.
- (BOOL) makeMove:(NSIndexPath *)move{
    NSString *mark = @"";
    NSInteger toFill = -1;
    if (self.isPlayer1Turn){
        toFill = 1;
        mark = @"x";
    } else{
        toFill = 2;
        mark = @"o";
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

#pragma mark Misc.

// Evaluates whether or not the game has reached a conclusion.
- (void) evaluateGameOver{
    NSInteger fill = -1;
    NSArray *wholeBoard = self.enabledBoards;
    if ((wholeBoard[0] == wholeBoard[1] && wholeBoard[0] == wholeBoard[2]) ||
        (wholeBoard[0] == wholeBoard[3] && wholeBoard[0] == wholeBoard[6])){
        fill = [wholeBoard[0] integerValue];
    } else if ((wholeBoard[8] == wholeBoard[7] && wholeBoard[8] == wholeBoard[6]) ||
               (wholeBoard[8] == wholeBoard[5] && wholeBoard[8] == wholeBoard[2])){
        fill = [wholeBoard[8] integerValue];
    } else if ((wholeBoard[4] == wholeBoard[0] && wholeBoard[4] == wholeBoard[8]) ||
               (wholeBoard[4] == wholeBoard[1] && wholeBoard[4] == wholeBoard[7]) ||
               (wholeBoard[4] == wholeBoard[2] && wholeBoard[4] == wholeBoard[6]) ||
               (wholeBoard[4] == wholeBoard[3] && wholeBoard[4] == wholeBoard[5])){
        fill = [wholeBoard[4] integerValue];
    } else if ([self gameIsCompletelyFilled]){
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
    
    // If a winning move was played, or if the miniboard ended in a draw,
    // set enabledBoards to the winning player's fill value (1 or 2), or 0 for draw.
    
    if ((miniBoard[0] == miniBoard[1] && miniBoard[0] == miniBoard[2]) ||
        (miniBoard[0] == miniBoard[3] && miniBoard[0] == miniBoard[6])){
        fill = [miniBoard[0] integerValue];
    } else if ((miniBoard[8] == miniBoard[7] && miniBoard[8] == miniBoard[6]) ||
               (miniBoard[8] == miniBoard[5] && miniBoard[8] == miniBoard[2])){
        fill = [miniBoard[8] integerValue];
    } else if ((miniBoard[4] == miniBoard[0] && miniBoard[4] == miniBoard[8]) ||
               (miniBoard[4] == miniBoard[1] && miniBoard[4] == miniBoard[7]) ||
               (miniBoard[4] == miniBoard[2] && miniBoard[4] == miniBoard[6]) ||
               (miniBoard[4] == miniBoard[3] && miniBoard[4] == miniBoard[5])){
        fill = [miniBoard[4] integerValue];
    } else if ([self miniBoardIsCompletelyFilled:index]){
        fill = 0;
    }
    
    self.enabledBoards[index] = [NSNumber numberWithInteger:fill];
    if (fill >= 0){
        NSLog(@"Miniboard concluded with fill = %d", fill);
        self.lastBoardWasWon = YES;
    }
}

- (BOOL) gameIsCompletelyFilled{
    NSArray *board = self.boards;
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
