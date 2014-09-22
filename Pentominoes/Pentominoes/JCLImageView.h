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

@property NSMutableDictionary *userMoves;
@property CGPoint portraitCoords;

@end
