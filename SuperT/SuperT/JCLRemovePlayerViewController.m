//
//  JCLRemovePlayerViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/19/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLRemovePlayerViewController.h"
#import "JCLModel.h"
#import "JCLPlayer.h"

@interface JCLRemovePlayerViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
- (IBAction)removePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

@property JCLModel *model;

@end

@implementation JCLRemovePlayerViewController

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

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        // Remove the player and exit view.
        
        // TODO test this whole thing.
        [self.model removePlayer:[self.model playerAtIndex:[self.pickerView selectedRowInComponent:0]]];
        [(JCLChoosePlayerViewController *)self.toRefresh refresh];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)removePressed:(id)sender {
    JCLPlayer *player = [self.model playerAtIndex:[self.pickerView selectedRowInComponent:0]];
    NSString *name = [player nameOfPlayer];
    NSIndexPath *totalScore = [player totalScore];
    NSString *summary = [NSString stringWithFormat:@"%@ has %d wins and %d losses.", name, totalScore.row, totalScore.section];
    // Thow alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                    message:summary
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Yes",
                          nil];
    [alert show];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
