//
//  JCLScrollView.h
//  PhotoViewer2
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/25/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCLScrollView : UIScrollView <UIScrollViewDelegate>

//@property (nonatomic, weak) IBOutlet UIImageView *imgView;
- (void) adjustContentSize;

@end
