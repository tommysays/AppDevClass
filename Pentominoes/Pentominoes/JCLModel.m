//
//  JCLModel.m
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/21/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLModel.h"
#import "JCLViewController.h"

@implementation JCLModel

- (void) loadData{
    self.keys = @[@"F", @"I", @"L", @"N", @"P", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    [self loadSolutions];
    [self loadBoardImages];
    [self loadPieces];
}
- (void) loadBoardImages{
    self.boardImages = [[NSMutableArray alloc] init];
    for (int i = 0; i < kNumBoards; ++i){
        NSString *imageName = [NSString stringWithFormat:@"Board%d", i];
        [self.boardImages addObject:[UIImage imageNamed:imageName]];
    }
}

- (void) loadSolutions{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Solutions" ofType:@"plist"];
    self.solutions = [[NSMutableArray alloc] initWithContentsOfFile:path];
}

- (void) loadPieces{
    self.pieceImages = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in self.keys){
        UIImage *img = [UIImage imageNamed:[@"tile" stringByAppendingString:key]];
        self.pieceImages[key] = img;
    }
    
}

- (UIImage *) boardImageFor:(NSInteger)boardNum{
    return [self.boardImages objectAtIndex:boardNum];
}

- (NSInteger) solutionRotation:(NSString *)key forBoard:(NSInteger)board{
    return [[[[self.solutions objectAtIndex:board] objectForKey:key] objectForKey:@"rotations"] integerValue];
}

- (NSInteger) solutionFlip:(NSString *)key forBoard:(NSInteger)board{
    return [[[[self.solutions objectAtIndex:board] objectForKey:key] objectForKey:@"flips"] integerValue];
}

- (NSInteger) solutionX:(NSString *)key forBoard:(NSInteger)board{
    return [[[[self.solutions objectAtIndex:board] objectForKey:key] objectForKey:@"x"] integerValue];
}

- (NSInteger) solutionY:(NSString *)key forBoard:(NSInteger)board{
    return [[[[self.solutions objectAtIndex:board] objectForKey:key] objectForKey:@"y"] integerValue];
}

- (void) dealloc{
    [_keys release];
    [_solutions release];
    [_boardImages release];
    [_pieceImages release];
    [super dealloc];
}

@end
