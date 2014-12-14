//
//  JCLChoosePlayerViewController.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCLModel.h"
#import "JCLGameViewController.h"
#import "JCLAppDelegate.h"
#import "JCLAddPlayerViewController.h"
#import "JCLRemovePlayerViewController.h"

@interface JCLChoosePlayerViewController : UIViewController

@property BOOL isSinglePlayer;
- (void) refresh;

@end
