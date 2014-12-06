//
//  JCLSinglePlayerChooseViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 12/5/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLSinglePlayerChooseViewController.h"
#import "JCLModel.h"

@interface JCLSinglePlayerChooseViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *playerPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *aiPicker;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel1;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel2;
@property JCLModel *model;

@end

@implementation JCLSinglePlayerChooseViewController

#pragma mark Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.model = [JCLModel sharedInstance];
    self.scoreLabel1.text = @"--";
    self.scoreLabel2.text = @"--";
}

- (void) viewWillAppear:(BOOL)animated{
    [self refresh];
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

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    Player *player1 = [self.model playerAtIndex:[self.playerPicker selectedRowInComponent:0]];
    Player *player2 = [self.model playerAtIndex:[self.aiPicker selectedRowInComponent:0]];

    Score *score = [self.model scoreBetweenPlayers:@[player1, player2]];
    
    self.scoreLabel1.text = [NSString stringWithFormat:@"%d", [score winsForPlayerID:player1 playerID]];
    self.scoreLabel2.text = [NSString stringWithFormat:@"%d", [score winsForPlayerID:player2.playerID]];
    }
}

- (void) refresh{
    [self.pickerView1 reloadComponent:0];
    [self.pickerView2 reloadComponent:0];
    // Calling didSelectRow to refresh score labels.
    [self pickerView:self.pickerView1 didSelectRow:0 inComponent:0];
}

#pragma mark Button Reactions
- (IBAction) playPressed:(id)sender{
    if ([self.pickerView1 selectedRowInComponent:0] != [self.pickerView2 selectedRowInComponent:0]){
        [self performSegueWithIdentifier:@"SingleToGame" sender:self];
    } else{
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
    //[self moveToProfileManager];
    [self performSegueWithIdentifier:@"SingleToAdd" sender:self];
}

- (IBAction)removePressed:(id)sender {
    [self performSegueWithIdentifier:@"SingleToRemove" sender:self];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"SingleToGame"]){
        JCLGameViewController *destController = segue.destinationViewController;
        destController.player1 = [self.model playerAtIndex:[self.pickerView1 selectedRowInComponent:0]];
        destController.player2 = nil;
    } else if ([segue.identifier isEqualToString:@"SingleToAdd"]){
        JCLAddPlayerViewController *destController = segue.destinationViewController;
        destController.toRefresh = self;
    } else if ([segue.identifier isEqualToString:@"SingleToRemove"]){
        JCLRemovePlayerViewController *destController = segue.destinationViewController;
        destController.toRefresh = self;
    }
}

@end
