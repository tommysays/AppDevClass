//
//  Player.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Player : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * playerID;
@property (nonatomic, retain) NSNumber * isAI;

@end
