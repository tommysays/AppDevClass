//
//  JCLModel.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLModel.h"
#import "JCLPlayer.h"

@interface JCLModel ()

@property NSMutableDictionary *playerList;

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

#pragma mark Misc

// A simple rand function for ID generation.
- (NSNumber *) generateID{
    NSInteger rand = -1;
    while ([self.playerList objectForKey:[NSNumber numberWithUnsignedInteger:rand]]|| rand == -1){
        rand = arc4random();
    }
    return [NSNumber numberWithUnsignedInteger:rand];
}

- (NSDictionary *) listOfPlayers{
    return self.playerList;
}

- (void) addPlayerWithName:(NSString *)name{
    JCLPlayer *player = [[JCLPlayer alloc] initWithName:name];
    [self.playerList setObject:player forKey:player.identificationNumber];
}

- (void) removePlayer:(JCLPlayer *)player{
    for (NSNumber *identificationNumber in self.playerList){
        JCLPlayer *pl = [self.playerList objectForKey:identificationNumber];
        if (pl){
            [pl resetScoresAgainst:player];
        }
    }
}

@end
