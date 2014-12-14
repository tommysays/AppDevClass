//
//  Volume+Cat.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "Volume+Cat.h"

@implementation Volume (Cat)

- (void) changeVolume:(float)vol{
    self.volume = [NSNumber numberWithFloat:vol];
}

- (void) updateIsOn:(BOOL)isOn{
    self.isOn = [NSNumber numberWithBool:isOn];
}

@end
