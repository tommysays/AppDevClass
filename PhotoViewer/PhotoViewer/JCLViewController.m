//
//  JCLViewController.m
//  PhotoViewer
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/19/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLViewController.h"

@interface JCLViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (strong, nonatomic) JCLModel *model;
@property (strong, nonatomic) UIScrollView *verticalScroll;
@property (strong, nonatomic) UIScrollView *zoomScroll;
@property NSInteger curSet; // What set we are showing
@property NSInteger curImageIndex; // Index of the image being shown.

@end

@implementation JCLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.model = [[JCLModel init] alloc];
    self.verticalScroll = [[UIScrollView alloc] init];
    self.zoomScroll = [[UIScrollView alloc] init];
    [self.model initImages];
    [self setup];
}

- (void) setup{
    self.curSet = 0;
    self.curImageIndex = 0;
}

@end
