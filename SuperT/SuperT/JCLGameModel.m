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
@property BOOL lastBoardWasWon;
@property BOOL gameOver;

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

#pragma mark Mutators

- (void) recordMove:(NSIndexPath *)move withMark:(NSString *)mark andFill:(NSInteger)fill{
    NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
    [entry setObject:move forKey:@"move"];
    [entry setObject:mark forKey:@"player"];
    [self.moveHistory addObject:entry];
    NSMutableArray *miniBoard = [self.boards objectAtIndex:move.row];
    miniBoard[move.section] = [NSNumber numberWithInteger:fill];
}

- (BOOL) makeMoveOnBoard:(NSInteger)boardIndex forCell:(NSInteger)cellIndex{
    NSString *mark = @"";
    NSInteger toFill = -1;
    if (self.isPlayer1Turn){
        toFill = 1;
        mark = @"x";
    } else{
        toFill = 2;
        mark = @"o";
    }
    NSIndexPath *move = [NSIndexPath indexPathForRow:boardIndex inSection:cellIndex];
    [self recordMove:move withMark:mark andFill:toFill];
    [self evaluateMiniBoard:boardIndex];
    
    if (self.lastBoardWasWon){
        // Check to see if the game is over.
        [self evaluateGameOver];
    }
    
    
    // If the move was not the game-winning move, switch player turns.
    if (!self.gameOver){
        self.isPlayer1Turn = self.isPlayer1Turn;
    }

    return self.lastBoardWasWon;
}

#pragma mark Misc.

// Evaluates whether or not the game has reached a conclusion.
- (void) evaluateGameOver{
    
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
        self.lastBoardWasWon = YES;
    }
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
