//
//  JCLModel.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLModel.h"
#import "SoundManager.h"
#import "DataManager.h"
#import "MyDataManager.h"


@interface JCLModel ()

@property (nonatomic,strong) DataManager *dataManager;
@property (nonatomic,strong) MyDataManager *myDataManager;
@property SoundManager *soundManager;

@property NSMutableArray *playerList;
@property NSMutableArray *aiList;
@property NSMutableDictionary *playerIDs;
@property NSMutableDictionary *images;


@end

@implementation JCLModel

#pragma mark - Initialization

+ (id) sharedInstance{
    static id singleton;
    @synchronized(self){
        if (!singleton){
            singleton = [[self alloc] init];
            [singleton finishInit];
        }
    }
    return singleton;
}

- (id) init{
    self = [super init];
    if (self){
        _dataManager = [DataManager sharedInstance];
        _myDataManager = [[MyDataManager alloc] init];
        _dataManager.delegate = _myDataManager;
        _soundManager = [SoundManager sharedInstance];
        _images = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// Can't place in "init" due to circular "self" call.
- (void) finishInit{
    [self loadImages];
    [self loadPlayers];
    [self.soundManager updateVolume:[self volume]];
    [self.soundManager updateIsOn:[self isSoundOn]];
}

- (void) loadPlayers{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isAI == %@", [NSNumber numberWithBool:NO]];
    NSArray *players = [self.dataManager fetchManagedObjectsForEntity:@"Player" sortKeys:@[@"name"] predicate:pred];
    self.playerList = [players mutableCopy];
    self.playerIDs = [[NSMutableDictionary alloc] init];
    for (Player *player in self.playerList){
        [self.playerIDs setObject:player forKey:player.playerID];
    }
    pred = [NSPredicate predicateWithFormat:@"isAI == %@", [NSNumber numberWithBool:YES]];
    NSArray *ais = [self.dataManager fetchManagedObjectsForEntity:@"AI" sortKeys:@[@"name"] predicate:pred];
    self.aiList = [ais mutableCopy];
    for (AI *ai in self.aiList){
        [self.playerIDs setObject:ai forKey:ai.playerID];
    }
    [self.dataManager saveContext];
}

- (void) loadImages{
    NSMutableArray *oMark = [[NSMutableArray alloc] init];
    [oMark addObject:[UIImage imageNamed:@"oMark1"]];
    [oMark addObject:[UIImage imageNamed:@"oMark2"]];
    [oMark addObject:[UIImage imageNamed:@"oMark3"]];
    [self.images setObject:oMark forKey:@"oMark"];
    
    NSMutableArray *xMark = [[NSMutableArray alloc] init];
    [xMark addObject:[UIImage imageNamed:@"xMark1"]];
    [xMark addObject:[UIImage imageNamed:@"xMark2"]];
    [xMark addObject:[UIImage imageNamed:@"xMark3"]];
    [self.images setObject:xMark forKey:@"xMark"];
}

#pragma mark - Accessors

- (NSInteger) numberOfPlayerProfiles{
    return [self.playerList count];
}

- (NSInteger) numberOfAIProfiles{
    return [self.aiList count];
}

- (NSString *) nameOfPlayerAtIndex:(NSInteger)playerIndex{
    return [[self.playerList objectAtIndex:playerIndex] name];
}

- (NSString *) nameOfAIAtIndex:(NSInteger)aiIndex{
    return [[self.aiList objectAtIndex:aiIndex] name];
}

- (Player *) playerAtIndex:(NSInteger)playerIndex{
    return [self.playerList objectAtIndex:playerIndex];
}

- (AI *) aiAtIndex:(NSInteger)aiIndex{
    return [self.aiList objectAtIndex:aiIndex];
}

- (UIImage *) markForPlayer:(NSInteger)player{
    NSArray *themes = [self.dataManager fetchManagedObjectsForEntity:@"Theme" sortKeys:nil predicate:nil];
    Theme *theme = themes[0];
    NSInteger curTheme = [theme.theme integerValue];
    if (player == 1){
        return [self.images objectForKey:@"xMark"][curTheme];
    } else{
        return [self.images objectForKey:@"oMark"][curTheme];
    }
}

- (Score *) scoreBetweenPlayers:(NSArray *)players{
    Player *player1 = players[0];
    Player *player2 = players[1];
    NSNumber *p1_id = player1.playerID;
    NSNumber *p2_id = player2.playerID;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(player1_ID == %@ AND player2_ID == %@) OR (player1_ID == %@ AND player2_ID == %@)", p1_id, p2_id, p2_id, p1_id];
    NSArray *scores = [self.dataManager fetchManagedObjectsForEntity:@"Score" sortKeys:nil predicate:pred];
    Score *toReturn;
    if ([scores count] == 0){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:p1_id forKey:@"player1_ID"];
        [dict setObject:p2_id forKey:@"player2_ID"];
        [dict setObject:[NSNumber numberWithInteger:0] forKey:@"player1_wins"];
        [dict setObject:[NSNumber numberWithInteger:0] forKey:@"player2_wins"];
        toReturn = [self.myDataManager addScoreWithDictionary:dict];
        [self.dataManager saveContext];
    } else{
        toReturn = scores[0];
    }
    return toReturn;
}

- (NSIndexPath *) totalScoreForPlayerAtIndex:(NSInteger)playerIndex{

    Player *player = self.playerList[playerIndex];
    NSNumber *ID = player.playerID;
    
    // Fetch all scores related to player.
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"player1_ID == %@ OR player2_ID == %@", ID, ID];
    NSArray *scores = [self.dataManager fetchManagedObjectsForEntity:@"Score" sortKeys:nil predicate:pred];
    
    // Tally up total wins and losses.
    NSInteger wins = 0;
    NSInteger losses = 0;
    for (Score *score in scores){
        wins += [score winsForPlayerID:ID];
        losses += [score lossesForPlayerID:ID];
    }
    
    return [NSIndexPath indexPathForRow:wins inSection:losses];
}

