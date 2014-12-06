//
//  ComputerAI.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/5/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "ComputerAI.h"

@interface ComputerAI ()



@end

@implementation ComputerAI

- (id) init{
    self = [super init];
    if (self){
        _gameModel = [JCLGameModel sharedInstance];
    }
    return self;
}

- (NSIndexPath *)makeMove{
    return nil;
}

@end
