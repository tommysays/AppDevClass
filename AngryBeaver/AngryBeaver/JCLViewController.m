//
//  JCLViewController.m
//  AngryBeaver
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/3/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLViewController.h"
@import CoreMotion;
static CMMotionManager *motionManager;

#ifndef CONSTANTS
#define CONSTANTS
#define kBladeMaxSpeed 150
#define kDensityBlade .7
#define kDensityLog .5
#define kDensityRock 1.9
#define kElasticityLog 0.25
#define kElasticityRock 0.0
#define kButtonFadeTime 0.5
#define kFadeTime 0.75 // Duration of fade for logs, rocks, and blade when struck.
#define kTagBlade 1
#define kTagLog 2
#define kTagRock 3
#define kBladeY 100 // Height where blade starts from, relative to bottom of screen.
#define kLaunchY 20 // Height where obstacles are launched from, relative to top of screen.
#define kGameOverY 400 // Height where game over screen center is, relative to top of screen.
#define kLaunchMaxTimeInterval 150 // Maximum time between obstacles, in deci-seconds.
#define kNumObstacles 4
#define kNumLauncherPositions 4
#define kMaxObstacleStartingSpeed 500
#endif

@interface JCLViewController () <UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
- (IBAction)playButtonPressed:(id)sender;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravity;
@property (strong, nonatomic) UICollisionBehavior *collision;
@property (strong, nonatomic) NSDictionary *images;
@property (copy, nonatomic) NSArray *bladeImages;
@property (strong, nonatomic) NSMutableArray *obstacles;
@property (strong, nonatomic) UIImageView *gameOverMessage;
@property BOOL playing;
@property NSInteger score;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation JCLViewController

# pragma mark Initialization Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.playing = NO;
    self.images = [[NSDictionary alloc] init];
    self.obstacles = [[NSMutableArray alloc] init];
    if (!motionManager) {
        motionManager = [[CMMotionManager alloc] init];
    }
    [self initBehaviors];
    [self loadImages];
    [self createGameOverMessage];
}

- (void) createGameOverMessage{
    self.gameOverMessage = [[UIImageView alloc] initWithImage:[self.images objectForKey:@"gameover"]];
    self.gameOverMessage.center = CGPointMake(self.view.center.x, kGameOverY);
    [self.view addSubview:self.gameOverMessage];
    self.gameOverMessage.hidden = YES;
}

- (void) initBehaviors{
    self.animator = [[UIDynamicAnimator alloc] init];
    self.gravity = [[UIGravityBehavior alloc] init];
    self.collision = [[UICollisionBehavior alloc] init];
    [motionManager startDeviceMotionUpdates];

    // Defining screen boundaries.
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGPoint topLeft = CGPointMake(0, 0);
    CGPoint topRight = CGPointMake(width, 0);
    CGPoint botLeft = CGPointMake(0, height);
    CGPoint botRight = CGPointMake(width, height);
    [self.collision addBoundaryWithIdentifier:@"top" fromPoint:topLeft toPoint:topRight];
    [self.collision addBoundaryWithIdentifier:@"bot" fromPoint:botLeft toPoint:botRight];
    [self.collision addBoundaryWithIdentifier:@"left" fromPoint:topLeft toPoint:botLeft];
    [self.collision addBoundaryWithIdentifier:@"right" fromPoint:topRight toPoint:botRight];

    self.collision.collisionDelegate = self;
    
    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.collision];
}

- (void) loadImages{
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    UIImage *img;
    
    img = [UIImage imageNamed:@"Log1"];
    [temp setObject:img forKey:@"obstacle0"];
    img = [UIImage imageNamed:@"Log2"];
    [temp setObject:img forKey:@"obstacle1"];
    img = [UIImage imageNamed:@"Log3"];
    [temp setObject:img forKey:@"obstacle2"];
    img = [UIImage imageNamed:@"rock"];
    [temp setObject:img forKey:@"obstacle3"];
    img = [UIImage imageNamed:@"GameOver"];
    [temp setObject:img forKey:@"gameover"];
    
    self.bladeImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"blade0"],
                        [UIImage imageNamed:@"blade1"],
                        [UIImage imageNamed:@"blade2"],
                        [UIImage imageNamed:@"blade3"],
                        [UIImage imageNamed:@"blade4"],
                        [UIImage imageNamed:@"blade5"], nil];
    
    self.images = temp;
}

# pragma mark Behavior Definitions

- (void) collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p{
    NSInteger tag1 = [(UIImageView *)item1 tag];
    NSInteger tag2 = [(UIImageView *)item2 tag];
    UIImageView *toRemove;
    if (tag1 == kTagLog && tag2 == kTagBlade){
        toRemove = (UIImageView *)item1;
        self.score++;
    } else if (tag1 == kTagBlade && tag2 == kTagLog){
        toRemove = (UIImageView *)item2;
        self.score++;
    } else if (tag1 == kTagRock && tag2 == kTagBlade){
        toRemove = (UIImageView *)item2;
    } else if (tag1 == kTagBlade && tag2 == kTagRock){
        toRemove = (UIImageView *)item1;
    }
    [self updateScoreLabel];
    if (toRemove){
        [self removeItem:toRemove];
        if ([toRemove tag] == kTagBlade){
            [self gameOver];
        }
    }
}

