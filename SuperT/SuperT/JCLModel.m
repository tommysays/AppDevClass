//
//  JCLModel.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLModel.h"

@interface JCLModel ()

@property NSMutableArray *playerList;
@property NSMutableDictionary *playerIDs;
@property NSMutableDictionary *images;

@end

@implementation JCLModel

#pragma mark Initialization

+ (id) sharedInstance{
    static id singleton;
    @synchronized(self){
        if (!singleton){
            singleton = [[self alloc] init];
        }
    }
    return singleton;
}

- (id) init{
    self = [super init];
    if (self){
        self.playerList = [[NSMutableArray alloc] init];
        self.playerIDs = [[NSMutableDictionary alloc] init];
        self.images = [[NSMutableDictionary alloc] init];
        [self loadImages];
    }
    return self;
}

- (void) loadImages{
    UIImage *img = [UIImage imageNamed:@"xcell_image"];
    [self.images setObject:img forKey:@"xCellImage"];
    img = [UIImage imageNamed:@"ocell_image"];
    [self.images setObject:img forKey:@"oCellImage"];
}

#pragma mark Accessors

- (NSInteger) numberOfPlayerProfiles{
    return [self.playerList count];
}

- (NSString *) nameOfPlayerAtIndex:(NSInteger)playerIndex{
    return [[self.playerList objectAtIndex:playerIndex] name];
}

- (JCLPlayer *) playerAtIndex:(NSInteger)playerIndex{
    return [self.playerList objectAtIndex:playerIndex];
}

- (UIImage *) markForPlayer:(NSInteger)player{
    if (player == 0){
        return [self.images objectForKey:@"xCellImage"];
    } else{
        return [self.images objectForKey:@"oCellImage"];
    }
}

#pragma mark Misc

// A simple rand function for ID generation.
- (NSNumber *) generateID{
    NSUInteger rand = -1;
    while ([self.playerIDs objectForKey:[NSNumber numberWithUnsignedInteger:rand]]|| rand == -1){
        rand = arc4random();
    }
    return [NSNumber numberWithUnsignedInteger:rand];
}

- (void) addPlayerWithName:(NSString *)name{
    JCLPlayer *player = [[JCLPlayer alloc] initWithName:name];
    [self.playerIDs setObject:player forKey:player.identificationNumber];
    [self.playerList addObject:player];
    [self sortPlayersByName];
}

- (void) removePlayer:(JCLPlayer *)player{
    for (JCLPlayer *pl in self.playerList){
        [pl resetScoresAgainst:player];
    }
    [self.playerList removeObject:player];
    [self.playerIDs removeObjectForKey:player.identificationNumber];
}

- (void) removePlayerAtIndex:(NSInteger)playerIndex{
    __weak JCLPlayer *player = [self.playerList objectAtIndex:playerIndex];
    [self removePlayer:player];
}

- (void) sortPlayersByName{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [self.playerList sortUsingDescriptors:@[sortDescriptor]];
}

@end
