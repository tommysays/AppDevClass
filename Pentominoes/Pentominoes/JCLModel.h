//
//  JCLModel.h
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/21/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCLModel : NSObject

@property NSArray *boardImages;
@property NSDictionary *pieceImages;
@property NSMutableDictionary *portraitCoords;
@property NSMutableDictionary *userMoves;
@property NSArray *solutions;
@property NSArray *keys;

// Loads board images, piece images, and piece solutions.
- (void) loadData;

// Loads solution data from plist
- (void) loadSolutions;

// Loads board images
- (void) loadBoardImages;

// Loads piece images and other data.
- (void) loadPieces;

// Returns the solution for a given piece and a given board.
- (NSDictionary *) getSolution:(NSString *)key forBoard:(NSInteger)board;

@end
