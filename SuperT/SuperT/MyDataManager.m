//
//  MyDataManager.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "MyDataManager.h"
#import "DataManager.h"

static NSString * const modelName = @"Model";

@interface MyDataManager ()

@property (nonatomic,strong) DataManager *dataManager;

@end

@implementation MyDataManager

-(id)init {
    self = [super init];
    if (self) {
        _dataManager = [DataManager sharedInstance];
    }
    return self;
}

#pragma mark - Protocol Methods
- (NSString*)xcDataModelName{
    return modelName;
}

-(void)createDatabase {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"DefaultPlayers" ofType:@"plist"];
    NSArray *defaultPlayers = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *dict in defaultPlayers) {
        [self addPlayerWithDictionary:dict];
    }
    path = [bundle pathForResource:@"DefaultAI" ofType:@"plist"];
    NSArray *defaultAI = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *dict in defaultAI){
        [self addAIWithDictionary:dict];
    }
}

#pragma mark - Private Methods

- (AI *) addAIWithDictionary:(NSDictionary *)dict{
    AI *ai = [NSEntityDescription insertNewObjectForEntityForName:@"AI" inManagedObjectContext:_dataManager.managedObjectContext];
    ai.name = dict[@"name"];
    ai.aiID = dict[@"aiID"];
    return ai;
}

- (Player *) addPlayerWithDictionary:(NSDictionary *)dict{
    Player *player = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:_dataManager.managedObjectContext];
    player.name = dict[@"name"];
    player.playerID = dict[@"playerID"];
    return player;
}

- (Score *) addScoreWithDictionary:(NSDictionary *)dict{
    Score *score = [NSEntityDescription insertNewObjectForEntityForName:@"Score" inManagedObjectContext:_dataManager.managedObjectContext];
    score.player1_ID = dict[@"player1_ID"];
    score.player2_ID = dict[@"player2_ID"];
    score.player1_wins = dict[@"player1_wins"];
    score.player2_wins = dict[@"player2_wins"];
    return score;
}

@end
