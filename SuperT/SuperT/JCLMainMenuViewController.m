//
//  JCLMainMenuViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLMainMenuViewController.h"
#import "JCLChoosePlayerViewController.h"
#import "JCLModel.h"
#import "SoundManager.h"

@interface JCLMainMenuViewController ()

- (IBAction)positivePressed:(id)sender;
@property JCLModel *model;
@property SoundManager *soundManager;

@end

@implementation JCLMainMenuViewController

- (void) viewDidLoad{
    self.model = [JCLModel sharedInstance];
    self.soundManager = [SoundManager sharedInstance];
}


#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"MainSingleToChoose"]){
        JCLChoosePlayerViewController *destController = (JCLChoosePlayerViewController *)segue.destinationViewController;
        destController.isSinglePlayer = YES;
    } else if ([identifier isEqualToString:@"MainMultiToChoose"]){
        JCLChoosePlayerViewController *destController = (JCLChoosePlayerViewController *)segue.destinationViewController;
        destController.isSinglePlayer = NO;
    }
}

#pragma mark - Buttons

- (IBAction)positivePressed:(id)sender{
    [self.soundManager playConfirmButton];
}

@end
