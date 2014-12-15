//
//  JCLOptionsViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLOptionsViewController.h"
#import "JCLModel.h"
#import "SoundManager.h"

@interface JCLOptionsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *highlights;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *themeButtons;
@property JCLModel *model;
@property SoundManager *soundManager;
- (IBAction)themePressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;

@end

@implementation JCLOptionsViewController

#pragma mark - Initialization

- (void) viewDidLoad{
    [super viewDidLoad];
    self.model = [JCLModel sharedInstance];
    self.soundManager = [SoundManager sharedInstance];
    [self.soundSwitch setOn:[self.model isSoundOn]];
    [self.volumeSlider setValue:[self.model volume]];
    NSInteger curTheme = [self.model currentTheme];
    for (UIView *view in self.highlights){
        if (view.tag == curTheme){
            view.hidden = NO;
        } else{
            view.hidden = YES;
        }
    }
}

#pragma mark - Button Reactions

- (IBAction)themePressed:(id)sender{
    [self.soundManager playConfirmButton];
    UIButton *button = (UIButton *)sender;
    [self.model updateTheme:button.tag];
    for (UIView *view in self.highlights){
        if (view.tag == button.tag){
            view.hidden = NO;
        } else{
            view.hidden = YES;
        }
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self.model updateVolume:self.volumeSlider.value];
    [self.model setSoundOn:self.soundSwitch.isOn];
    
    [self.soundManager playBackButton];
    
    if (self.gameController){
        [self.gameController resetMarks];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
