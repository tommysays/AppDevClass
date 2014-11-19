//
//  JCLPlayer.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLPlayer.h"
#import "JCLModel.h"

@interface JCLPlayer ()

@property NSString *name;
@property NSMutableDictionary *scores;
@property JCLModel *model;

@end

@implementation JCLPlayer

#pragma mark Initialization

- (id) init{
    self = [super init];
    if (self){
        _scores = [[NSMutableDictionary alloc] init];
        _name = @"Anonymous";
        _model = [JCLModel sharedInstance];
        _identificationNumber = [self.model generateID];
    } else{
        NSLog(@"Something went horribly wrong! Player could not be initialized.");
    }
    return self;
}

- (id) initWithName:(NSString *)name{
    self = [self init];
    if (self){
        _name = name;
    }
    return self;
}

#pragma mark Accessors

- (NSIndexPath *) scoresAgainst:(JCLPlayer *)opponent{
    NSIndexPath *toReturn = [self.scores objectForKey:opponent.identificationNumber];
    if (!toReturn){
        toReturn = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.scores setObject:toReturn forKey:opponent.identificationNumber];
    }
    return toReturn;
}

- (NSIndexPath *) totalScore{
    NSInteger wins = 0;
    NSInteger losses = 0;
    for (NSIndexPath *score in self.scores){
        wins += score.row;
        losses -= score.section;
    }
    return [NSIndexPath indexPathForRow:wins inSection:losses];
}

- (NSString *) nameOfPlayer{
    return self.name;
}

#pragma mark Mutators

+ (void) concludeWithWinner:(JCLPlayer *)winner andLoser:(JCLPlayer *)loser{
    [winner winAgainst:loser];
    [loser loseAgainst:winner];
}

- (void) resetScoresAgainst:(JCLPlayer *)opponent{
    if ([self.scores objectForKey:opponent.identificationNumber]){
        [self.scores removeObjectForKey:opponent.identificationNumber];
    }
}

- (void) winAgainst:(JCLPlayer *)opponent{
    NSIndexPath *score;
    if ([self.scores objectForKey:opponent.identificationNumber]){
        score = [self.scores objectForKey:opponent.identificationNumber];
        score = [NSIndexPath indexPathForRow:(score.row + 1) inSection:score.section];
    } else{
        score = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    [self.scores setObject:score forKey:opponent.identificationNumber];
}

- (void) loseAgainst:(JCLPlayer *)opponent{
    NSIndexPath *score;
    if ([self.scores objectForKey:opponent.identificationNumber]){
        score = [self.scores objectForKey:opponent.identificationNumber];
        score = [NSIndexPath indexPathForRow:score.row inSection:(score.section + 1)];
    } else{
        score = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    [self.scores setObject:score forKey:opponent.identificationNumber];
}

@end
