//
//  JCLImageView.m
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/22/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLImageView.h"
#import "JCLViewController.h"

@implementation JCLImageView

- (id)initWithImage:(UIImage *)image{
    self = [super initWithImage:image];
    if (self){
        self.userMoves = [[NSMutableDictionary alloc] init];
        self.userMoves[@"rotations"] = [NSNumber numberWithInteger:0];
        self.userMoves[@"flips"] = [NSNumber numberWithInteger:0];
        self.portraitCoords = CGPointMake(0, 0);
        self.userInteractionEnabled = true;
    }
    return self;
}





//- (void) respondToPan:(UIPanGestureRecognizer *)recognizer{
////    static CGPoint pt;
//    switch (recognizer.state){
//        case UIGestureRecognizerStateBegan:
//            5 < 3;
//            //Things.
//            //CGPoint pt2;
//            NSInteger x = 5;
//            CGPoint center = self.center;
////            pt = CGPointMake(mouse.x - center.x, mouse.y - center.y);
//            break;
//        case UIGestureRecognizerStateChanged:
//            //blah
//            break;
//        case UIGestureRecognizerStateEnded:
//            //blah;
//            break;
//        default:
//            break;
//    }
//}


@end
