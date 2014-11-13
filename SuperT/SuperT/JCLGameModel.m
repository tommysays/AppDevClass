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
@property BOOL isXTurn;

@end

@implementation JCLGameModel

- (id) init{
    self = [super init];
    if (self){
        [self initLists];
        self.isXTurn = YES;
    }
    return self;
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

- (void) makeMove_X:(NSIndexPath *)move{
    [self recordMove:move withMark:@"x"];
    self.isXTurn = NO;
}

- (void) makeMove_O:(NSIndexPath *)move{
    [self recordMove:move withMark:@"o"];
    self.isXTurn = YES;
}

- (void) recordMove:(NSIndexPath *)move withMark:(NSString *)mark{
    NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
    [entry setObject:move forKey:@"move"];
    [entry setObject:mark forKey:@"player"];
    [self.moveHistory addObject:entry];
}

@end
