//
//  JCLZoomViewController.m
//  PhotoViewer3
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLConstants.h"
#import "JCLZoomViewController.h"

@interface JCLZoomViewController () <UIScrollViewDelegate>

@end

@implementation JCLZoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView = [[JCLScrollView alloc] initWithFrame:self.view.frame];
    self.zoomImg = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.zoomImg.image = self.passedImage;
    self.zoomImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.zoomImg];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

- (void) viewWillAppear:(BOOL)animated{
    self.scrollView.frame = self.view.frame;
    self.zoomImg.frame = self.view.frame;
    [self adjustContentSize];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [UIView animateWithDuration:kRotationDuration animations:^{
        self.scrollView.center = self.view.center;
    } completion:^(BOOL finished) {
        [self adjustContentSize];
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.zoomImg;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self adjustContentSize];
	CGFloat offsetX = MAX((self.scrollView.bounds.size.width - self.scrollView.contentSize.width) / 2, 0.0);
	CGFloat offsetY = MAX((self.scrollView.bounds.size.height - self.scrollView.contentSize.height) / 2, 0.0);
	self.zoomImg.center = CGPointMake(self.scrollView.contentSize.width / 2 + offsetX, self.scrollView.contentSize.height / 2 + offsetY);
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
}

- (void) adjustContentSize{
    CGFloat width = self.zoomImg.image.size.width;
    CGFloat height = self.zoomImg.image.size.height;
    CGFloat	ratio = height/width;
    CGFloat offset = (ratio * self.scrollView.bounds.size.width * self.scrollView.zoomScale);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width*self.scrollView.zoomScale, offset);
}

@end
