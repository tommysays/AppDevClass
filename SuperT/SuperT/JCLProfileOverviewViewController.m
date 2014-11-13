//
//  JCLProfileOverviewViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLProfileOverviewViewController.h"

@interface JCLProfileOverviewViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property JCLPlayer *selectedPlayer;
@property JCLModel *model;

@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *winsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lossesLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@end

@implementation JCLProfileOverviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.model = [JCLModel sharedInstance];
    self.playerNameLabel.text = [self.curPlayer nameOfPlayer];
    self.selectedPlayer = [self.model playerAtIndex:[self.pickerView selectedRowInComponent:0]];
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSString *wins, *losses;
    
    self.selectedPlayer = [self.model playerAtIndex:row];
    
    if ([self.curPlayer isEqual:self.selectedPlayer]){
        wins = @"";
        losses = @"";
    } else{
        NSIndexPath *score = [self.curPlayer scoresAgainst:self.selectedPlayer];
        wins = [NSString stringWithFormat:@"%d", score.row];
        losses = [NSString stringWithFormat:@"%d", score.section];
    }
    self.winsLabel.text = wins;
    self.lossesLabel.text = losses;
}


@end
