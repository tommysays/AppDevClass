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
    
}

@end
