//
//  DataManager.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DataManagerDelegate.h"

@interface DataManager : NSObject



@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;


@property (nonatomic,weak) id<DataManagerDelegate>delegate;

+(id)sharedInstance;
-(id) __unavailable init;

- (void)saveContext;
- (NSArray *)fetchManagedObjectsForEntity:(NSString*)entityName
                                 sortKeys:(NSArray*)sortKeys
                                predicate:(NSPredicate *)predicate;

@end
