//
//  JCLCollectionViewCell.m
//  PhotoViewer2
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/23/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLCollectionViewCell.h"

@implementation JCLCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void) setImage:(UIImage *)img{
    self.img.image = img;
    self.img.bounds = self.bounds;
    self.img.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    self.img.contentMode = UIViewContentModeScaleAspectFit;
}

@end
