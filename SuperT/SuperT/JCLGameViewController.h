//
//  JCLGameViewController.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Player.h"
#import "AI.h"

@interface JCLGameViewController : UIViewController

@property Player *player1;
@property Player *player2;
@property AI *ai;

@end
