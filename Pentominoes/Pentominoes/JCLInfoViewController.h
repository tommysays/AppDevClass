//
//  JCLInfoViewController.h
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/22/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCLViewController.h"

@interface JCLInfoViewController : UIViewController

@property NSInteger colorSelected;
@property (assign, nonatomic) JCLViewController* delegate;

#define kSelectorOffset 5

@end