#pragma mark - Mutators

- (void) addPlayerWithName:(NSString *)name{
    NSNumber *playerID = [self generateID];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[playerID, name] forKeys:@[@"playerID", @"name"]];
    Player *player = [self.myDataManager addPlayerWithDictionary:dict];
    [self.playerIDs setObject:player forKey:player.playerID];
    [self.playerList addObject:player];
    [self sortPlayersByName];
    
    [self.dataManager saveContext];
}

- (void) removePlayerAtIndex:(NSUInteger)playerIndex{
    __weak Player *player = [self.playerList objectAtIndex:playerIndex];
    NSNumber *ID = player.playerID;
    
    [self.dataManager.managedObjectContext deleteObject:player];
    
    // Fetch and remove all scores related to player.
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"player1_ID == %@ OR player2_ID == %@", ID, ID];
    NSArray *scores = [self.dataManager fetchManagedObjectsForEntity:@"Score" sortKeys:nil predicate:pred];
    for (Score *score in scores){
        [self.dataManager.managedObjectContext deleteObject:score];
    }
    
    [self.playerIDs removeObjectForKey:ID];
    [self.playerList removeObjectAtIndex:playerIndex];
    
    [self.dataManager saveContext];
}

- (void) updateScore:(Score *)score withWinner:(Player *)winner{
    [score winFor:winner.playerID];
    
    [self.dataManager saveContext];
}

#pragma mark - Volume

- (float) volume{
    NSArray *volumes = [self.dataManager fetchManagedObjectsForEntity:@"Volume" sortKeys:nil predicate:nil];
    Volume *volume = volumes[0];
    NSNumber *vol = volume.volume;
    return [vol floatValue];
}

- (void) updateVolume:(float)vol{
    NSArray *volumes = [self.dataManager fetchManagedObjectsForEntity:@"Volume" sortKeys:nil predicate:nil];
    [volumes[0] changeVolume:vol];
    
    [self.soundManager updateVolume:vol];
    
    [self.dataManager saveContext];
}

- (BOOL) isSoundOn{
    NSArray *volumes = [self.dataManager fetchManagedObjectsForEntity:@"Volume" sortKeys:nil predicate:nil];
    Volume *volume = volumes[0];
    return [volume.isOn boolValue];
}
- (void) setSoundOn:(BOOL)isOn{
    NSArray *volumes = [self.dataManager fetchManagedObjectsForEntity:@"Volume" sortKeys:nil predicate:nil];
    [volumes[0] updateIsOn:isOn];
    
    [self.soundManager updateIsOn:isOn];
    
    [self.dataManager saveContext];
}

#pragma mark - Theme

- (NSInteger) currentTheme{
    NSArray *themes = [self.dataManager fetchManagedObjectsForEntity:@"Theme" sortKeys:nil predicate:nil];
    Theme *theme = themes[0];
    return [theme.theme integerValue];
}

- (void) updateTheme:(NSInteger)theme{
    NSArray *themes = [self.dataManager fetchManagedObjectsForEntity:@"Theme" sortKeys:nil predicate:nil];
    Theme *curTheme = themes[0];
    curTheme.theme = [NSNumber numberWithInteger:theme];
    [self.dataManager saveContext];
}

#pragma mark - Sorting

- (void) sortPlayersByName{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [self.playerList sortUsingDescriptors:@[sortDescriptor]];
}

#pragma mark - Misc

// A simple rand function for ID generation.
- (NSNumber *) generateID{
    NSUInteger rand = -1;
    // ID 0 through 10 are reserved for AI.
    while ([self.playerIDs objectForKey:[NSNumber numberWithUnsignedInteger:rand]] || rand < 11){
        rand = arc4random();
    }
    return [NSNumber numberWithUnsignedInteger:rand];
}

@end
