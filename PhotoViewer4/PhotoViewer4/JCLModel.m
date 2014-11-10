//
//  JCLModel.m
//  PhotoViewer
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/19/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLModel.h"

@interface JCLModel ()

@property (strong, nonatomic) NSMutableArray *photosetArray;
@property (strong, nonatomic) NSMutableArray *images;
@property NSInteger maxSetSize;
@property UIImage *natImage;

@end

@implementation JCLModel


// Singleton code taken from class example.
+ (id) sharedInstance{
    static id singleton;
    @synchronized(self) {
        if (!singleton) {
            singleton = [[self alloc] init];
        }
    }
    return singleton;
}

- (id) init{
    self = [super init];
    if (self){
        [self initImages];
    }
    return self;
}


- (void) initImages{
    [self readFromFile];
    [self loadImages];
    [self initializeDescriptions];
}
- (void) readFromFile{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Photos" ofType:@"plist"];
    self.photosetArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
}

- (void) loadImages{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    NSInteger size = [self.photosetArray count];
    self.maxSetSize = 0;
    for (NSInteger i = 0; i < size; i++){
        NSDictionary *photoset = [self.photosetArray objectAtIndex:i];
        NSArray *imgData = [photoset objectForKey:@"photos"];
        NSMutableArray *temp2 = [[NSMutableArray alloc] init];
        for (NSInteger j = 0; j < [imgData count]; j++){
            NSDictionary *imgDict = [imgData objectAtIndex:j];
            NSString *imgName = [imgDict objectForKey:@"imageName"];
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", imgName]];
            [temp2 addObject:img];
        }
        [temp addObject:temp2];
        if (self.maxSetSize < [imgData count]){
            self.maxSetSize = [imgData count];
        }
    }
    UIImage *img = [UIImage imageNamed:@"NationalPark"];
    self.natImage = img;
    self.images = temp;
}

// Initializes all photo descriptions to be blank, unless they have already been set.
- (void) initializeDescriptions{
    for (NSMutableDictionary *imgData in self.photosetArray){
        NSMutableArray *photoArray = [imgData objectForKey:@"photos"];
        for (NSMutableDictionary *photoDict in photoArray){
            if (![photoDict objectForKey:@"descrption"])
                [photoDict setObject:@"" forKey:@"description"];
        }
    }
}

#pragma mark Data Accessors

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

- (NSString *) nameOfImage:(NSInteger)imgIndex fromSet:(NSInteger)photosetIndex{
    NSDictionary *dict = [self.photosetArray objectAtIndex:photosetIndex];
    NSArray *photos = [dict objectForKey:@"photos"];
    NSString *name = [[photos objectAtIndex:imgIndex] objectForKey:@"caption"];
    return name;
}

- (NSString *) descriptionOfImage:(NSInteger)imgIndex fromSet:(NSInteger)photosetIndex{
    NSDictionary *dict = [self.photosetArray objectAtIndex:photosetIndex];
    NSArray *photos = [dict objectForKey:@"photos"];
    NSString *desc = [[photos objectAtIndex:imgIndex] objectForKey:@"description"];
    return desc;
}

- (UIImage *) nationalParkImage{
    return self.natImage;
}

- (UIImage *) image:(NSInteger)imgIndex fromSet:(NSInteger)photosetIndex{
    return [[self.images objectAtIndex:photosetIndex] objectAtIndex:imgIndex];
}

#pragma mark Model mutators

- (void) addPark:(NSString *)parkName{
    NSMutableDictionary *parkDict = [[NSMutableDictionary alloc] init];
    [parkDict setObject:parkName forKey:@"name"];
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [parkDict setObject:photos forKey:@"photos"];
    [self.photosetArray addObject:parkDict];
}

- (void) addImage:(UIImage *)image toSet:(NSInteger)photosetIndex{
    NSMutableDictionary *parkDict = [self.photosetArray objectAtIndex:photosetIndex];
    NSMutableArray *photos = [parkDict objectForKey:@"photos"];
    NSInteger imgIndex = [photos count];
    NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
    [entry setObject:[NSString stringWithFormat:@"%d, %d", photosetIndex, imgIndex] forKey:@"imageName"];
    [entry setObject:@"Untitled" forKey:@"caption"];
    [entry setObject:@"" forKey:@"description"];
    [photos addObject:entry];
    [[self.images objectAtIndex:photosetIndex] addObject:entry];
}

- (void) changeCaption:(NSString *)caption forImage:(NSInteger)imgIndex forSet:(NSInteger)photosetIndex{
    NSMutableDictionary *parkDict = [self.photosetArray objectAtIndex:photosetIndex];
    NSMutableArray *photos = [parkDict objectForKey:@"photos"];
    NSMutableDictionary *entry = [photos objectAtIndex:imgIndex];
    [entry setObject:caption forKey:@"caption"];
}

- (void) changeDescription:(NSString *)description forImage:(NSInteger)imgIndex forSet:(NSInteger)photosetIndex{
    NSMutableDictionary *parkDict = [self.photosetArray objectAtIndex:photosetIndex];
    NSMutableArray *photos = [parkDict objectForKey:@"photos"];
    NSMutableDictionary *entry = [photos objectAtIndex:imgIndex];
    [entry setObject:description forKey:@"description"];
}

- (void) moveImageFrom:(NSInteger)sourceImgIndex to:(NSInteger)destImgIndex fromSet:(NSInteger)photosetIndex{
    NSMutableDictionary *parkDict = [self.photosetArray objectAtIndex:photosetIndex];
    NSMutableArray *photos = [parkDict objectForKey:@"photos"];
    NSMutableDictionary *entry = [photos objectAtIndex:sourceImgIndex];
    [photos removeObjectAtIndex:sourceImgIndex];
    [photos insertObject:entry atIndex:destImgIndex];
    
    UIImage *temp = [[self.images objectAtIndex:photosetIndex] objectAtIndex:sourceImgIndex];
    [[self.images objectAtIndex:photosetIndex] removeObjectAtIndex:sourceImgIndex];
    [[self.images objectAtIndex:photosetIndex] insertObject:temp atIndex:destImgIndex];
}

- (void) removeImage:(NSInteger)imgIndex fromSet:(NSInteger)photosetIndex{
    [[self.images objectAtIndex:photosetIndex] removeObjectAtIndex:imgIndex];
    [[self.photosetArray objectAtIndex:photosetIndex] removeObjectAtIndex:imgIndex];
}

@end
