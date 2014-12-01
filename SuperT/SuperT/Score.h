//
//  Score.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Score : NSManagedObject

@property (nonatomic, retain) NSNumber * player1_ID;
@property (nonatomic, retain) NSNumber * player2_wins;
@property (nonatomic, retain) NSNumber * player1_wins;
@property (nonatomic, retain) NSNumber * player2_ID;

@end
