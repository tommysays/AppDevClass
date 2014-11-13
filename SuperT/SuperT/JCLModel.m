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
        // Call initialization methods for data.
    }
    return self;
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

#pragma mark Misc

// A simple rand function for ID generation.
- (NSNumber *) generateID{
    NSInteger rand = -1;
    while ([self.playerIDs objectForKey:[NSNumber numberWithUnsignedInteger:rand]]|| rand == -1){
        rand = arc4random();
    }
    return [NSNumber numberWithUnsignedInteger:rand];
}

- (void) addPlayerWithName:(NSString *)name{
    JCLPlayer *player = [[JCLPlayer alloc] initWithName:name];
    [self.playerIDs setObject:player forKey:player.identificationNumber];
}

- (void) removePlayer:(JCLPlayer *)player{
    for (JCLPlayer *pl in self.playerList){
        [pl resetScoresAgainst:player];
    }
    [self.playerList removeObject:player];
}

@end
