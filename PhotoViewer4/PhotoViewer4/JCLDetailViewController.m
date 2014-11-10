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
#import "JCLModel.h"

@interface JCLDetailViewController () <UITextFieldDelegate, UITextViewDelegate>

@property CGRect startingFrame;
@property JCLModel *model;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation JCLDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
    self.model = [JCLModel sharedInstance];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.descriptionField.text = [self.model descriptionOfImage:self.modelIndexPath.row fromSet:self.modelIndexPath.section];
    self.isUnwound = YES;
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.userInteractionEnabled = YES;
    self.imgView.center = CGPointMake(self.view.center.x, self.imgView.center.y);
    self.caption.center = CGPointMake(self.view.center.x, self.caption.center.y);
    [self.caption setEnabled:false];
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

#pragma mark Edit methods

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.caption setEnabled:editing];
}

#pragma mark - Split view
- (void) splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController{
    
    barButtonItem.title = NSLocalizedString(@"Parks", @"Parks");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
}

- (void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    [self.navigationItem setLeftBarButtonItem:nil];
}

#pragma mark TextField Delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"text begin edit.");
}

- (void) textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"Did end editing.");
    
}

- (void)keyboardWillBeShown:(NSNotification*)notification{
    NSDictionary *info = [notification userInfo];
    NSLog(@"sfsf");
    CGRect frame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize keyboardSize = frame.size;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
}
- (void)keyboardWillHide:(NSNotification*)notification{
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

#pragma mark Segue Methods

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (!self.captionText){
        return false;
    }
    return true;
}

- (void) willMoveToParentViewController:(UIViewController *)parent{
    [self.model changeCaption:self.caption.text forImage:self.modelIndexPath.row forSet:self.modelIndexPath.section];
    [self.model changeDescription:self.descriptionField.text forImage:self.modelIndexPath.row forSet:self.modelIndexPath.section];
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