- (void) collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p{
    if ([(UIImageView *)item tag] == kTagRock && [(NSString *)identifier isEqualToString:@"bot"]){
        [self removeItem:(UIImageView *)item];
    }
}

- (void) removeItem:(UIImageView *)toRemove{
    [self.collision removeItem:toRemove];
    if ([toRemove tag] != kTagBlade){
        [self.gravity removeItem:toRemove];
        [self.obstacles removeObject:toRemove];
    }
    [UIImageView animateWithDuration:kFadeTime animations:^{
        toRemove.alpha = 0.0;
    } completion:^(BOOL finished){
        [toRemove removeFromSuperview];
    }];
}

# pragma mark Game Methods

- (void) launchTimer{
    NSTimeInterval randTime = arc4random_uniform(kLaunchMaxTimeInterval) / 100.0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:randTime target:self selector:@selector(createObstacle) userInfo:nil repeats:NO];
}

- (void) createBlade{
    UIImageView *blade = [[UIImageView alloc] initWithImage:self.bladeImages[0]];
    blade.animationImages = self.bladeImages;
    [self.view addSubview:blade];
    [blade startAnimating];
    blade.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - kBladeY);
    [blade setTag:kTagBlade];
    
    // Defining blade behavior.
    UIDynamicItemBehavior *superBladeBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[blade]];
    __weak UIDynamicItemBehavior *bladeBehavior = superBladeBehavior; // So that we have a weak reference
    bladeBehavior.density = kDensityBlade;
    bladeBehavior.action = ^{
        CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
        CMAcceleration acceleration = deviceMotion.gravity;
        CGPoint velocity = CGPointMake(acceleration.x * kBladeMaxSpeed, -acceleration.y * kBladeMaxSpeed);
        [bladeBehavior addLinearVelocity:velocity forItem:blade];
    };

    [self.collision addItem:blade];
    [self.animator addBehavior:bladeBehavior];
}

- (void) createObstacle{
    NSInteger rand = arc4random_uniform(kNumObstacles);
    UIImageView *obstacle = [[UIImageView alloc] initWithImage:[self.images objectForKey:[NSString stringWithFormat:@"obstacle%ld", (long)rand]]];
    [self.view addSubview:obstacle];
    
    // Launching the obstacle from one of several positions.
    NSInteger launcherSpacing = self.view.frame.size.width / (kNumLauncherPositions + 1);
    NSInteger randomizeLauncher = arc4random_uniform(kNumLauncherPositions);
    NSInteger launchX = launcherSpacing * (randomizeLauncher + 1);
    obstacle.center = CGPointMake(launchX, kLaunchY);
    
    // Set a random starting velocity.
    UIDynamicItemBehavior *obstacleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[obstacle]];
    NSInteger xRand = (NSInteger)arc4random_uniform(kMaxObstacleStartingSpeed) - (kMaxObstacleStartingSpeed / 2);
    CGPoint velocity = CGPointMake(xRand, 0);
    [obstacleBehavior addLinearVelocity:velocity forItem:obstacle];

    // Setting rock or log specific behaviors.
    if (rand == kNumObstacles - 1){
        [obstacle setTag:kTagRock];
        obstacleBehavior.density = kDensityRock;
        obstacleBehavior.elasticity = kElasticityRock;
    } else{
        [obstacle setTag:kTagLog];
        obstacleBehavior.density = kDensityLog;
        obstacleBehavior.elasticity = kElasticityLog;
    }
    
    [self.animator addBehavior:obstacleBehavior];
    [self.collision addItem:obstacle];
    [self.gravity addItem:obstacle];
    [self.obstacles addObject:obstacle];
    
    if (self.playing){
        [self launchTimer];
    }
}

- (void) updateScoreLabel{
    [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %ld", (long)self.score]];
}

# pragma mark Button Method and Game Over.

- (void) clearObstacles{
    while(self.obstacles.count > 0){
        [self removeItem:[self.obstacles objectAtIndex:0]];
    }
}

- (IBAction)playButtonPressed:(id)sender {
    self.playButton.enabled = false;
    self.playing = YES;
    self.score = 0;
    self.gameOverMessage.hidden = YES;
    [self updateScoreLabel];
    [self clearObstacles];
    [self launchTimer];
    [self createBlade];
    [UIButton animateWithDuration:kButtonFadeTime animations:^{
        self.playButton.alpha = 0.0;
    }];
}

- (void) gameOver{
    [self.timer invalidate];
    [self clearObstacles];
    self.playing = NO;
    self.gameOverMessage.hidden = NO;
    [UIButton animateWithDuration:kButtonFadeTime animations:^{
        self.playButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.playButton.enabled = true;
    }];
}
@end
