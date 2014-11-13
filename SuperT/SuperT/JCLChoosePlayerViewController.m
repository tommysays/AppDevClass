//
//  JCLChoosePlayerViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLChoosePlayerViewController.h"

@interface JCLChoosePlayerViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView1;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView2;
- (IBAction)playPressed:(id)sender;
- (IBAction)addPressed:(id)sender;
- (IBAction)backPressed:(id)sender;
@property JCLModel *model;

@end

@implementation JCLChoosePlayerViewController

#pragma mark Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.model = [JCLModel sharedInstance];
}

#pragma mark PickerView Data Source and Delegate

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.model numberOfPlayerProfiles];
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.model nameOfPlayerAtIndex:row];
}

#pragma mark Button Reactions
- (IBAction) playPressed:(id)sender{
    if ([self.pickerView1 selectedRowInComponent:0] != [self.pickerView2 selectedRowInComponent:0]){
        NSLog(@"About to start game.");
        NSLog(@"picker 1 = %d, picker 2 = %d", [self.pickerView1 selectedRowInComponent:0], [self.pickerView2 selectedRowInComponent:0]);
        [self performSegueWithIdentifier:@"ChooseToGame" sender:self];
    } else{
        NSLog(@"Invalid player selections");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh! You cannot face yourself in this game."
                                                        message:@" Select a different player profile, or play Solitaire instead!"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil,
                              nil];
        [alert show];
    }
}

- (IBAction) addPressed:(id)sender{
    [self moveToProfileManager];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ChooseToGame"]){
        JCLGameViewController *destController = segue.destinationViewController;
        destController.player1 = [self.model playerAtIndex:[self.pickerView1 selectedRowInComponent:0]];
        destController.player2 = [self.model playerAtIndex:[self.pickerView2 selectedRowInComponent:0]];
    }
}

- (void) moveToProfileManager{
    UISplitViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileManager"];
    [JCLManageProfileTableViewController setToReturn:self];
    JCLAppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    //[appDel.window setRootViewController:controller];
    [UIView transitionWithView:appDel.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ appDel.window.rootViewController = controller; }
                    completion:nil];
}

@end
