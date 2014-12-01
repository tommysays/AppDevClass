//
//  MyDataManager.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManagerDelegate.h"
#import "Player.h"
#import "Score.h"

@interface MyDataManager : NSObject <DataManagerDelegate>

- (Player *) addPlayerWithDictionary:(NSDictionary *)dict;
- (Score *) addScoreWithDictionary:(NSDictionary *)dict;

@end
