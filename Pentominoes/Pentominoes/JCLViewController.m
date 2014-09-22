//
//  JCLViewController.m
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//


#import "JCLViewController.h"
#import "JCLModel.h"

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
@property NSMutableDictionary *pieceViews;
@property NSMutableArray *solutions;
@property NSArray *boardImages;
@property (nonatomic, strong) JCLModel *model;

@end

@implementation JCLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.height = self.view.bounds.size.height;
    self.width = self.view.bounds.size.width;
    self.curBoard = 0;
    self.solveButton.enabled = false;
    self.solved = 0;
    self.model = [[JCLModel alloc] init];
    [self.model loadData];
    [self initPieceViews];
}

// Placing pieces in their initial position.
- (void) initPieceViews{
    
    // Calculating padding and how many pieces can fit across the screen.
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
    
    self.pieceViews = [[NSMutableDictionary alloc] init];
    for (NSString *key in self.model.keys){
        UIImage *img = self.model.pieceImages[key];
        UIImageView *piece = [[UIImageView alloc] initWithImage:img];
        CGSize imgSize = [[piece image] size];
        x = xCounter * (padding + kMaxPieceWidth) + padding;
        CGPoint pt = CGPointMake(x, y);
        NSValue *val = [NSValue valueWithCGPoint:pt];
        self.model.portraitCoords[key] = val;
        CGRect dim = CGRectMake(x, y, imgSize.width, imgSize.height);
        piece.frame = dim;
        piece.contentMode = UIViewContentModeTopLeft;
        
        self.pieceViews[key] = piece;
        [[self view] addSubview:piece];
        
        xCounter++;
        if (xCounter >= tilesAcross){
            xCounter = 0;
            y += kMaxPieceHeight + padding;
        }
    }
}

- (void) reset{
    [self.view setUserInteractionEnabled:false];
    for (NSString *key in self.model.keys){
        UIImageView *imgView = self.pieceViews[key];
        
        [UIImageView animateWithDuration:kAnimationDuration animations:^{
            // Changing parent view, if needed
            if (imgView.superview == self.boardView){
                imgView.center = [self.boardView convertPoint:imgView.center toView:self.view];
            }
            [self.view addSubview:imgView];
            
            // Reset all transformations.
            imgView.transform = CGAffineTransformIdentity;
            
            // Translate piece
            NSValue *val = [self.model.portraitCoords objectForKey:key];
            CGPoint newOrigin = [val CGPointValue];
            //CGPoint newOrigin = [self.model.portraitCoords[key] CGPointValue];
            CGSize size = imgView.frame.size;
            CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, size.width, size.height);
            
            // Setting frame to final location!
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
    for (NSString *key in self.model.keys){
        
        // Get solution and imgView for piece
        NSDictionary *move = [self.model getSolution:key forBoard:self.curBoard - 1];
        UIImageView *imgView = self.pieceViews[key];
        
        [UIImageView animateWithDuration:kAnimationDuration animations:^{
            // Changing parent view, if needed
            if (imgView.superview == self.view){
                imgView.center = [self.view convertPoint:imgView.center toView:self.boardView];
            }
            [self.boardView addSubview:imgView];
            
            // Transform for rotating piece
            NSInteger moveRotations = [move[@"rotations"] integerValue];
            CGAffineTransform transform;
            transform = CGAffineTransformMakeRotation((CGFloat)(M_PI * kRotation * moveRotations));
            
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
            
            // Setting frame to final location!
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
    [self.boardView setImage:[self.model.boardImages objectAtIndex:self.curBoard]];
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
