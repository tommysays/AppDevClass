//
//  JCLModel.h
//  PhotoViewer
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/19/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCLModel : NSObject

// Accessors:

+ (id) sharedInstance;
- (NSInteger) maxSizeOfSet;
- (NSInteger) numberOfSets;
- (NSInteger) sizeOfSet:(NSInteger)photosetIndex;
- (NSString *) nameOfSet:(NSInteger)photosetIndex;
- (NSString *) nameOfImage:(NSInteger)imgIndex fromSet:(NSInteger)photosetIndex;
- (UIImage *) nationalParkImage;
- (UIImage *) image:(NSInteger)imgIndex fromSet:(NSInteger)photosetIndex;
- (NSString *) descriptionOfImage:(NSInteger)imgIndex fromSet:(NSInteger)photosetIndex;

// Mutators:

- (NSInteger) addPark:(NSString *)parkName;
- (void) addImage:(UIImage *)image toSet:(NSInteger)photosetIndex;
- (void) changeCaption:(NSString *)caption forImage:(NSInteger)imgIndex forSet:(NSInteger)photosetIndex;
- (void) changeDescription:(NSString *)description forImage:(NSInteger)imgIndex forSet:(NSInteger)photosetIndex;
- (void) moveImageFrom:(NSInteger)sourceImgIndex to:(NSInteger)destImgIndex fromSet:(NSInteger)photosetIndex;
- (void) removeImage:(NSInteger)imgIndex fromSet:(NSInteger)photosetIndex;
@end
