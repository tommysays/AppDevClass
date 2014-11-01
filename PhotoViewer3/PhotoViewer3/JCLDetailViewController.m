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
    NSLog(@"About to segue.");
    if ([segue.identifier isEqualToString:@"DetailToZoom"]){
        NSLog(@"Segue from detail to zoom.");
        JCLZoomViewController *destController = segue.destinationViewController;
        destController.passedImage = self.imgView.image;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
