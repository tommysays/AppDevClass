//
//  AIMedium.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "AIMedium.h"

@implementation AIMedium

- (NSIndexPath *) makeMove{
    BOOL p1turn = [self.gameModel isPlayer1Turn];
    NSInteger playerMark = p1turn ? 1 : 2;
    
    // General approach: Calculates values of all possible moves, looking only 1 move ahead.
    // Good move = a move where the ai can win a miniboard.
    // Compile best moves into a set (array), and choose one randomly.
    
    NSInteger bestValue = -1;
    NSArray *board = [self.gameModel wholeBoard];
    NSMutableArray *bestMoves = [[NSMutableArray alloc] init];
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
                
                if ([bestMoves count] == 0 || curValue > bestValue){
                    // Change best value, reset bestMoves and add move to bestMoves.
                    bestValue = curValue;
                    bestMoves = [[NSMutableArray alloc] init];
                    [bestMoves addObject:[NSIndexPath indexPathForRow:i inSection:boardIndex]];
                } else if (curValue == bestValue){
                    [bestMoves addObject:[NSIndexPath indexPathForRow:i inSection:boardIndex]];
                }
            }
        }
    }
    
    // Choose a move randomly from the list of best moves.
    NSIndexPath *move;
    NSInteger rand = arc4random_uniform([bestMoves count]);
    move = bestMoves[rand];
    
    return move;
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
