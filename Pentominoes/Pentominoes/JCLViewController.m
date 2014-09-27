//
//  JCLViewController.m
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//


#import "JCLViewController.h"
#import "JCLInfoViewController.h"
#import "JCLModel.h"
#import "JCLImageView.h"

@interface JCLViewController ()
@property (retain, nonatomic) IBOutlet UIImageView *boardView;
@property (retain, nonatomic) IBOutlet UIButton *solveButton;
@property (retain, nonatomic) IBOutlet UIButton *resetButton;
- (IBAction)boardButtonPressed:(UIButton *)sender;
- (IBAction)solvePresssed:(id)sender;
- (IBAction)resetPressed:(id)sender;
- (void) snapToBoard:(JCLImageView *)view withTransform:(CGAffineTransform)transform;

@property NSInteger width, height;
@property NSInteger curBoard;
@property NSInteger solved;
@property (nonatomic, retain) NSMutableDictionary *pieceViews;
@property (nonatomic, retain) JCLModel *model;
@property (nonatomic) UIDeviceOrientation orientation;
//@property NSInteger orientation;

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
    self.orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    self.model = [[JCLModel alloc] init];
    [self.model loadData];
    [self initPieceViews];
}

# pragma mark Initialization Methods

// Placing pieces in their initial position and adds Tap and Pan recognizers to them.
- (void) initPieceViews{
    // Initializing dictionary of ImageViews
    self.pieceViews = [[NSMutableDictionary alloc] init];
    
    // Calculating for portrait modes.
    NSInteger tilesAcross = self.width / kMaxPieceWidth;
    NSInteger tilesDown = kNumPieces / tilesAcross;
    if (kNumPieces % tilesAcross != 0){
        tilesDown++;
    }
    NSInteger remainder = self.width % kMaxPieceWidth;
    NSInteger padding = remainder / tilesAcross;
    NSInteger x = padding;
    NSInteger y = kPortraitY;
    NSInteger xCounter = 0;
    
    for (NSString *key in self.model.keys){
        UIImage *img = self.model.pieceImages[key];
        
        // Initializing piece and recognizers for it.
        JCLImageView *piece = [[[JCLImageView alloc] initWithImage:img] autorelease];
        [self initRecognizers:piece];
        
        // Setting starting location
        x = xCounter * (padding + kMaxPieceWidth) + padding;
        CGPoint pt = CGPointMake(x, y);
        [piece setStartingCoord:pt forOrientation:UIDeviceOrientationPortrait];
        [piece setStartingCoord:pt forOrientation:UIDeviceOrientationPortraitUpsideDown];
        piece.contentMode = UIViewContentModeTopLeft;
        
        [self.pieceViews setObject:piece forKey:key];
        
        xCounter++;
        if (xCounter >= tilesAcross){
            xCounter = 0;
            y += kMaxPieceHeight + padding;
        }
    }
    
    // Recalculating for landscape modes.
    tilesAcross = self.height / kMaxPieceWidth;
    tilesDown = kNumPieces / tilesAcross;
    if (kNumPieces % tilesAcross != 0){
        tilesDown++;
    }
    remainder = self.height % kMaxPieceWidth;
    padding = remainder / tilesAcross;
    x = padding;
    y = kLandscapeY;
    xCounter = 0;
    
    for (NSString *key in self.model.keys){
        JCLImageView *piece = [self.pieceViews objectForKey:key];
        x = xCounter * (padding + kMaxPieceWidth) + padding;
        CGPoint pt = CGPointMake(x, y);
        [piece setStartingCoord:pt forOrientation:UIDeviceOrientationLandscapeLeft];
        [piece setStartingCoord:pt forOrientation:UIDeviceOrientationLandscapeRight];
        
        xCounter++;
        if (xCounter >= tilesAcross){
            xCounter = 0;
            y += kMaxPieceHeight + padding;
        }
    }
    
    
    // Setting pieces to their locations
    for (NSString *key in self.model.keys){
        JCLImageView *piece = [self.pieceViews objectForKey:key];
        CGPoint pt = [piece startingCoords:self.orientation];
        CGRect newFrame = CGRectMake(pt.x, pt.y, piece.frame.size.width, piece.frame.size.height);
        piece.frame = newFrame;
        
        
        NSLog(@"For %@, %@", key, [NSValue valueWithCGPoint:pt]);
        [[self view] addSubview:piece];
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
    
    // Adding recognizers
    [view addGestureRecognizer:singleTap];
    [view addGestureRecognizer:doubleTap];
    [view addGestureRecognizer:panRecognizer];
    
    //TODO dealloc recognizers!
}

# pragma mark Recognizer Methods

- (void) respondToSingleTap:(UITapGestureRecognizer *)recognizer{
    JCLImageView *imgView = (JCLImageView *)recognizer.view;
    [UIView animateWithDuration:kSnapAnimationDuration animations:^{
        NSInteger rotations = [imgView userRotations];
        NSInteger flips = [imgView userFlips];
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
            transform = CGAffineTransformScale(transform, x, y);
        }
        imgView.transform = transform;
        
        x = imgView.frame.origin.x;
        y = imgView.frame.origin.y;
        
        if (imgView.superview == self.boardView){
            // Adjusting the piece to fit in board, since a rotation may put it out of bounds.
            while (x < 0){
                x += kBlockWidth;
            }
            while (y < 0){
                y += kBlockHeight;
            }
            while (x + imgView.frame.size.width > self.boardView.frame.size.width){
                x -= kBlockWidth;
            }
            while (y + imgView.frame.size.height > self.boardView.frame.size.height){
                y -= kBlockWidth;
            }
            CGRect newFrame = CGRectMake(x, y, imgView.frame.size.width, imgView.frame.size.height);
            imgView.frame = newFrame;
            
            [self snapToBoard:imgView withTransform:transform];
        }
        
        // Setting new number of rotations
        [imgView setUserRotations:rotations];
        
    } completion:^(BOOL finished){
        
        
    }];
}

