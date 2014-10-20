//
//  JCLViewController.m
//  PhotoViewer
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/19/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLViewController.h"

@interface JCLViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowUp;
@property (weak, nonatomic) IBOutlet UIImageView *arrowDown;
@property (weak, nonatomic) IBOutlet UIImageView *arrowLeft;
@property (weak, nonatomic) IBOutlet UIImageView *arrowRight;


@property (strong, nonatomic) JCLModel *model;
@property (strong, nonatomic) UIScrollView *zoomScroll;
@property (strong, nonatomic) UIImageView *zoomImage;
@property NSInteger curSet; // What set we are showing
@property NSInteger curImageIndex; // Index of the image being shown.
@property CGPoint lastOffset;

@property CGPoint dragStart;
@property BOOL isAtTop;
@property BOOL moveVertical;
@property BOOL moveHorizontal;
@property BOOL isZoomed;
@property CGFloat lastScale;

@property NSTimer *arrowTimer;

@end

const NSTimeInterval kArrowFadeTime = 1.0;
const CGFloat kLabelHeight = 4; // Higher numbers = higher label.
const CGFloat kMinZoomScale = 1.0;
const CGFloat kMaxZoomScale = 10.0;

@implementation JCLViewController

# pragma mark Initialization Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lastScale = 1.0;
    self.curSet = 0;
    self.curImageIndex = 0;
    self.isAtTop = YES;
    self.isZoomed = NO;
    self.moveVertical = false;
    self.moveHorizontal = false;
    self.model = [[JCLModel alloc] init];
    
    [self.model initImages];
    [self setupScrollView];
    [self resetArrowsWithX:0 andY:0];
}

- (void) setupScrollView{
    CGSize viewSize = self.view.bounds.size;
    NSInteger width = [self.model numberOfSets];
    NSInteger height = [self.model maxSizeOfSet];
    
    UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
    
    self.zoomScroll = [[UIScrollView alloc] init];
    [self.view addSubview:self.zoomScroll];
    self.zoomScroll.minimumZoomScale = kMinZoomScale;
    self.zoomScroll.maximumZoomScale = kMaxZoomScale;
    self.zoomScroll.frame = self.view.frame;
    self.zoomScroll.contentSize = self.zoomScroll.bounds.size;
    self.zoomScroll.bounces = true;
    //self.zoomScroll.backgroundColor = [UIColor blackColor];
    self.zoomScroll.hidden = true;
    self.zoomScroll.delegate = self;
    
    recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    recognizer.delegate = self;
    [self.zoomScroll addGestureRecognizer:recognizer];
    
    [self.mainScrollView setContentSize:CGSizeMake(viewSize.width * width, viewSize.height * height)];
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.directionalLockEnabled = YES;
    self.mainScrollView.minimumZoomScale = kMinZoomScale;
    self.mainScrollView.maximumZoomScale = kMinZoomScale;
    self.mainScrollView.delegate = self;
    [self loadImages];
}

- (void) loadImages{
    CGFloat width = self.mainScrollView.bounds.size.width;
    CGFloat height = self.mainScrollView.bounds.size.height;
    CGFloat labelX = 0;
    CGFloat labelY = height / kLabelHeight;
    CGRect labelFrame = CGRectMake(labelX, labelY, width, height / kLabelHeight);
    for (NSInteger i = 0; i < self.model.numberOfSets; i++){
        for (NSInteger j = 0; j < [self.model sizeOfSet:i]; j++){
            CGFloat x = i * width;
            CGFloat y = j * height;
            CGRect frame = CGRectMake(x, y, width, height);
            UIView *view = [[UIView alloc] initWithFrame:frame];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.bounds];
            imgView.image = [self.model image:j fromSet:i];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            [view addSubview:imgView];
            if (j == 0){
                UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
                label.text = [self.model nameOfSet:i];
                label.textAlignment = NSTextAlignmentCenter;
                label.shadowColor = [UIColor whiteColor];
                [view addSubview:label];
            }
            [self.mainScrollView addSubview:view];
        }
    }
}

#pragma mark Arrow Methods

