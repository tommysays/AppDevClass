//
//  JCLTableViewCell.h
//  PhotoViewer2
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/24/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCLTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *photoCaption;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
