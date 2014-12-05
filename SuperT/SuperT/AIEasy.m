//
//  AIEasy.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/5/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "AIEasy.h"

@implementation AIEasy

- (NSIndexPath *) makeMove:(NSArray *)board withAvailableBoards:(NSArray *)available asPlayer:(NSInteger)playerTurn{
    NSInteger opponentMark = playerTurn == 1 ? 2 : 1;
    NSInteger playerMark = playerTurn;
    
    // General approach: Calculates values of all possible moves, looking only 1 ahead.
    
    NSInteger bestValue = 0;
    NSIndexPath *bestMove;
    
    for (NSNumber *num in available){
        NSInteger boardIndex = [num integerValue];
        NSArray *miniboard = board[boardIndex];
        // Calculate a value for each possible move.
        for (NSInteger i = 0; i < 9; i++){
            if ([miniboard[i] integerValue] == 0){
                // If a move's value is better than the current one, replace it.
                
            }
        }
        
        
    }
    
    return bestMove;
}

@end
