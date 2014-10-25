//
//  JCLScrollView.m
//  PhotoViewer2
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/25/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLScrollView.h"
#import "JCLConstants.h"

@implementation JCLScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.minimumZoomScale = kMinimumZoomScale;
        self.maximumZoomScale = kMaximumZoomScale;
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self adjustContentSize];
	CGFloat offsetX = MAX((self.bounds.size.width - self.contentSize.width) / 2, 0.0);
	CGFloat offsetY = MAX((self.bounds.size.height - self.contentSize.height) / 2, 0.0);
	self.imgView.center = CGPointMake(self.contentSize.width / 2 + offsetX, self.contentSize.height / 2 + offsetY);
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView{
}

- (void) adjustContentSize{
    CGFloat width = self.imgView.image.size.width;
    CGFloat height = self.imgView.image.size.height;
    CGFloat	ratio = height/width;
    CGFloat offset = (ratio * self.bounds.size.width * self.zoomScale);
    self.contentSize = CGSizeMake(self.bounds.size.width*self.zoomScale, offset);
}

@end
