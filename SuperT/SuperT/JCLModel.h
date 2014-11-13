//
//  JCLModel.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCLPlayer.h"

@interface JCLModel : NSObject

+ (id) sharedInstance;
- (NSNumber *) generateID;

- (NSInteger) numberOfPlayerProfiles;
- (NSString *) nameOfPlayerAtIndex:(NSInteger)playerIndex;
- (JCLPlayer *) playerAtIndex:(NSInteger)playerIndex;

- (void) addPlayerWithName:(NSString *)name;
- (void) removePlayerAtIndex:(NSInteger)playerIndex;
- (void) removePlayer:(JCLPlayer *)player;

@end
