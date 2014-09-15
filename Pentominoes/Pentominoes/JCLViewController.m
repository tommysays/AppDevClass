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

NSMutableDictionary *pieces;
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
        inner[@"rotations"] = [NSNumber numberWithInteger:0];
        inner[@"flips"] = [NSNumber numberWithInteger:0];
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
    NSDictionary *tileMoves = [solutions objectAtIndex:(self.curBoard - 1)];
    for (NSString *key in pieceKeys){
        NSDictionary *move = tileMoves[key];
        NSMutableDictionary *piece = pieces[key];
        UIImageView *imgView = piece[@"view"];
        
        [UIImageView animateWithDuration:1.5 animations:^{
            // Changing parent view, if needed
            if (imgView.superview == self.view){
                imgView.center = [self.view convertPoint:imgView.center toView:self.boardView];
            }
            [self.boardView addSubview:imgView];
            
            // Transform for rotating piece
            NSInteger moveRotations = [move[@"rotations"] integerValue];
            NSInteger pieceRotations = [piece[@"rotations"] integerValue];
            NSInteger numRotations = moveRotations - pieceRotations;
            NSLog(@"Rotating %@ %d times.", key, numRotations);
            imgView.transform = CGAffineTransformRotate(imgView.transform, (CGFloat)(M_PI * 0.5 * numRotations));
            piece[@"rotations"] = [NSNumber numberWithInteger:moveRotations];
            
            // Transform for flipping piece
            NSInteger moveFlip = [move[@"flips"] integerValue];
            NSInteger pieceFlip = [piece[@"flips"] integerValue];
            NSInteger flip = 0;
            if (moveFlip != pieceFlip){
                flip = 1;
            }
            CGFloat x, y;
            if (flip != 0){
                if (moveRotations % 2 == 0){
                    x = -1.0f;
                    y = 1.0f;
                } else{
                    x = 1.0f;
                    y = -1.0f;
                }
                imgView.transform = CGAffineTransformScale(imgView.transform, x, y);
            }
            piece[@"flips"] = [NSNumber numberWithInteger:moveFlip];
            
            // Translate piece
            CGPoint newOrigin = CGPointMake(BLOCK_WIDTH * [move[@"x"] integerValue],
                                            BLOCK_HEIGHT * [move[@"y"] integerValue]);
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
