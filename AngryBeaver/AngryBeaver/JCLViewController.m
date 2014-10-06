//
//  JCLViewController.m
//  AngryBeaver
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/3/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLViewController.h"

#ifndef CONSTANTS
#define CONSTANTS
#define kFadeTime 0.75 // Duration of fade for logs, rocks, and blade when struck.
#define kTagBlade 0
#define kTagLog 1
#define kTagRock 2
#define kBladeY 100 // Height where blade starts from, relative to bottom of screen.
#define kLaunchY 20 // Height where obstacles are launched from, relative to top of screen.
#define kLaunchMaxTimeInterval 150 // Maximum time between obstacles, in deci-seconds.
#define kNumObstacles 4
#define kNumLauncherPositions 4
#endif

@interface JCLViewController () <UICollisionBehaviorDelegate>

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravity;
@property (strong, nonatomic) UICollisionBehavior *collision;
@property (strong, nonatomic) NSDictionary *images;
@property (strong, nonatomic) NSArray *bladeImages;
@property BOOL gameOver;

@end

@implementation JCLViewController

# pragma mark Initialization Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.gameOver = false;
    self.images = [[NSDictionary alloc] init];
    [self initBehaviors];
    [self loadImages];
    [self createBlade];
    [self createObstacle];
}

- (void) initBehaviors{
    self.animator = [[UIDynamicAnimator alloc] init];
    self.gravity = [[UIGravityBehavior alloc] init];
    self.collision = [[UICollisionBehavior alloc] init];
    
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
        [behavior removeItem:item1];
    } else if (tag1 == kTagBlade && tag2 == kTagLog){
        toRemove = (UIImageView *)item2;
        [behavior removeItem:item2];
    } else if (tag1 == kTagRock && tag2 == kTagBlade){
        toRemove = (UIImageView *)item2;
        [behavior removeItem:item2];
        self.gameOver = YES;
    } else if (tag1 == kTagBlade && tag2 == kTagRock){
        toRemove = (UIImageView *)item1;
        [behavior removeItem:item1];
        self.gameOver = YES;
    }
    if (toRemove){
        [self removeItem:toRemove];
    }
}

- (void) collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p{
    NSLog(@"Tag = %d", [(UIImageView *)item tag]);
    if ([(UIImageView *)item tag] == kTagRock && [(NSString *)identifier isEqualToString:@"bot"]){
        NSLog(@"Rock bottom.");
        [behavior removeItem:item];
        [self removeItem:(UIImageView *)item];
    }
}

- (void) removeItem:(UIImageView *)toRemove{
    [UIImageView animateWithDuration:kFadeTime animations:^{
        toRemove.alpha = 0.0;
    } completion:^(BOOL finished){
        [toRemove removeFromSuperview];
    }];
}

# pragma mark View Creation Methods

- (void) launchTimer{
    NSTimeInterval randTime = arc4random_uniform(kLaunchMaxTimeInterval) / 100.0;
    [NSTimer scheduledTimerWithTimeInterval:randTime target:self selector:@selector(createObstacle) userInfo:nil repeats:NO];
}

- (void) createBlade{
    UIImageView *blade = [[UIImageView alloc] initWithImage:self.bladeImages[0]];
    blade.animationImages = self.bladeImages;
    [blade setTag:kTagBlade];
    [self.collision addItem:blade];
    [self.view addSubview:blade];
    blade.center = CGPointMake(self.view.frame.size.width / 2, kBladeY);
}

- (void) createObstacle{
    NSInteger rand = arc4random_uniform(kNumObstacles);
    rand = kNumObstacles - 1;
    UIImageView *obstacle = [[UIImageView alloc] initWithImage:[self.images objectForKey:[NSString stringWithFormat:@"obstacle%d", rand]]];
    [self.view addSubview:obstacle];
    
    // Launching the obstacle from one of several positions.
    NSInteger launcherSpacing = self.view.frame.size.width / (kNumLauncherPositions + 1);
    NSInteger randomizeLauncher = arc4random_uniform(kNumLauncherPositions);
    NSInteger launchX = launcherSpacing * (randomizeLauncher + 1);
    obstacle.center = CGPointMake(launchX, kLaunchY);
    
    
    if (rand == kNumObstacles - 1){
        // Obstacle generated is a rock!
        NSLog(@"Generating rock!");
        [obstacle setTag:kTagRock];
    } else{
        // Obstacle generated is a log...
        [obstacle setTag:kTagLog];
    }
    NSLog(@"Generated tag: %d", [obstacle tag]);
    
    [self.collision addItem:obstacle];
    [self.gravity addItem:obstacle];
    
    if (!self.gameOver){
        [self launchTimer];
    }
}

@end
