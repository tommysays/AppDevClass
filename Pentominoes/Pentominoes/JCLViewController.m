//
//  JCLViewController.m
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//


#import "JCLViewController.h"
#import "JCLModel.h"
#import "JCLImageView.h"

@interface JCLViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *boardView;
@property (weak, nonatomic) IBOutlet UIButton *solveButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
- (IBAction)boardButtonPressed:(UIButton *)sender;
- (IBAction)solvePresssed:(id)sender;
- (IBAction)resetPressed:(id)sender;
- (void) snapToBoard:(JCLImageView *)view withTransform:(CGAffineTransform)transform;

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
    [self.boardView setUserInteractionEnabled:true];
    self.model = [[JCLModel alloc] init];
    [self.model loadData];
    [self initPieceViews];
}

# pragma mark Initialization Methods

// Placing pieces in their initial position and adds Tap and Pan recognizers to them.
- (void) initPieceViews{
    // Initializing dictionary of ImageViews
    self.pieceViews = [[NSMutableDictionary alloc] init];
    
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
    
    
    for (NSString *key in self.model.keys){
        UIImage *img = self.model.pieceImages[key];
        
        // Initializing piece and recognizers for it.
        JCLImageView *piece = [[JCLImageView alloc] initWithImage:img];
        [self initRecognizers:piece];
        
        // Setting starting location
        CGSize imgSize = [[piece image] size];
        x = xCounter * (padding + kMaxPieceWidth) + padding;
        CGPoint pt = CGPointMake(x, y);
        piece.portraitCoords = pt;
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

// Initializes and adds recognizers for a piece.
- (void) initRecognizers:(JCLImageView *)view{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToPan:)];
    //[panRecognizer requireGestureRecognizerToFail:singleTap];
    //[panRecognizer requireGestureRecognizerToFail:doubleTap];
    
    // Adding recognizers
    [view addGestureRecognizer:singleTap];
    [view addGestureRecognizer:doubleTap];
    [view addGestureRecognizer:panRecognizer];
}

# pragma mark Recognizers

- (void) respondToSingleTap:(UITapGestureRecognizer *)recognizer{
    JCLImageView *view = (JCLImageView *)recognizer.view;
    [UIView animateWithDuration:kSnapAnimationDuration animations:^{
        NSMutableDictionary *moves = view.userMoves;
        NSInteger rotations = [moves[@"rotations"] integerValue];
        NSInteger flips = [moves[@"flips"] integerValue];
        rotations++;
        if (rotations >= kMaxRotations){
            rotations -= kMaxRotations;
        }
        
        CGAffineTransform transform;
        transform = CGAffineTransformMakeRotation((CGFloat)(M_PI * kRotation * rotations));
        
        CGFloat x, y;
        if (flips % 2 != 0){
            x = -1.0f;
            y = 1.0f;
            view.transform = CGAffineTransformScale(transform, x, y);
        } else {
            view.transform = transform;
        }
        
        // Setting new number of rotations
        moves[@"rotations"] = [NSNumber numberWithInteger:rotations];
        
    } completion:^(BOOL finished){
        
    }];
}

- (void) respondToDoubleTap:(UITapGestureRecognizer *)recognizer{
    JCLImageView *view = (JCLImageView *)recognizer.view;
    [UIView animateWithDuration:kSnapAnimationDuration animations:^{
        NSMutableDictionary *moves = view.userMoves;
        NSInteger rotations = [moves[@"rotations"] integerValue];
        NSInteger flips = [moves[@"flips"] integerValue];
        flips++;
        
        CGAffineTransform transform;
        transform = CGAffineTransformMakeRotation((CGFloat)(M_PI * kRotation * rotations));
        
        CGFloat x, y;
        if (flips % 2 != 0){
            x = -1.0f;
            y = 1.0f;
            view.transform = CGAffineTransformScale(transform, x, y);
            flips = 1; // An odd number of flips is the same as exactly 1 flip.
        } else {
            flips = 0; // An even number of flips is the same as no flips at all.
            view.transform = transform;
        }
        
        // Setting new number of flips
        moves[@"flips"] = [NSNumber numberWithInteger:flips];
        
    } completion:^(BOOL finished){
        
    }];
}

