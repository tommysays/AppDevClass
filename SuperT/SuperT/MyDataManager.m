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
    NSArray *defaultPlayers = [[NSArray arrayWithContentsOfFile:path] mutableCopy];
    for (NSDictionary *dict in defaultPlayers) {
        [self addPlayerWithDictionary:dict];
    }
}

#pragma mark - Private Methods

- (Player *) addPlayerWithDictionary:(NSDictionary *)dict{
    Player *player = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:_dataManager.managedObjectContext];
    player.name = dict[@"name"];
    player.playerID = dict[@"playerID"];
    return player;
}

- (Score *) addScoreWithDictionary:(NSDictionary *)dict{
    Score *score = [NSEntityDescription insertNewObjectForEntityForName:@"Score" inManagedObjectContext:_dataManager.managedObjectContext];
    score.player1_id = dict[@"player1_ID"];
    score.player2_id = dict[@"player2_ID"];
    score.player1_wins = dict[@"player1_wins"];
    score.player2_wins = dict[@"player2_wins"];
    return score;
}

@end
