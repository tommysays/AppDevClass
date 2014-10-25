//
//  JCLCollectionViewCell.h
//  PhotoViewer2
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/23/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef CELLCONSTANTS
#define CELLCONSTANTS

#define CELL_SIZE 90

#endif

@interface JCLCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img;

@end
