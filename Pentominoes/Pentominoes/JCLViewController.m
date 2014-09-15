//
//  JCLViewController.m
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLViewController.h"

@interface JCLViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *boardView;
@property (weak, nonatomic) IBOutlet UIButton *solveButton;
- (IBAction)boardButtonPressed:(UIButton *)sender;
- (IBAction)solvePresssed:(id)sender;
- (IBAction)resetPressed:(id)sender;

@property NSInteger width, height;
@property NSInteger curBoard;

@end

@implementation JCLViewController

const NSInteger NUM_BOARDS = 6;
const NSInteger NUM_PIECES = 12;
const NSInteger BLOCK_WIDTH = 30;
const NSInteger BLOCK_HEIGHT = 30;
const NSInteger MAX_PIECE_WIDTH = 150;
const NSInteger MAX_PIECE_HEIGHT = 150;
const NSInteger STARTING_Y = 550;

NSDictionary *pieces;
NSMutableArray *solutions;
NSArray *boardImages;
NSArray *pieceKeys;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.height = self.view.bounds.size.height;
    self.width = self.view.bounds.size.width;
    self.curBoard = 0;
    self.solveButton.enabled = false;
    [self loadBoardImages];
    [self loadPieces];
    [self loadSolutions];
    [self initPiecePositions];
}

- (void) loadBoardImages{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (int i = 0; i < NUM_BOARDS; ++i){
        NSString *imageName = [NSString stringWithFormat:@"Board%d", i];
        [temp addObject:[UIImage imageNamed:imageName]];
    }
    boardImages = temp;
}

- (void) loadPieces{
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    pieceKeys = @[@"F", @"I", @"L", @"N", @"P", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    for (NSString *key in pieceKeys){
        NSMutableDictionary *inner = [[NSMutableDictionary alloc] init];
        UIImage *img = [UIImage imageNamed:[@"tile" stringByAppendingString:key]];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
        inner[@"view"] = imgView;
        inner[@"rotations"] = @0;
        inner[@"flips"] = @0;
        temp[key] = inner;
    }
    pieces = temp;
}

- (void) loadSolutions{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Solutions" ofType:@"plist"];
    solutions = [[NSMutableArray alloc] initWithContentsOfFile:path];
}

// Placing pieces in their initial position.
- (void) initPiecePositions{
    NSInteger tilesAcross = self.width / MAX_PIECE_WIDTH;
    NSInteger tilesDown = NUM_PIECES / tilesAcross;
    if (NUM_PIECES % tilesAcross != 0){
        tilesDown++;
    }
    NSInteger remainder = self.width % MAX_PIECE_WIDTH;
    NSInteger padding = remainder / tilesAcross;
    NSInteger x = padding;
    NSInteger y = STARTING_Y;
    NSInteger xCounter = 0;
    
    for (NSString *key in pieceKeys){
        UIImageView *tile = pieces[key][@"view"];
        CGSize imgSize = [[tile image] size];
        x = xCounter * (padding + MAX_PIECE_WIDTH) + padding;
        CGRect dim = CGRectMake(x, y, imgSize.width, imgSize.height);
        tile.frame = dim;
        tile.contentMode = UIViewContentModeTopLeft;
        [[self view] addSubview:tile];
        
        xCounter++;
        if (xCounter >= tilesAcross){
            xCounter = 0;
            y += MAX_PIECE_HEIGHT + padding;
        }
    }
}

// Animates the pieces toward their position in the solution.
- (void) solve{
    if (self.curBoard == 0){
        return;
    }
    CGPoint boardOrigin = [self boardView].frame.origin;
    NSDictionary *tileMoves = [solutions objectAtIndex:(self.curBoard - 1)];
    for (NSString *key in pieceKeys){
        NSDictionary *move = tileMoves[key];
        NSDictionary *piece = pieces[key];
        UIImageView *imgView = piece[@"view"];
        [UIImageView animateWithDuration:1.5 animations:^{
            // Transform for rotating piece
            NSInteger numRotations = (NSInteger)move[@"rotations"] - (NSInteger)piece[@"rotations"];
            CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat)(M_PI * 0.5 * numRotations));
            
            // Transform for flipping piece
            NSInteger flip = (NSInteger)move[@"flip"] - (NSInteger)piece[@"flip"];
            if (flip != 0){
                flip = 1;
            }
            if (flip != 0){
                if (numRotations % 2 == 0){
                    transform = CGAffineTransformScale(transform, -1.0, 1.0);
                } else{
                    transform = CGAffineTransformScale(transform, 1.0, -1.0);
                }
            }
            
            imgView.transform = transform;
            
            // Translate piece
            CGPoint newOrigin = CGPointMake(boardOrigin.x + BLOCK_WIDTH * (NSInteger)move[@"x"],
                                            boardOrigin.y + BLOCK_HEIGHT * (NSInteger)move[@"y"]);
            CGSize size = imgView.frame.size;
            CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, size.width, size.height);
            imgView.frame = newFrame;
        }];
    }
}

- (IBAction)boardButtonPressed:(UIButton *)sender {
    self.curBoard = sender.tag;
    [self.boardView setImage:[boardImages objectAtIndex:self.curBoard]];
    if (self.curBoard != 0){
        self.solveButton.enabled = true;
    } else{
        self.solveButton.enabled = false;
    }
}

- (IBAction)solvePresssed:(id)sender {
    [self solve];
}

- (IBAction)resetPressed:(id)sender {
}
@end
