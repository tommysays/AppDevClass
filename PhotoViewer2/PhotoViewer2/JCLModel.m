//
//  JCLModel.m
//  PhotoViewer
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/19/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLModel.h"

@implementation JCLModel

@property (strong, nonatomic) NSArray *photosetArray;
@property (strong, nonatomic) NSDictionary *images;
@property NSInteger maxSetSize;

- (void) initImages{
    [self readFromFile];
    [self loadImages];
}
- (void) readFromFile{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Photos" ofType:@"plist"];
    self.photosetArray = [[NSArray alloc] initWithContentsOfFile:path];
}

- (void) loadImages{
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    NSInteger size = [self.photosetArray count];
    self.maxSetSize = 0;
    for (NSInteger i = 0; i < size; i++){
        NSDictionary *photoset = [self.photosetArray objectAtIndex:i];
        NSArray *imgData = [photoset objectForKey:@"photos"];
        for (NSDictionary *imgDict in imgData){
            NSString *imgName = [imgDict objectForKey:@"imageName"];
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", imgName]];
            [temp setObject:img forKey:imgName];
        }
        if (self.maxSetSize < [imgData count]){
            self.maxSetSize = [imgData count];
        }
    }
    self.images = temp;
}

- (NSInteger) numberOfSets{
    return [self.photosetArray count];
}

- (NSInteger) maxSizeOfSet{
    return self.maxSetSize;
}

- (NSInteger) sizeOfSet:(NSInteger)photosetIndex{
    NSDictionary *photoset = [self.photosetArray objectAtIndex:photosetIndex];
    NSInteger size = [[photoset objectForKey:@"photos"] count];
    return size;
}

- (NSString *) nameOfSet:(NSInteger)photosetIndex{
    NSDictionary *photoset = [self.photosetArray objectAtIndex:photosetIndex];
    return [photoset objectForKey:@"name"];
}

- (UIImage *) image:(NSInteger)imgIndex fromSet:(NSInteger)photosetIndex{
    NSDictionary *dict = [self.photosetArray objectAtIndex:photosetIndex];
    NSArray *photos = [dict objectForKey:@"photos"];
    NSString *name = [[photos objectAtIndex:imgIndex] objectForKey:@"imageName"];
    return [self.images objectForKey:name];
}

@end
