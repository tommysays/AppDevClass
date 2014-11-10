//
//  JCLDetailViewController.h
//  PhotoViewer3
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCLZoomViewController.h"


@interface JCLDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UITextField *caption;
@property (weak, nonatomic) IBOutlet UITextView *descriptionField;

@property (nonatomic, strong) NSString *captionText;
@property (nonatomic, strong) UIImage *image;

@property NSIndexPath *modelIndexPath;

@property BOOL isUnwound;
@property JCLZoomViewController *zoomController;

- (void) reloadData;
@end
