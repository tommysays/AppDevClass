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
@property NSMutableArray *playing; // Keeps a reference to sounds that are playing, so that they don't mysteriously die.

// Sound effect URLS per player, per action.
@property NSArray *tapPlayer1;
@property NSArray *tapPlayer2;
@property NSArray *finalizePlayer1;
@property NSArray *finalizePlayer2;
@property NSURL *gameOverURL;
@property NSURL *startGameURL;

@end


@implementation SoundManager

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSession];
        [self initURLS];
    }
    return self;
}

- (void) initSession {
    _audioSession = [AVAudioSession sharedInstance];
    [_audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
}

- (void) initURLS{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"Sounds" ofType:@"plist"];
    NSDictionary *soundDict = [NSDictionary dictionaryWithContentsOfFile:path];
    _tapPlayer1 = soundDict[@"tapPlayer1"];
    _tapPlayer2 = soundDict[@"tapPlayer2"];
    _finalizePlayer1 = soundDict[@"finalizePlayer1"];
    _finalizePlayer2 = soundDict[@"finalizePlayer2"];
    _gameOverURL = soundDict[@"gameOver"];
    _startGameURL = soundDict[@"startGame"];
}

#pragma mark - Sound Playing

/*!
 * Plays a random tap sound effect from a selection based on whose turn it is.
 * Wow, I did not know I could document like this. Neat!
 * @param turn The player's turn (1 or 2)
 */
- (void) playTapForPlayer:(NSInteger)turn {
    NSArray *temp;
    if (turn == 1){
        temp = self.tapPlayer1;
    } else{
        temp = self.tapPlayer2;
    }
    [self playSoundWithURLArray:temp];
}

- (void) playFinalizeForPlayer:(NSInteger)turn{
    NSArray *temp;
    if (turn == 1){
        temp = self.finalizePlayer1;
    } else{
        temp = self.finalizePlayer2;
    }
    [self playSoundWithURLArray:temp];
}

- (void) playStartGame{
    [self playSoundWithURLArray:@[self.startGameURL]];
}

- (void) playGameOver{
    [self playSoundWithURLArray:@[self.gameOverURL]];
}

- (void) playSoundWithURLArray:(NSArray *)urlArray{
    [self removeFinishedSounds];
    if ([urlArray count] == 0){
        return;
    }
    NSInteger randIndex = arc4random_uniform([urlArray count]);
    NSURL *randURL = urlArray[randIndex];
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:randURL error:nil];
    [self.playing addObject:audioPlayer];
    [audioPlayer play];
}

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
    NSLog(@"Playing count = %d", [self.playing count]);
}

#pragma mark - AVAudioPlayerDelegate methods

- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player {
    // Do I need anything here?
}

- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player withOptions:(NSUInteger) flags{
    // Maybe not.
}

@end
