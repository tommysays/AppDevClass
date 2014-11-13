//
//  JCLGameModel.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCLPlayer.h"

@interface JCLGameModel : NSObject

@property BOOL isPlayer1Turn;

- (id) initWithPlayer1:(JCLPlayer *)player1 andPlayer2:(JCLPlayer *)player2;

@end