- (void) respondToDoubleTap:(UITapGestureRecognizer *)recognizer{
    JCLImageView *imgView = (JCLImageView *)recognizer.view;
    [UIView animateWithDuration:kSnapAnimationDuration animations:^{
        NSInteger rotations = [imgView userRotations];
        NSInteger flips = [imgView userFlips];
        flips++;
        
        CGAffineTransform transform;
        transform = CGAffineTransformMakeRotation((CGFloat)(M_PI * kRotation * rotations));
        
        CGFloat x, y;
        if (flips % 2 != 0){
            x = -1.0f;
            y = 1.0f;
            imgView.transform = CGAffineTransformScale(transform, x, y);
            flips = 1; // An odd number of flips is the same as exactly 1 flip.
        } else {
            flips = 0; // An even number of flips is the same as no flips at all.
            imgView.transform = transform;
        }
        
        // Setting new number of flips
        [imgView setUserFlips:flips];
        
    } completion:^(BOOL finished){
        
    }];
}

- (void) respondToPan:(UIPanGestureRecognizer *)recognizer{
    static JCLImageView *imgView;
    static CGAffineTransform transform;
    
    switch (recognizer.state){
        case UIGestureRecognizerStateBegan:
        {
            imgView = (JCLImageView *)recognizer.view;
            // Preserving any rotations or flips applied by user
            NSInteger rotations = [imgView userRotations];
            NSInteger flips = [imgView userFlips];
            transform = CGAffineTransformMakeRotation((CGFloat)(M_PI * kRotation * rotations));
            if (flips % 2 != 0){
                transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            }
            // Scaling the piece up a little.
            imgView.transform = CGAffineTransformScale(transform, kPanScale, kPanScale);
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            // Keeping the piece scaled up a little.
            imgView.transform = CGAffineTransformScale(transform, kPanScale, kPanScale);
            
            // Moving the piece as user moves around.
            CGPoint oldCenter = imgView.center;
            CGPoint translation = [recognizer translationInView:imgView.superview];
            CGPoint newCenter = CGPointMake(oldCenter.x + translation.x, oldCenter.y + translation.y);
            imgView.center = newCenter;
            
            // Stopping the translation from accumulating.
            [recognizer setTranslation:CGPointZero inView:imgView.superview];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            // If it's in the board, check to see if we need to remove it.
            if (imgView.superview == self.boardView){
                CGRect viewFrame = imgView.frame;
                CGRect boardFrame = self.boardView.frame;
                // Check bounds of piece to see if we need to remove it from board.
                
                if (viewFrame.origin.x + .5 * kBlockWidth < 0 ||
                    viewFrame.origin.y + .5 * kBlockHeight < 0 ||
                    viewFrame.origin.x + viewFrame.size.width - .5 * kBlockWidth > boardFrame.size.width ||
                    viewFrame.origin.y + viewFrame.size.height - .5 * kBlockHeight > boardFrame.size.height){
                    
                    // Piece is out of bounds, so we switch its parent view and reset its
                    // position, rotation, and flip. (As if the reset was pressed).
                    [self resetPiece:imgView];
                    
                } else{
                    [self snapToBoard:imgView withTransform:transform];
                }
            } else{
                // Otherwise, check to see if we need to place piece in board.
                CGRect frame = imgView.frame;
                CGRect boardFrame = self.boardView.frame;
                
                // If the peice is within half a block of the board, we add snap it to the board.
                if (frame.origin.x + .5 * kBlockWidth > boardFrame.origin.x &&
                    frame.origin.y + .5 * kBlockHeight > boardFrame.origin.y &&
                    frame.origin.x + frame.size.width - .5 * kBlockWidth < boardFrame.origin.x + boardFrame.size.width &&
                    frame.origin.y + frame.size.height - .5 * kBlockHeight < boardFrame.origin.y + boardFrame.size.height){
                    
                    [self snapToBoard:imgView withTransform:transform];
                } else{
                    // Lastly, if none of the other conditions were met, this piece
                    // has moved such that both source and destination were not the board.
                    [self resetPiece:imgView];
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

- (void) resetPiece:(JCLImageView *)imgView{
    [self.view setUserInteractionEnabled:false];
    
    [JCLImageView animateWithDuration:kSnapAnimationDuration animations:^{
        if (imgView.superview == self.boardView){
            imgView.center = [self.boardView convertPoint:imgView.center toView:self.view];
        }
        [self.view addSubview:imgView];
        
        // Reset all transformations.
        imgView.transform = CGAffineTransformIdentity;
        
        // Reset all user moves.
        [imgView setUserRotations:0];
        [imgView setUserFlips:0];
        
        // Translate piece
        CGPoint newOrigin = [imgView startingCoords:self.orientation];
        
        CGSize size = imgView.frame.size;
        CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, size.width, size.height);
        
        // Setting frame to final location!
        imgView.frame = newFrame;
    }completion:^(BOOL finished) {
        [self.view setUserInteractionEnabled:true];
    }];
    
}

# pragma mark Device Rotation Support

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    for (NSString * key in self.model.keys){
        JCLImageView *piece = [self.pieceViews objectForKey:key];
        // Reset pieces only if they are not already on the board.
        if (piece.superview != self.boardView){
            // Place piece in correct starting position.
            CGPoint pt = [piece startingCoords:toInterfaceOrientation];
            CGRect newFrame = CGRectMake(pt.x, pt.y, piece.frame.size.width, piece.frame.size.height);
            piece.frame = newFrame;
            
            // Reset user and solution transformations.
            [piece setUserRotations:0];
            [piece setUserFlips:0];
            piece.transform = CGAffineTransformIdentity;
        }
        
        
    }
    self.orientation = (UIDeviceOrientation)toInterfaceOrientation;
}

# pragma mark Button Actions

- (IBAction)boardButtonPressed:(UIButton *)sender {
    NSInteger tag = sender.tag;
    if (self.curBoard != tag){
        self.curBoard = tag;
        self.solved = -1;
    }
    [self.boardView setImage:[self.model boardImageFor:self.curBoard]];
    if (self.curBoard != 0){
        self.solveButton.enabled = true;
    } else{
        self.solveButton.enabled = false;
    }
}

- (IBAction)solvePresssed:(id)sender {
    [self.view setUserInteractionEnabled:false];
    for (NSString *key in self.model.keys){
        
        JCLImageView *imgView = self.pieceViews[key];
        
        [JCLImageView animateWithDuration:kAnimationDuration animations:^{
            // Changing parent view, if needed
            if (imgView.superview == self.view){
                imgView.center = [self.view convertPoint:imgView.center toView:self.boardView];
            }
            [self.boardView addSubview:imgView];
            
            // Since solution board numbers are offset by 1, we use this instead of curBoard.
            NSInteger solutionBoard = self.curBoard - 1;
            
            // Transform for rotating piece
            NSInteger moveRotations = [self.model solutionRotation:key forBoard:solutionBoard];
            CGAffineTransform transform;
            transform = CGAffineTransformMakeRotation((CGFloat)(M_PI * kRotation * moveRotations));
            
            // Transform for flipping piece
            NSInteger moveFlip = [self.model solutionFlip:key forBoard:solutionBoard];
            CGFloat x, y;
            if (moveFlip != 0){
                x = -1.0f;
                y = 1.0f;
                imgView.transform = CGAffineTransformScale(transform, x, y);
            } else {
                imgView.transform = transform;
            }
            
            // Set all user transformations to solution's transformations.
            [imgView setUserRotations:moveRotations];
            [imgView setUserFlips:moveFlip];
            
            // Translate piece
            NSInteger solutionX = [self.model solutionX:key forBoard:solutionBoard];
            NSInteger solutionY = [self.model solutionY:key forBoard:solutionBoard];
            CGPoint newOrigin = CGPointMake(kBlockWidth * solutionX, kBlockHeight * solutionY);
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

- (IBAction)resetPressed:(id)sender {
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
            [imgView setUserRotations:0];
            [imgView setUserFlips:0];
            
            // Translate piece
            CGPoint newOrigin = [imgView startingCoords:self.orientation];
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

# pragma mark Segue Preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toInfo"]){
        JCLInfoViewController *controller = [segue destinationViewController];
        controller.boardNum = self.curBoard;
    }
}

# pragma mark Dealloc

- (void) dealloc{
    [_pieceViews release];
    [_model release];
    [super dealloc];
}

@end
