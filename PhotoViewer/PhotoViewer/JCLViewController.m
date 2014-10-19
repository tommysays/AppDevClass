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

@end

const CGFloat kLabelHeight = 4; // Higher numbers = higher label.

@implementation JCLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.model = [[JCLModel alloc] init];
    self.zoomScroll = [[UIScrollView alloc] init];
    [self.model initImages];
    [self setup];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
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
    if (!self.isAtTop){
        scrollView.contentOffset = CGPointMake(self.dragStart.x, scrollView.contentOffset.y);
    }
}

- (void) setup{
    self.curSet = 0;
    self.curImageIndex = 0;
    self.isAtTop = YES;
    CGSize viewSize = self.view.bounds.size;
    NSInteger width = [self.model numberOfSets];
    NSInteger height = [self.model maxSizeOfSet];
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
            NSLog(@"%@", NSStringFromCGRect(frame));
            UIView *view = [[UIView alloc] initWithFrame:frame];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.bounds];
            imgView.image = [self.model image:j fromSet:i];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            [view addSubview:imgView];
            if (j == 0){
                UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
                label.text = [self.model nameOfSet:i];
                label.textAlignment = NSTextAlignmentCenter;
                [view addSubview:label];
            }
            [self.mainScrollView addSubview:view];
        }
    }
}

@end
