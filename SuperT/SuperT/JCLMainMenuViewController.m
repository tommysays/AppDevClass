//
//  JCLMainMenuViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLMainMenuViewController.h"
#import "JCLChoosePlayerViewController.h"

@interface JCLMainMenuViewController ()

@end

@implementation JCLMainMenuViewController

#pragma mark Segue

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

@end
