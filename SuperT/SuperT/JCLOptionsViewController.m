//
//  JCLOptionsViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLOptionsViewController.h"

@interface JCLOptionsViewController ()
- (IBAction)backButtonPressed:(id)sender;

@end

@implementation JCLOptionsViewController

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
