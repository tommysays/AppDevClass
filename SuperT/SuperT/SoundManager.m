//
//  SoundManager.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "SoundManager.h"
@import AVFoundation;

@interface SoundManager () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioSession *audioSession;
@property float volume;
@property BOOL isSoundOn;
@property NSMutableArray *playing; // Keeps a reference to sounds that are playing, so that they don't mysteriously die.

// Sound effect file names per player, per action.
@property NSArray *tapPlayer1;
@property NSArray *tapPlayer2;
@property NSArray *finalizePlayer1;
@property NSArray *finalizePlayer2;
@property NSURL *gameOverURL;
@property NSURL *startGameURL;
@property NSBundle *main;

@end


@implementation SoundManager

#pragma mark - Initialization

+ (id) sharedInstance{
    static id singleton;
    @synchronized(self){
        if (!singleton){
            singleton = [[self alloc] init];
        }
    }
    return singleton;
}

- (id) init{
    self = [super init];
    if (self) {
        [self initSession];
        [self initURLS];
    }
    return self;
}

- (void) initSession{
    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
}

- (void) initURLS{
    _main = [NSBundle mainBundle];
    NSString *path = [self.main pathForResource:@"Sounds" ofType:@"plist"];
    NSDictionary *soundDict = [NSDictionary dictionaryWithContentsOfFile:path];
    _tapPlayer1 = soundDict[@"tapPlayer1"];
    _tapPlayer2 = soundDict[@"tapPlayer2"];
    _finalizePlayer1 = soundDict[@"finalizePlayer1"];
    _finalizePlayer2 = soundDict[@"finalizePlayer2"];
    _gameOverURL = soundDict[@"gameOver"];
    _startGameURL = soundDict[@"startGame"];
}

#pragma mark - Play Sound

- (void) playConfirmButton{
    // TODO
}

- (void) playBackButton{
    // TODO
}

- (void) playTapForPlayer:(NSInteger)turn{
    NSArray *temp;
    if (turn == 1){
        temp = self.tapPlayer1;
    } else{
        temp = self.tapPlayer2;
    }
    [self playSoundWithNameArray:temp];
}

- (void) playFinalizeForPlayer:(NSInteger)turn{
    NSArray *temp;
    if (turn == 1){
        temp = self.finalizePlayer1;
    } else{
        temp = self.finalizePlayer2;
    }
    [self playSoundWithNameArray:temp];
}

- (void) playStartGame{
    [self playSoundWithNameArray:@[self.startGameURL]];
}

- (void) playGameOver{
    [self playSoundWithNameArray:@[self.gameOverURL]];
}

- (void) playSoundWithNameArray:(NSArray *)nameArray{
    [self removeFinishedSounds];
    if (!self.isSoundOn || [nameArray count] == 0){
        return;
    }
    
    NSInteger randIndex = arc4random_uniform([nameArray count]);
    NSString *randName = nameArray[randIndex];
    
    NSString *path = [self.main pathForResource:randName ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.playing addObject:audioPlayer];
    [audioPlayer play];
    audioPlayer.volume = self.volume;
}

- (void) updateVolume:(float)vol{
    self.volume = vol;
}

- (void) updateIsOn:(BOOL)isOn{
    self.isSoundOn = isOn;
}

#pragma mark - Reference Delete

/*!
 * Removes references to sounds that have finished playing.
 */
- (void) removeFinishedSounds{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (AVAudioPlayer *player in self.playing){
        if ([player isPlaying]){
            [temp addObject:player];
        }
    }
    self.playing = temp;
}

#pragma mark - AVAudioPlayerDelegate methods

- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player{
    // Do I need anything here?
}

- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player withOptions:(NSUInteger) flags{
    // Maybe not.
}

@end
