//
//  JCLModel.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCLModel : NSObject

+ (id) sharedInstance;
- (NSNumber *) generateID;

- (NSDictionary *) listOfPlayers;

@end
