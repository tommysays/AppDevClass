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
        _userMoves = [[NSMutableDictionary alloc] init];
        _startingCoords = [[NSMutableDictionary alloc] init];
        _userMoves[@"rotations"] = [NSNumber numberWithInteger:0];
        _userMoves[@"flips"] = [NSNumber numberWithInteger:0];
        self.userInteractionEnabled = true;
    }
    return self;
}

- (NSInteger) userRotations{
    return [[self.userMoves objectForKey:@"rotations"] integerValue];
}

- (NSInteger) userFlips{
    return [[self.userMoves objectForKey:@"flips"] integerValue];
}

- (void) setUserRotations:(NSInteger)rotations{
    [self.userMoves setObject:[NSNumber numberWithInteger:rotations] forKey:@"rotations"];
}

- (void) setUserFlips:(NSInteger)flips{
    [self.userMoves setObject:[NSNumber numberWithInteger:flips] forKey:@"flips"];
}

- (void) setStartingCoord:(CGPoint)point forOrientation:(NSInteger)orientation{
    [self.startingCoords setObject:[NSValue valueWithCGPoint:point] forKey:[NSNumber numberWithInteger:orientation]];
}

//TODO may not be working as intended.
- (CGPoint) startingCoords:(NSInteger)orientation{
    return [[self.startingCoords objectForKey:[NSNumber numberWithInteger:orientation]] CGPointValue];
}

- (void) dealloc{
    [_startingCoords release];
    [_userMoves release];
    [super dealloc];
}

@end
