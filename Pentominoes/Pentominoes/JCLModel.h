//
//  JCLModel.h
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/21/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCLModel : NSObject

@property (nonatomic, retain) NSMutableArray *boardImages;
@property (nonatomic, retain) NSMutableDictionary *pieceImages;
@property (nonatomic, retain) NSArray *solutions;
@property (nonatomic, retain) NSArray *keys;

// Loads board images, piece images, and piece solutions.
- (void) loadData;

// Loads solution data from plist
- (void) loadSolutions;

// Loads board images
- (void) loadBoardImages;

// Loads piece images and other data.
- (void) loadPieces;

// Returns a part of the solution for indicated piece and board
- (NSInteger) solutionRotation:(NSString *)key forBoard:(NSInteger)board;
- (NSInteger) solutionFlip:(NSString *)key forBoard:(NSInteger)board;
- (NSInteger) solutionX:(NSString *)key forBoard:(NSInteger)board;
- (NSInteger) solutionY:(NSString *)key forBoard:(NSInteger)board;

// Returns the image for the indicated board.
- (UIImage *) boardImageFor:(NSInteger)boardNum;

@end
