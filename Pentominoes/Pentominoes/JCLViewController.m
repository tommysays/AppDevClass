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
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
- (IBAction)boardButtonPressed:(UIButton *)sender;
- (IBAction)solvePresssed:(id)sender;
- (IBAction)resetPressed:(id)sender;

@property NSInteger width, height;
@property NSInteger curBoard;
@property NSInteger solved;
@property NSMutableDictionary *pieces;
@property NSMutableArray *solutions;
@property NSArray *boardImages;
@property NSArray *pieceKeys;

@end

const NSInteger kNumBoards = 6;
const NSInteger kNumPieces = 12;
const NSInteger kBlockWidth = 30;
const NSInteger kBlockHeight = 30;
const NSInteger kMaxPieceWidth = 150;
const NSInteger kMaxPieceHeight = 150;
const NSInteger kStartingY = 550;
const NSTimeInterval kAnimationDuration = 1.5;

@implementation JCLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.height = self.view.bounds.size.height;
    self.width = self.view.bounds.size.width;
    self.curBoard = 0;
    self.solveButton.enabled = false;
    self.solved = 0;
    [self loadBoardImages];
    [self loadPieces];
    [self loadSolutions];
    [self initPiecePositions];
}

- (void) loadBoardImages{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (int i = 0; i < kNumBoards; ++i){
        NSString *imageName = [NSString stringWithFormat:@"Board%d", i];
        [temp addObject:[UIImage imageNamed:imageName]];
    }
    self.boardImages = temp;
}

- (void) loadPieces{
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    self.pieceKeys = @[@"F", @"I", @"L", @"N", @"P", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    for (NSString *key in self.pieceKeys){
        NSMutableDictionary *inner = [[NSMutableDictionary alloc] init];
        UIImage *img = [UIImage imageNamed:[@"tile" stringByAppendingString:key]];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
        inner[@"view"] = imgView;
        inner[@"x"] = [NSNumber numberWithInteger:0];
        inner[@"y"] = [NSNumber numberWithInteger:0];
        temp[key] = inner;
    }
    self.pieces = temp;
}

- (void) loadSolutions{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Solutions" ofType:@"plist"];
    self.solutions = [[NSMutableArray alloc] initWithContentsOfFile:path];
}

// Placing pieces in their initial position.
- (void) initPiecePositions{
    NSInteger tilesAcross = self.width / kMaxPieceWidth;
    NSInteger tilesDown = kNumPieces / tilesAcross;
    if (kNumPieces % tilesAcross != 0){
        tilesDown++;
    }
    NSInteger remainder = self.width % kMaxPieceWidth;
    NSInteger padding = remainder / tilesAcross;
    NSInteger x = padding;
    NSInteger y = kStartingY;
    NSInteger xCounter = 0;
    
    for (NSString *key in self.pieceKeys){
        NSMutableDictionary *piece = self.pieces[key];
        UIImageView *tile = piece[@"view"];
        CGSize imgSize = [[tile image] size];
        x = xCounter * (padding + kMaxPieceWidth) + padding;
        piece[@"x"] = [NSNumber numberWithInteger:x];
        piece[@"y"] = [NSNumber numberWithInteger:y];
        CGRect dim = CGRectMake(x, y, imgSize.width, imgSize.height);
        tile.frame = dim;
        tile.contentMode = UIViewContentModeTopLeft;
        [[self view] addSubview:tile];
        
        xCounter++;
        if (xCounter >= tilesAcross){
            xCounter = 0;
            y += kMaxPieceHeight + padding;
        }
    }
}

- (void) reset{
    [self.view setUserInteractionEnabled:false];
    for (NSString *key in self.pieceKeys){
        NSMutableDictionary *piece = self.pieces[key];
        UIImageView *imgView = piece[@"view"];
        
        [UIImageView animateWithDuration:kAnimationDuration animations:^{
            // Changing parent view, if needed
            if (imgView.superview == self.boardView){
                imgView.center = [self.boardView convertPoint:imgView.center toView:self.view];
            }
            [self.view addSubview:imgView];
            
            // Reset all transformations.
            imgView.transform = CGAffineTransformIdentity;
            
            // Translate piece
            CGPoint newOrigin = CGPointMake([piece[@"x"] integerValue], [piece[@"y"] integerValue]);
            CGSize size = imgView.frame.size;
            CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, size.width, size.height);
            imgView.frame = newFrame;
        } completion:^(BOOL finished){
            [self.view setUserInteractionEnabled:true];
        }];
        self.solved = 0;
    }
}

// Animates the pieces toward their correct position in the solution.
- (void) solve{
    if (self.curBoard == 0 || (self.solved == self.curBoard)){
        return;
    }
    [self.view setUserInteractionEnabled:false];
    NSDictionary *tileMoves = [self.solutions objectAtIndex:(self.curBoard - 1)];
    for (NSString *key in self.pieceKeys){
        NSDictionary *move = tileMoves[key];
        NSMutableDictionary *piece = self.pieces[key];
        UIImageView *imgView = piece[@"view"];
        
        [UIImageView animateWithDuration:kAnimationDuration animations:^{
            // Changing parent view, if needed
            if (imgView.superview == self.view){
                imgView.center = [self.view convertPoint:imgView.center toView:self.boardView];
            }
            [self.boardView addSubview:imgView];
            
            // Transform for rotating piece
            NSInteger moveRotations = [move[@"rotations"] integerValue];
            CGAffineTransform transform;
            transform = CGAffineTransformMakeRotation((CGFloat)(M_PI * 0.5 * moveRotations));
            
            // Transform for flipping piece
            NSInteger moveFlip = [move[@"flips"] integerValue];
            CGFloat x, y;
            if (moveFlip != 0){
                x = -1.0f;
                y = 1.0f;
                imgView.transform = CGAffineTransformScale(transform, x, y);
            } else {
                imgView.transform = transform;
            }
            
            // Translate piece
            CGPoint newOrigin = CGPointMake(kBlockWidth * [move[@"x"] integerValue],
                                            kBlockHeight * [move[@"y"] integerValue]);
            CGSize size = imgView.frame.size;
            CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, size.width, size.height);
            imgView.frame = newFrame;
        } completion:^(BOOL finished){
            [self.view setUserInteractionEnabled:true];
        }];
        self.solved = self.curBoard;
    }
}

- (IBAction)boardButtonPressed:(UIButton *)sender {
    NSInteger tag = sender.tag;
    if (self.curBoard != tag){
        self.curBoard = tag;
        self.solved = -1;
    }
    [self.boardView setImage:[self.boardImages objectAtIndex:self.curBoard]];
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
    [self reset];
}
@end
