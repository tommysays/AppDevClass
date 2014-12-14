//
//  JCLOptionsViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLOptionsViewController.h"
#import "JCLModel.h"

@interface JCLOptionsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property JCLModel *model;
- (IBAction)backButtonPressed:(id)sender;

@end

@implementation JCLOptionsViewController

- (void) viewDidLoad{
    self.model = [JCLModel sharedInstance];
    [self.soundSwitch setOn:[self.model isSoundOn]];
    [self.volumeSlider setValue:[self.model volume]];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.model updateVolume:self.volumeSlider.value];
    [self.model setSoundOn:self.soundSwitch.isOn];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
