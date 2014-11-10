//
//  JCLModel.m
//  PhotoViewer
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/19/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLModel.h"

@interface JCLModel ()

@property NSMutableArray *photosetArray;
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
    [self sortParksByName];
}
- (void) readFromFile{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Photos" ofType:@"plist"];
    self.photosetArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
}

- (void) loadImages{
    self.maxSetSize = 0;
    for (NSInteger i = 0; i < [self.photosetArray count]; i++){
        NSMutableDictionary *photoset = [self.photosetArray objectAtIndex:i];
        NSArray *imgData = [photoset objectForKey:@"photos"];
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (NSInteger j = 0; j < [imgData count]; j++){
            NSDictionary *imgDict = [imgData objectAtIndex:j];
            NSString *imgName = [imgDict objectForKey:@"imageName"];
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", imgName]];
            [temp addObject:img];
        }
        [photoset setObject:temp forKey:@"images"];
        
        if (self.maxSetSize < [imgData count]){
            self.maxSetSize = [imgData count];
        }
    }
    UIImage *img = [UIImage imageNamed:@"NationalPark"];
    self.natImage = img;}

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
    NSArray *images = [[self.photosetArray objectAtIndex:photosetIndex] objectForKey:@"images"];
    return [images objectAtIndex:imgIndex];
}

#pragma mark Model mutators

- (NSInteger) addPark:(NSString *)parkName{
    NSMutableDictionary *parkDict = [[NSMutableDictionary alloc] init];
    [parkDict setObject:parkName forKey:@"name"];
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    [parkDict setObject:photos forKey:@"photos"];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    [parkDict setObject:images forKey:@"images"];
    [self.photosetArray addObject:parkDict];
    [self sortParksByName];
    return [self.photosetArray indexOfObject:parkDict];
}

- (void) addImage:(UIImage *)image toSet:(NSInteger)photosetIndex{
    NSMutableDictionary *parkDict = [self.photosetArray objectAtIndex:photosetIndex];
    NSMutableArray *photos = [parkDict objectForKey:@"photos"];
    NSInteger imgIndex = [photos count];
    NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
    // The imageName here is not important, as it is never used later or presented to the user.
    // However, I set one anyway, in case I try to access it later for whatever reason.
    [entry setObject:[NSString stringWithFormat:@"%d, %d", photosetIndex, imgIndex] forKey:@"imageName"];
    [entry setObject:@"Untitled" forKey:@"caption"];
    [entry setObject:@"" forKey:@"description"];
    [photos addObject:entry];
    
    NSMutableArray *images = [parkDict objectForKey:@"images"];
    [images addObject:image];
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
    
    NSMutableArray *images = [parkDict objectForKey:@"images"];
    UIImage *img = [images objectAtIndex:sourceImgIndex];
    [images removeObjectAtIndex:sourceImgIndex];
    [images insertObject:img atIndex:destImgIndex];
}

- (void) removeImage:(NSInteger)imgIndex fromSet:(NSInteger)photosetIndex{
    NSMutableDictionary *parkDict = [self.photosetArray objectAtIndex:photosetIndex];
    NSMutableArray *photos = [parkDict objectForKey:@"photos"];
    [photos removeObjectAtIndex:imgIndex];
    NSMutableArray *images = [parkDict objectForKey:@"images"];
    [images removeObjectAtIndex:imgIndex];
}

- (void) sortParksByName{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [self.photosetArray sortUsingDescriptors:@[sortDescriptor]];
}

@end
