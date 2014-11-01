//
//  JCLDetailViewController.h
//  PhotoViewer3
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCLDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *caption;

@property (nonatomic, strong) NSString *captionText;
@property (nonatomic, strong) UIImage *image;

@end
