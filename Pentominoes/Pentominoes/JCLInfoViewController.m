//
//  JCLInfoViewController.m
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/22/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLInfoViewController.h"

@interface JCLInfoViewController ()
@property (retain, nonatomic) IBOutlet UILabel *selectorLabel;
@property (retain, nonatomic) IBOutlet UIButton *firstButton;
@property (retain, nonatomic) IBOutlet UIButton *secondButton;
@property (retain, nonatomic) IBOutlet UIButton *thirdButton;
- (IBAction)backPressed:(id)sender;
- (IBAction)colorPressed:(id)sender;

@end

@implementation JCLInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.selectorLabel setBackgroundColor:self.colorSelected];
    // Find out which button selector should be on
    [self moveSelectorToButton:[self buttonWithTag:self.colorSelected]];
}

- (UIButton *)buttonWithTag:(NSInteger)tag{
    switch (tag) {
        case 0:
            return self.firstButton;
        case 1:
            return self.secondButton;
        default:
            return self.thirdButton;
    }
}

- (void) moveSelectorToButton:(UIButton *)button{
    CGPoint pt = button.frame.origin;
    pt.x -= kSelectorOffset;
    pt.y -= kSelectorOffset;
    CGRect newFrame = CGRectMake(pt.x, pt.y, self.selectorLabel.frame.size.width, self.selectorLabel.frame.size.height);
    self.selectorLabel.frame = newFrame;
}

- (IBAction)backPressed:(id)sender {
    // I call delegate function outside of completion block because it feels a little laggy
    // to have the bg color change after the dismiss animation is done.
    [_delegate receiveColor:[self buttonWithTag:self.colorSelected].backgroundColor andTag:self.colorSelected];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)colorPressed:(id)sender {
    self.colorSelected = [sender tag];
    
    // Move selector to button.
    [self moveSelectorToButton:[self buttonWithTag:self.colorSelected]];
    
}
- (void)dealloc {
    [_firstButton release];
    [_secondButton release];
    [_thirdButton release];
    [_selectorLabel release];
    [super dealloc];
}
@end
