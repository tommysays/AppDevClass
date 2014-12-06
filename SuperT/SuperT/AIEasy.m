//
//  AIEasy.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/5/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "AIEasy.h"

@implementation AIEasy

- (NSIndexPath *) makeMove{
    BOOL p1turn = [self.gameModel isPlayer1Turn];
    NSInteger playerMark = p1turn ? 1 : 2;
    
    // General approach: Calculates values of all possible moves, looking only 1 ahead.
    
    NSInteger bestValue = -1;
    NSIndexPath *bestMove;
    NSArray *board = [self.gameModel wholeBoard];
    for (NSNumber *num in [self.gameModel allAvailableBoards]){
        NSInteger boardIndex = [num integerValue];
        NSArray *miniboard = board[boardIndex];
        // Calculate a value for each possible move.
        for (NSInteger i = 0; i < 9; i++){
            if ([miniboard[i] integerValue] < 0){
                NSInteger curValue = 0;
                
                // Calculate value for move
                if ([self canWinBoard:[miniboard mutableCopy] withIndex:i andPlayer:playerMark]){
                    curValue++;
                }
                
                // Replace best move and value if needed.
                if (!bestMove || curValue > bestValue){
                    bestValue = curValue;
                    bestMove = [NSIndexPath indexPathForRow:i inSection:boardIndex];
                }
            }
        }
        
        
    }
    
    return bestMove;
}

- (BOOL) canWinBoard:(NSMutableArray *)miniBoard withIndex:(NSInteger)index andPlayer:(NSInteger)player{
    NSNumber *neg1 = [NSNumber numberWithInteger:-1];
    NSInteger fill = -1;
    
    miniBoard[index] = [NSNumber numberWithInteger:player];
    
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
    }
    /*
    else if ([self miniBoardIsCompletelyFilled:index])
    {
        fill = 0;
    }
    */
    
    return fill == player;
}

@end
