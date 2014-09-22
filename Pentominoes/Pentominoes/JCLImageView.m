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
        [self initRecognizers];
    }
    return self;
}

- (void) initRecognizers{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToPan:)];
    [panRecognizer requireGestureRecognizerToFail:singleTap];
    [panRecognizer requireGestureRecognizerToFail:doubleTap];
    
    // Adding recognizers
    [self addGestureRecognizer:singleTap];
    [self addGestureRecognizer:doubleTap];
    [self addGestureRecognizer:panRecognizer];
}

# pragma mark Recognizer Actions

- (void) respondToSingleTap:(UITapGestureRecognizer *)recognizer{
    [UIView animateWithDuration:kAnimationDuration/4 animations:^{
        NSMutableDictionary *moves = self.userMoves;
        NSInteger rotations = [moves[@"rotations"] integerValue];
        NSInteger flips = [moves[@"flips"] integerValue];
        rotations++;
        if (rotations >= 4){
            rotations -= 4;
        }
        
        CGAffineTransform transform;
        transform = CGAffineTransformMakeRotation((CGFloat)(M_PI * kRotation * rotations));
        
        CGFloat x, y;
        if (flips % 2 != 0){
            x = -1.0f;
            y = 1.0f;
            self.transform = CGAffineTransformScale(transform, x, y);
        } else {
            self.transform = transform;
        }
        
        // Setting new number of rotations
        moves[@"rotations"] = [NSNumber numberWithInteger:rotations];
        
    } completion:^(BOOL finished){
        
    }];
}

- (void) respondToDoubleTap:(UITapGestureRecognizer *)recognizer{
    [UIView animateWithDuration:kAnimationDuration/4 animations:^{
        NSMutableDictionary *moves = self.userMoves;
        NSInteger rotations = [moves[@"rotations"] integerValue];
        NSInteger flips = [moves[@"flips"] integerValue];
        flips++;
        
        CGAffineTransform transform;
        transform = CGAffineTransformMakeRotation((CGFloat)(M_PI * kRotation * rotations));
        
        CGFloat x, y;
        if (flips % 2 != 0){
            x = -1.0f;
            y = 1.0f;
            self.transform = CGAffineTransformScale(transform, x, y);
            flips = 1;
        } else {
            flips = 0;
            self.transform = transform;
        }
        
        // Setting new number of rotations
        moves[@"flips"] = [NSNumber numberWithInteger:flips];
        
    } completion:^(BOOL finished){
        
    }];
}

- (void) respondToPan:(UIPanGestureRecognizer *)recognizer{
    
}


@end
