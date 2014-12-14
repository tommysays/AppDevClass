//
//  JCLAddPlayerViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLAddPlayerViewController.h"
#import "JCLModel.h"
#import "SoundManager.h"
#import "Constants.h"

@interface JCLAddPlayerViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)addPressed:(id)sender;

@property JCLModel *model;
@property SoundManager *soundManager;

@end

@implementation JCLAddPlayerViewController

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0, 0, kAddRemoveWidth, kAddRemoveHeight);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.model = [JCLModel sharedInstance];
    self.soundManager = [SoundManager sharedInstance];
    [self.textField becomeFirstResponder];
}

- (IBAction)cancelPressed:(id)sender {
    [self.soundManager playBackButton];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addPressed:(id)sender {
    NSString *name = self.textField.text;
    NSInteger length = [[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
    if (length == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Blank name"
                                                        message:@"Names need at least 1 non-whitespace character."
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,
                              nil];
        [alert show];
    } else if (length > kMAX_PLAYER_NAME_LENGTH){
        NSString *msg = [NSString stringWithFormat:@"Names must be at most %d characters long.", kMAX_PLAYER_NAME_LENGTH];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Name is too long"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,
                              nil];
        [alert show];
    } else{
        [self.soundManager playConfirmButton];
        [self.model addPlayerWithName:name];
        [(JCLChoosePlayerViewController *)self.toRefresh refresh];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
