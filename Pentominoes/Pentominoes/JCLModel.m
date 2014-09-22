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
    [self loadPieceImages];
}
- (void) loadBoardImages{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (int i = 0; i < kNumBoards; ++i){
        NSString *imageName = [NSString stringWithFormat:@"Board%d", i];
        [temp addObject:[UIImage imageNamed:imageName]];
    }
    self.boardImages = temp;
}

- (void) loadSolutions{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Solutions" ofType:@"plist"];
    self.solutions = [[NSMutableArray alloc] initWithContentsOfFile:path];
}

- (void) loadPieceImages{
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    self.portraitCoords = [[NSMutableDictionary alloc] init];
    for (NSString *key in self.keys){
        UIImage *img = [UIImage imageNamed:[@"tile" stringByAppendingString:key]];
        temp[key] = img;
        // Initializing start coordinates to 0, 0. (just in case we try to get
        // data from it before the real coords are set.
        CGPoint pt = CGPointMake(10, 10);
        [self.portraitCoords setObject:[NSValue valueWithCGPoint:pt] forKey:key];
        //self.portraitCoords[key] = [NSValue valueWithCGPoint:pt];
        NSLog(@"%f", [self.portraitCoords[key] CGPointValue].x);
    }
    self.pieceImages = temp;
}

- (NSDictionary *) getSolution:(NSString *)key forBoard:(NSInteger)board{
    NSDictionary *temp = [self.solutions objectAtIndex:board];
    return temp[key];
}

@end
