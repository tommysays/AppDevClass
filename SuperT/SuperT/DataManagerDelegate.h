//
//  DataManagerDelegate.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/1/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataManagerDelegate <NSObject>

-(NSString*)xcDataModelName;
-(void)createDatabase;

@end
