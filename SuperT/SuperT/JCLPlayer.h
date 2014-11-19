//
//  JCLPlayer.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCLPlayer : NSObject

@property NSNumber *identificationNumber;

- (id) initWithName:(NSString *)name;

// Returns the score between two players. Method name might be a bit ambiguous.
- (NSIndexPath *) scoresAgainst:(JCLPlayer *)opponent;
- (NSIndexPath *) totalScore;
- (NSString *) nameOfPlayer;

+ (void) concludeWithWinner:(JCLPlayer *)winner andLoser:(JCLPlayer *)loser;
- (void) resetScoresAgainst:(JCLPlayer *)opponent;

@end
