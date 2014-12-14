//
//  JCLModel.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AI.h"
#import "Player.h"
#import "Score+Cat.h"
#import "Volume+Cat.h"

@interface JCLModel : NSObject

+ (id) sharedInstance;

- (NSInteger) numberOfPlayerProfiles;
- (NSInteger) numberOfAIProfiles;

- (NSString *) nameOfPlayerAtIndex:(NSInteger)playerIndex;
- (NSString *) nameOfAIAtIndex:(NSInteger)aiIndex;

- (Player *) playerAtIndex:(NSInteger)playerIndex;
- (AI *) aiAtIndex:(NSInteger)aiIndex;

- (UIImage *) markForPlayer:(NSInteger)player;
- (Score *) scoreBetweenPlayers:(NSArray *)players;
- (NSIndexPath *) totalScoreForPlayerAtIndex:(NSInteger)playerIndex;

- (void) addPlayerWithName:(NSString *)name;
- (void) removePlayerAtIndex:(NSUInteger)playerIndex;
- (void) updateScore:(Score *)score withWinner:(Player *)winner;

@end
