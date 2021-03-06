//
//  JCLGameModel.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "AI.h"

@interface JCLGameModel : NSObject

@property BOOL isPlayer1Turn;
@property BOOL lastBoardWasWon;
@property BOOL gameOver;
@property NSInteger winner;

+ (id) sharedInstance;

- (id) initWithPlayer1:(Player *)player1 andPlayer2:(Player *)player2;
- (id) initWithPlayer1:(Player *)player1 andAI:(AI *)ai;

- (BOOL) isCellEnabled:(NSIndexPath *)path;
- (BOOL) isBoardAvailable:(NSInteger)index;
- (BOOL) isBoardEnabled:(NSInteger)index;
- (BOOL) wasLastBoardWon;

- (NSArray *) boardsForPretendMove:(NSIndexPath *)move;
- (NSArray *) allAvailableBoards;
- (NSArray *) wholeBoard;

// Returns true if the move ended the game.
- (BOOL) makeMove:(NSIndexPath *)move;

@end
