//
//  DataManager.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "DataManager.h"

@interface DataManager ()
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic,copy) NSString *projectName;

@end

@implementation DataManager


+(id)sharedInstance {
    static id singleton = nil;
    @synchronized(self) {
        if (singleton == nil) {
            singleton = [[self alloc] init];
        }
    }
    
    return singleton;
}

// Once the delegate is set we can ask it to create the database if it doesn't exist
-(void)setDelegate:(id<DataManagerDelegate>)delegate {
    _delegate = delegate;
    self.projectName = [delegate xcDataModelName];
    if (![self databaseExists]) {
        [self.delegate createDatabase];
    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort(); // TODO remove this.
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.projectName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSString *sqliteName = [NSString stringWithFormat:@"%@.sqlite", self.projectName];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:sqliteName];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


#pragma File System

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)databasePath
{
    NSString *sqlite = [NSString stringWithFormat:@"%@.sqlite", self.projectName];
	return [[self applicationDocumentsDirectory] URLByAppendingPathComponent: sqlite];
}


- (BOOL)databaseExists
{
	NSURL	*url = [self databasePath];
	BOOL	databaseExists = [[NSFileManager defaultManager] fileExistsAtPath:[url path]];
	
	return databaseExists;
}

#pragma mark - Fetching Data

- (NSArray *)fetchManagedObjectsForEntity:(NSString*)entityName
                                 sortKeys:(NSArray*)sortKeys
                                predicate:(NSPredicate *)predicate
{
	NSFetchRequest	*request = [NSFetchRequest fetchRequestWithEntityName:entityName];
	request.predicate = predicate;
	
    // create array of sort descriptors from array of sort keys
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
    for (NSString *key in sortKeys) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
        [sortDescriptors addObject:sortDescriptor];
    }
	request.sortDescriptors=sortDescriptors ;
	
    NSManagedObjectContext	*context = [self managedObjectContext];
	NSArray	*results = [context executeFetchRequest:request error:nil];
	return results;
}



@end
