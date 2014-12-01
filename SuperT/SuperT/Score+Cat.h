//
//  Score+Cat.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "Score.h"

@interface Score (Cat)

- (NSInteger) winsForPlayerID:(NSNumber *)playerID;
- (NSInteger) lossesForPlayerID:(NSNumber *)playerID;
- (void) winAgainst:(NSNumber *)playerID;
- (void) winFor:(NSNumber *)playerID;

@end
