//
//  JCLDetailViewController.m
//  PhotoViewer3
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLDetailViewController.h"
#import "JCLScrollView.h"
#import "JCLConstants.h"

@interface JCLDetailViewController ()

@property CGRect startingFrame;

@end

@implementation JCLDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
    self.isUnwound = YES;
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.userInteractionEnabled = YES;
    self.imgView.center = CGPointMake(self.view.center.x, self.imgView.center.y);
    self.caption.center = CGPointMake(self.view.center.x, self.caption.center.y);
}

- (void) reloadData{
    self.imgView.image = self.image;
    self.caption.text = self.captionText;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [UIView animateWithDuration:kRotationDuration animations:^{
        self.imgView.center = CGPointMake(self.view.center.x, self.imgView.center.y);
        self.caption.center = CGPointMake(self.view.center.x, self.caption.center.y);
    }];
}

#pragma mark - Split view
- (void) splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController{
    
    barButtonItem.title = NSLocalizedString(@"Parks", @"Parks");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
}

- (void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    [self.navigationItem setLeftBarButtonItem:nil];
}

#pragma mark Segue Methods

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (!self.captionText){
        return false;
    }
    return true;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"DetailToZoom"]){
        JCLZoomViewController *destController = segue.destinationViewController;
        self.zoomController = destController;
        destController.passedImage = self.imgView.image;
        destController.navigationItem.title = self.captionText;
        self.isUnwound = NO;
    }
}

@end
