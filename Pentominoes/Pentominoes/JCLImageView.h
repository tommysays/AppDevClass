//
//  JCLImageView.h
//  Pentominoes
//
//  This is a subclass of UIImageView that acts just like UIImageView, but it
//  also has convenient storage of data relevant to the piece, such as number
//  of rotations performed on it.
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/22/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCLImageView : UIImageView

@property (nonatomic, retain) NSMutableDictionary *userMoves;
@property (nonatomic, retain) NSMutableDictionary *startingCoords;

- (NSInteger) userRotations;
- (NSInteger) userFlips;
- (void) setUserRotations:(NSInteger)rotations;
- (void) setUserFlips:(NSInteger)flips;
- (CGPoint) startingCoords:(NSInteger)orientation;
- (void) setStartingCoord:(CGPoint)point forOrientation:(NSInteger)orientation;

@end