- (void) resetArrowsWithX:(CGFloat)xOffset andY:(CGFloat)yOffset{
    [self.arrowTimer invalidate];
    [self hideArrows];
    if (yOffset < [self.model sizeOfSet:xOffset] - 1){
        self.arrowDown.hidden = false;
    }
    if (yOffset > 0){
        self.arrowUp.hidden = false;
    } else{
        if (xOffset < [self.model numberOfSets] - 1){
            self.arrowRight.hidden = false;
        }
        if (xOffset > 0){
            self.arrowLeft.hidden = false;
        }
    }
    // After a bit, timer will hide all arrows.
    self.arrowTimer = [NSTimer scheduledTimerWithTimeInterval:kArrowFadeTime target:self selector:@selector(hideArrows) userInfo:nil repeats:NO];
}

- (void) hideArrows{
    self.arrowUp.hidden = true;
    self.arrowDown.hidden = true;
    self.arrowLeft.hidden = true;
    self.arrowRight.hidden = true;
}

#pragma mark ScrollView Zoom

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.zoomImage;
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if (self.zoomScroll.zoomScale == 1.0){
        self.zoomScroll.hidden = true;
        self.mainScrollView.hidden = false;
    }
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer{
    if (self.zoomScroll.hidden == true){
        for (UIView *view in self.zoomScroll.subviews){
            [view removeFromSuperview];
        }
        self.zoomScroll.hidden = false;
        self.mainScrollView.hidden = true;
        self.zoomImage = [[UIImageView alloc] initWithFrame:self.zoomScroll.frame];
        CGFloat xOffset = [self.mainScrollView contentOffset].x;
        CGFloat yOffset = [self.mainScrollView contentOffset].y;
        xOffset /= self.mainScrollView.bounds.size.width;
        yOffset /= self.mainScrollView.bounds.size.height;
        self.zoomImage.image = [self.model image:yOffset fromSet:xOffset];
        self.zoomImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.zoomScroll addSubview:self.zoomImage];
    }
    [self.zoomScroll setZoomScale:(self.lastScale * recognizer.scale) animated:YES];
    
    if (recognizer.state == UIGestureRecognizerStateEnded){
        self.lastScale = self.zoomScroll.zoomScale;
        if (self.zoomScroll.zoomScale == 1.0){
            self.zoomScroll.hidden = true;
            self.mainScrollView.hidden = false;
        }
    }
}

#pragma mark ScrollView Drag

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.zoomScroll){
        return;
    }
    self.moveHorizontal = false;
    self.moveVertical = false;
    self.dragStart = scrollView.contentOffset;
    CGFloat xOffset = [scrollView contentOffset].x;
    CGFloat yOffset = [scrollView contentOffset].y;
    xOffset /= scrollView.bounds.size.width;
    yOffset /= scrollView.bounds.size.height;
    [self resetArrowsWithX:xOffset andY:yOffset];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.zoomScroll){
        return;
    }
    CGFloat xOffset = [scrollView contentOffset].x;
    CGFloat yOffset = [scrollView contentOffset].y;
    xOffset /= scrollView.bounds.size.width;
    yOffset /= scrollView.bounds.size.height;
    if (yOffset == 0){
        self.isAtTop = YES;
    } else{
        self.isAtTop = NO;
    }
    CGFloat width = scrollView.contentSize.width;
    CGFloat height = scrollView.bounds.size.height * [self.model sizeOfSet:xOffset];
    scrollView.contentSize = CGSizeMake(width, height);
    
    [self resetArrowsWithX:xOffset andY:yOffset];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.zoomScroll){
        return;
    }
    if (!self.isAtTop || self.moveVertical){
        scrollView.contentOffset = CGPointMake(self.dragStart.x, scrollView.contentOffset.y);
    } else if (self.moveHorizontal){
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, self.dragStart.y);
    } else{
        if (scrollView.contentOffset.x == self.dragStart.x){
            self.moveVertical = true;
            scrollView.contentOffset = CGPointMake(self.dragStart.x, scrollView.contentOffset.y);
        } else{
            self.moveHorizontal = true;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, self.dragStart.y);
        }
    }
    CGFloat xOffset = [scrollView contentOffset].x;
    CGFloat yOffset = [scrollView contentOffset].y;
    xOffset /= scrollView.bounds.size.width;
    yOffset /= scrollView.bounds.size.height;
    [self resetArrowsWithX:xOffset andY:yOffset];
}



@end
