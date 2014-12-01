//
//  Score+Cat.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "Score+Cat.h"

@implementation Score (Cat)

- (NSInteger) winsForPlayerID:(NSNumber *)playerID{
    if ([playerID isEqual:self.player1_ID]){
        return [self.player1_wins integerValue];
    } else{
        return [self.player2_wins integerValue];
    }
}

- (NSInteger) lossesForPlayerID:(NSNumber *)playerID{
    if ([playerID isEqual:self.player1_ID]){
        return [self.player2_wins integerValue];
    } else{
        return [self.player1_wins integerValue];
    }
}

- (void) winAgainst:(NSNumber *)playerID{
    if ([playerID isEqual:self.player1_ID]){
        self.player2_wins = [NSNumber numberWithInteger:([self.player2_wins integerValue] + 1)];
    } else{
        self.player1_wins = [NSNumber numberWithInteger:([self.player1_wins integerValue] + 1)];
    }
    
    // TODO Should this be here? Or should I refresh elsewhere? Am I even refreshing correctly?
    // Update: Apparently this works, but I'm not very convinced that it's the right way to do it.
    // Update 2: It doesn't work! I can't save the context from here.
    //[self.managedObjectContext refreshObject:self mergeChanges:YES];
}

- (void) winFor:(NSNumber *)playerID{
    if ([playerID isEqual:self.player1_ID]){
        self.player1_wins = [NSNumber numberWithInteger:([self.player1_wins integerValue] + 1)];
    } else{
        self.player2_wins = [NSNumber numberWithInteger:([self.player2_wins integerValue] + 1)];
    }
}

@end
