//
//  MyDataManager.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManagerDelegate.h"
#import "AI.h"
#import "Player.h"
#import "Score.h"
#import "Volume.h"
#import "Theme.h"

@interface MyDataManager : NSObject <DataManagerDelegate>

- (Theme *) addTheme;
- (Volume *) addVolume;
- (AI *) addAIWithDictionary:(NSDictionary *)dict;
- (Player *) addPlayerWithDictionary:(NSDictionary *)dict;
- (Score *) addScoreWithDictionary:(NSDictionary *)dict;

@end
