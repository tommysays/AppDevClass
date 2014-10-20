//
//  JCLViewController.m
//  PhotoViewer
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/19/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLViewController.h"

@interface JCLViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (strong, nonatomic) JCLModel *model;
@property (strong, nonatomic) UIScrollView *zoomScroll;
@property NSInteger curSet; // What set we are showing
@property NSInteger curImageIndex; // Index of the image being shown.

@property CGPoint dragStart;
@property BOOL isAtTop;
@property BOOL moveVertical;
@property BOOL moveHorizontal;
@property BOOL isZoomed;

@end

const CGFloat kLabelHeight = 4; // Higher numbers = higher label.
const CGFloat kMinZoomScale = 1.0;
const CGFloat kMaxZoomScale = 10.0;

@implementation JCLViewController

# pragma mark Initialization Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.curSet = 0;
    self.curImageIndex = 0;
    self.isAtTop = YES;
    self.isZoomed = NO;
    self.moveVertical = false;
    self.moveHorizontal = false;
    self.model = [[JCLModel alloc] init];
    
    [self.model initImages];
    [self setupScrollView];
}

- (void) setupScrollView{
    CGSize viewSize = self.view.bounds.size;
    NSInteger width = [self.model numberOfSets];
    NSInteger height = [self.model maxSizeOfSet];
    
    self.zoomScroll = [[UIScrollView alloc] init];
    self.zoomScroll.delegate = self;
    self.zoomScroll.minimumZoomScale = kMinZoomScale;
    self.zoomScroll.maximumZoomScale = kMaxZoomScale;
    
    self.mainScrollView.minimumZoomScale = kMinZoomScale;
    self.mainScrollView.maximumZoomScale = kMinZoomScale + 1;
    [self.mainScrollView setContentSize:CGSizeMake(viewSize.width * width, viewSize.height * height)];
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.directionalLockEnabled = YES;
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

#pragma mark ScrollView Delegate Methods

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    CGFloat xOffset = [scrollView contentOffset].x;
    CGFloat yOffset = [scrollView contentOffset].y;
    xOffset /= self.mainScrollView.bounds.size.width;
    yOffset /= self.mainScrollView.bounds.size.height;
    CGRect frame = CGRectMake(0, 0, self.mainScrollView.bounds.size.width, self.mainScrollView.bounds.size.height);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.image = [self.model image:yOffset fromSet:xOffset];
    return imgView;
}

- (void) scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    if (self.mainScrollView == scrollView){
        return;
    }
    NSLog(@"b");
    CGFloat xOffset = [scrollView contentOffset].x;
    CGFloat yOffset = [scrollView contentOffset].y;
    xOffset /= scrollView.bounds.size.width;
    yOffset /= scrollView.bounds.size.height;
    CGRect frame = CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.image = [self.model image:yOffset fromSet:xOffset];
    self.zoomScroll.frame = frame;
    self.zoomScroll.contentSize = imgView.image.size;
    [self.view addSubview:self.zoomScroll];
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if (scale == kMinZoomScale){
        [self.zoomScroll removeFromSuperview];
    } else{
        self.isZoomed = YES;
    }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.moveHorizontal = false;
    self.moveVertical = false;
    self.dragStart = scrollView.contentOffset;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
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
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
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
}



@end
