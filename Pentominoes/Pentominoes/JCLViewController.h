//
//  JCLViewController.h
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCLViewController : UIViewController

@end

#if !defined CONSTANTS
#define CONSTANTS
#define kNumBoards  6
#define kNumPieces  12
#define kBlockWidth 30
#define kBlockHeight 30
#define kMaxPieceWidth 150
#define kMaxPieceHeight 100
#define kPortraitY 570
#define kLandscapeY 540
#define kAnimationDuration 1.5
// kSnapAnimationDuration is used for user-prompted animations
// so we make those animations faster, since kAnimationDuration is way
// too slow.
#define kSnapAnimationDuration 0.25
#define kRotation 0.5
#define kMaxRotations 4
#define kPanScale 1.1
#endif