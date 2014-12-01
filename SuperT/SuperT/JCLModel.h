//
//  JCLModel.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
#import "Score+Cat.h"

@interface JCLModel : NSObject

+ (id) sharedInstance;

- (NSInteger) numberOfPlayerProfiles;
- (NSString *) nameOfPlayerAtIndex:(NSInteger)playerIndex;
- (Player *) playerAtIndex:(NSInteger)playerIndex;
- (UIImage *) markForPlayer:(NSInteger)player;
- (Score *) scoreBetweenPlayers:(NSArray *)players;

- (void) addPlayerWithName:(NSString *)name;
- (void) removePlayerAtIndex:(NSUInteger)playerIndex;

@end
