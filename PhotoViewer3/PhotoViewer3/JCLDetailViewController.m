//
//  JCLDetailViewController.m
//  PhotoViewer3
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLZoomViewController.h"
#import "JCLDetailViewController.h"
#import "JCLScrollView.h"

@interface JCLDetailViewController ()

@property CGRect startingFrame;

@end

@implementation JCLDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imgView.image = self.image;
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.userInteractionEnabled = YES;
    self.caption.text = self.captionText;
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"DetailToZoom"]){
        JCLZoomViewController *destController = segue.destinationViewController;
        destController.passedImage = self.imgView.image;
        destController.navigationItem.title = self.captionText;
    }
}

@end
