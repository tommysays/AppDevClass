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
    
    // General approach: Chooses a valid move at random.
    
    NSArray *board = [self.gameModel wholeBoard];
    NSMutableArray *possibleMoves = [[NSMutableArray alloc] init];
    for (NSNumber *num in [self.gameModel allAvailableBoards]){
        NSInteger boardIndex = [num integerValue];
        NSArray *miniboard = board[boardIndex];
        // Calculate a value for each possible move.
        for (NSInteger i = 0; i < 9; i++){
            if ([miniboard[i] integerValue] < 0){
                [possibleMoves addObject:[NSIndexPath indexPathForRow:i inSection:boardIndex]];
            }
        }
    }
    
    // Choose a move randomly from the list of valid moves.
    NSIndexPath *move;
    NSInteger rand = arc4random_uniform([possibleMoves count]);
    move = possibleMoves[rand];
    
    return move;
}

@end
