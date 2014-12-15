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
@property (weak, nonatomic) IBOutlet UIView *highlightView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *themeButtons;
@property JCLModel *model;
@property SoundManager *soundManager;
- (IBAction)themePressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;

@end

@implementation JCLOptionsViewController

- (void) viewDidLoad{
    self.model = [JCLModel sharedInstance];
    self.soundManager = [SoundManager sharedInstance];
    [self.soundSwitch setOn:[self.model isSoundOn]];
    [self.volumeSlider setValue:[self.model volume]];
    NSInteger curTheme = [self.model currentTheme];
    for (UIButton *button in self.themeButtons){
        if (button.tag == curTheme){
            self.highlightView.center = button.center;
            NSLog(@"center = %@", NSStringFromCGPoint(self.highlightView.center));
            NSLog(@"tag = %d", button.tag);
            break;
        }
    }
}

- (void) viewDidAppear:(BOOL)animated{
    NSLog(@"real center = %@", NSStringFromCGPoint(self.highlightView.center));
    NSLog(@"---");
}

- (void) viewWillAppear:(BOOL)animated{
    NSInteger curTheme = [self.model currentTheme];
    for (UIButton *button in self.themeButtons){
        if (button.tag == curTheme){
            self.highlightView.center = button.center;
            break;
        }
    }
}

#pragma mark - Button Reactions

- (IBAction)themePressed:(id)sender{
    [self.soundManager playConfirmButton];
    UIButton *button = (UIButton *)sender;
    [self.model updateTheme:button.tag];
    self.highlightView.center = button.center;
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
