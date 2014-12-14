//
//  SoundManager.h
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

@interface SoundManager : NSObject

+ (id) sharedInstance;

- (void) updateVolume:(float)vol;
- (void) updateIsOn:(BOOL)isOn;

- (void) playConfirmButton;
- (void) playBackButton;
- (void) playTapForPlayer:(NSInteger)turn;
- (void) playFinalizeForPlayer:(NSInteger)turn;
- (void) playStartGame;
- (void) playGameOver;

@end
