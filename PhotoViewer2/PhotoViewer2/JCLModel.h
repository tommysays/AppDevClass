//
//  JCLModel.h
//  PhotoViewer
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/19/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCLModel : NSObject

+ (id) sharedInstance;
- (NSInteger) maxSizeOfSet;
- (NSInteger) numberOfSets;
- (NSInteger) sizeOfSet:(NSInteger)photosetIndex;
- (NSString *) nameOfSet:(NSInteger)photosetIndex;
- (NSString *) nameOfImage:(NSInteger)imgIndex fromSet:(NSInteger)photosetIndex;
- (UIImage *) image:(NSInteger)imgIndex fromSet:(NSInteger)photosetIndex;

@end
