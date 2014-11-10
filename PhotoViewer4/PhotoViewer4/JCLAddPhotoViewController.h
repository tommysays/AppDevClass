//
//  JCLAddPhotoViewController.h
//  PhotoViewer4
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/9/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCLTableViewController.h"

@interface JCLAddPhotoViewController : UIViewController

@property NSInteger selectedPark;
@property UIImage *selectedImage;
@property BOOL didCancel;

@property JCLTableViewController *parentView;

@end