- (void) respondToPan:(UIPanGestureRecognizer *)recognizer{
    static JCLImageView *view;
    static CGAffineTransform transform;
    
    switch (recognizer.state){
        case UIGestureRecognizerStateBegan:
        {
            view = (JCLImageView *)recognizer.view;
            NSMutableDictionary *moves = view.userMoves;
            // Preserving any rotations or flips applied by user
            NSInteger rotations = [moves[@"rotations"] integerValue];
            NSInteger flips = [moves[@"flips"] integerValue];
            transform = CGAffineTransformMakeRotation((CGFloat)(M_PI * kRotation * rotations));
            if (flips % 2 != 0){
                transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint oldCenter = view.center;
            CGPoint translation = [recognizer translationInView:view.superview];
            CGPoint newCenter = CGPointMake(oldCenter.x + translation.x, oldCenter.y + translation.y);
            view.center = newCenter;
            [recognizer setTranslation:CGPointZero inView:view.superview];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            // If it's in the board, check to see if we need to remove it.
            if (view.superview == self.boardView){
                CGRect viewFrame = view.frame;
                CGRect boardFrame = self.boardView.frame;
                // Check bounds of piece to see if we need to remove it from board.
                
                if (viewFrame.origin.x + .5 * kBlockWidth < 0 ||
                    viewFrame.origin.y + .5 * kBlockHeight < 0 ||
                    viewFrame.origin.x + viewFrame.size.width - .5 * kBlockWidth > boardFrame.size.width ||
                    viewFrame.origin.y + viewFrame.size.height - .5 * kBlockHeight > boardFrame.size.height){
                    
                    // Piece is out of bounds, so we switch its parent view and reset its
                    // position, rotation, and flip. (As if the reset was pressed).
                    [self resetPiece:view];
                    
                } else{
                    [self snapToBoard:view withTransform:transform];
                }
            } else{
                // Otherwise, check to see if we need to place piece in board.
                CGRect frame = view.frame;
                CGRect boardFrame = self.boardView.frame;
                
                // If the peice is within half a block of the board, we add snap it to the board.
                if (frame.origin.x + .5 * kBlockWidth > boardFrame.origin.x &&
                    frame.origin.y + .5 * kBlockHeight > boardFrame.origin.y &&
                    frame.origin.x + frame.size.width - .5 * kBlockWidth < boardFrame.origin.x + boardFrame.size.width &&
                    frame.origin.y + frame.size.height - .5 * kBlockHeight < boardFrame.origin.y + boardFrame.size.height){
                    
                    [self snapToBoard:view withTransform:transform];
                }
            }
        }
            break;
            
        default:;
            break;
    }
}

- (void) snapToBoard:(JCLImageView *)view withTransform:(CGAffineTransform)transform{
    [self.view setUserInteractionEnabled:false];
    [JCLImageView animateWithDuration:kSnapAnimationDuration animations:^{
        if (view.superview != self.boardView){
            view.center = [self.view convertPoint:view.center toView:self.boardView];
        }
        [self.boardView addSubview:view];
        
        // Preserve user transformations
        view.transform = transform;
        
        // Snapping piece to grid.
        CGFloat x = view.frame.origin.x;
        CGFloat y = view.frame.origin.y;
        NSInteger snapX = roundf(x / kBlockWidth);
        NSInteger snapY = roundf(y / kBlockWidth);
        if (x < 0){
            x = 0;
            snapX = 0;
        }
        if (y < 0){
            y = 0;
            snapY = 0;
        }
        CGPoint newOrigin = CGPointMake(snapX * kBlockWidth, snapY * kBlockHeight);
        CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, view.frame.size.width, view.frame.size.height);
        view.frame = newFrame;
    }completion:^(BOOL finished) {
        [self.view setUserInteractionEnabled:true];
    }];
}

- (void) resetPiece:(JCLImageView *)view{
    [self.view setUserInteractionEnabled:false];
    [JCLImageView animateWithDuration:kAnimationDuration animations:^{
        if (view.superview == self.boardView){
            view.center = [self.boardView convertPoint:view.center toView:self.view];
        }
        [self.view addSubview:view];
        
        // Reset all transformations.
        view.transform = CGAffineTransformIdentity;
        
        // Reset all user moves.
        view.userMoves[@"rotations"] = [NSNumber numberWithInt:0];
        view.userMoves[@"flips"] = [NSNumber numberWithInt:0];
        
        // Translate piece
        CGPoint newOrigin = view.portraitCoords;
        CGSize size = view.frame.size;
        CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, size.width, size.height);
        
        // Setting frame to final location!
        view.frame = newFrame;
    }completion:^(BOOL finished) {
        [self.view setUserInteractionEnabled:true];
    }];
    
}
# pragma mark Button Actions

- (void) reset{
    [self.view setUserInteractionEnabled:false];
    for (NSString *key in self.model.keys){
        JCLImageView *imgView = self.pieceViews[key];
        
        [JCLImageView animateWithDuration:kAnimationDuration animations:^{
            // Changing parent view, if needed
            if (imgView.superview == self.boardView){
                imgView.center = [self.boardView convertPoint:imgView.center toView:self.view];
            }
            [self.view addSubview:imgView];
            
            // Reset all transformations.
            imgView.transform = CGAffineTransformIdentity;
            
            // Reset user transformations;
            imgView.userMoves[@"rotations"] = [NSNumber numberWithInt:0];
            imgView.userMoves[@"flips"] = [NSNumber numberWithInt:0];
            
            // Translate piece
            CGPoint newOrigin = imgView.portraitCoords;
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
    [self.view setUserInteractionEnabled:false];
    for (NSString *key in self.model.keys){
        
        // Get solution and imgView for piece
        NSDictionary *move = [self.model getSolution:key forBoard:self.curBoard - 1];
        JCLImageView *imgView = self.pieceViews[key];
        
        [JCLImageView animateWithDuration:kAnimationDuration animations:^{
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
            
            // Reset all user transformations
            imgView.userMoves[@"rotations"] = [NSNumber numberWithInt:0];
            imgView.userMoves[@"flips"] = [NSNumber numberWithInt:0];
            
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
