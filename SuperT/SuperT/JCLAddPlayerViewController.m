//
//  JCLAddPlayerViewController.m
//  SuperT
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLAddPlayerViewController.h"
#import "JCLModel.h"

@interface JCLAddPlayerViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)addPressed:(id)sender;

@property JCLModel *model;

@end

@implementation JCLAddPlayerViewController

const NSInteger WIDTH = 500;
const NSInteger HEIGHT = 450;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0, 0, WIDTH, HEIGHT);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.model = [JCLModel sharedInstance];
    [self.textField becomeFirstResponder];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addPressed:(id)sender {
    NSString *name = self.textField.text;
    if ([[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid name!"
                                                        message:@"Names cannot be empty."
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,
                              nil];
        [alert show];
    } else{
        [self.model addPlayerWithName:name];
        [(JCLChoosePlayerViewController *)self.toRefresh refresh];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end