//
//  JCLZoomViewController.h
//  PhotoViewer3
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCLScrollView.h"

@interface JCLZoomViewController : UIViewController

@property (strong, nonatomic) JCLScrollView *scrollView;
@property (strong, nonatomic) UIImageView *zoomImg;
@property (nonatomic, strong) UIImage *passedImage;

@end
