//
//  JCLInfoViewController.m
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/22/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLInfoViewController.h"

@interface JCLInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *currentBoardLabel;
- (IBAction)backPressed:(id)sender;

@end

@implementation JCLInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *str = [NSString stringWithFormat:@"Current Board: %d", self.boardNum];
    [self.currentBoardLabel setText:str];
    
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
