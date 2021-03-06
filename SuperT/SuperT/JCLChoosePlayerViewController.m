//
//  JCLChoosePlayerViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLChoosePlayerViewController.h"
#import "Player.h"
#import "Score+Cat.h"
#import "Constants.h"
#import "SoundManager.h"

@interface JCLChoosePlayerViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView1;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView2;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel1;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel2;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
- (IBAction)playPressed:(id)sender;
- (IBAction)addPressed:(id)sender;
- (IBAction)removePressed:(id)sender;
- (IBAction)backPressed:(id)sender;
@property JCLModel *model;
@property SoundManager *soundManager;

@end

@implementation JCLChoosePlayerViewController

#pragma mark Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.model = [JCLModel sharedInstance];
    self.soundManager = [SoundManager sharedInstance];
    [self refresh];
}

- (void) viewWillAppear:(BOOL)animated{
    [self refresh];
}

#pragma mark PickerView Data Source and Delegate

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (self.isSinglePlayer && [pickerView isEqual:self.pickerView2]){
        // AI instead of players.
        return [self.model numberOfAIProfiles];
    }
    return [self.model numberOfPlayerProfiles];
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (self.isSinglePlayer && [pickerView isEqual:self.pickerView2]){
        // AI instead of players.
        return [self.model nameOfAIAtIndex:row];
    }
    return [self.model nameOfPlayerAtIndex:row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    Player *player1 = [self.model playerAtIndex:[self.pickerView1 selectedRowInComponent:0]];
    if (self.isSinglePlayer){
        AI *ai = [self.model aiAtIndex:[self.pickerView2 selectedRowInComponent:0]];
        Score *score = [self.model scoreBetweenPlayers:@[player1, ai]];
        self.scoreLabel1.text = [NSString stringWithFormat:@"%d", [score winsForPlayerID:player1.playerID]];
        self.scoreLabel2.text = [NSString stringWithFormat:@"%d", [score winsForPlayerID:ai.playerID]];
    } else{
        Player *player2 = [self.model playerAtIndex:[self.pickerView2 selectedRowInComponent:0]];
        if ([player1.playerID isEqual:player2.playerID]){
            self.scoreLabel1.text = @"--";
            self.scoreLabel2.text = @"--";
            [self changeButtonState:self.playButton to:NO];
        } else{
            Score *score = [self.model scoreBetweenPlayers:@[player1, player2]];
            self.scoreLabel1.text = [NSString stringWithFormat:@"%d", [score winsForPlayerID:player1.playerID]];
            self.scoreLabel2.text = [NSString stringWithFormat:@"%d", [score winsForPlayerID:player2.playerID]];
            [self changeButtonState:self.playButton to:YES];
        }
    }
    
}

- (void) changeButtonState:(UIButton *)button to:(BOOL)enabled{
    button.enabled = enabled;
    [UIView animateWithDuration:kEnableInterval animations:^{
        button.alpha = enabled ? 1.0 : kDisabledAlpha;
    }];
}

- (void) refresh{
    [self.pickerView1 reloadComponent:0];
    [self.pickerView2 reloadComponent:0];
    
    // Disable remove button if not enough player profiles.
    if ([self.model numberOfPlayerProfiles] < 2){
        [self changeButtonState:self.removeButton to:NO];
    } else{
        [self changeButtonState:self.removeButton to:YES];
    }
    
    // Calling didSelectRow to refresh score labels.
    [self pickerView:self.pickerView1 didSelectRow:0 inComponent:0];
}

#pragma mark Button Reactions

- (IBAction) playPressed:(id)sender{
    if (self.isSinglePlayer || [self.pickerView1 selectedRowInComponent:0] != [self.pickerView2 selectedRowInComponent:0]){
        [self performSegueWithIdentifier:@"ChooseToGame" sender:self];
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
    [self.soundManager playConfirmButton];
    [self performSegueWithIdentifier:@"ChooseToAdd" sender:self];
}

- (IBAction)removePressed:(id)sender {
    [self.soundManager playBackButton];
    [self performSegueWithIdentifier:@"ChooseToRemove" sender:self];
}

- (IBAction)backPressed:(id)sender {
    [self.soundManager playBackButton];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ChooseToGame"]){
        JCLGameViewController *destController = segue.destinationViewController;
        destController.player1 = [self.model playerAtIndex:[self.pickerView1 selectedRowInComponent:0]];
        if (self.isSinglePlayer){
            destController.ai = [self.model aiAtIndex:[self.pickerView2 selectedRowInComponent:0]];
        } else{
            destController.player2 = [self.model playerAtIndex:[self.pickerView2 selectedRowInComponent:0]];
        }
    } else if ([segue.identifier isEqualToString:@"ChooseToAdd"]){
        JCLAddPlayerViewController *destController = segue.destinationViewController;
        destController.toRefresh = self;
    } else if ([segue.identifier isEqualToString:@"ChooseToRemove"]){
        JCLRemovePlayerViewController *destController = segue.destinationViewController;
        destController.toRefresh = self;
    }
}

@end
