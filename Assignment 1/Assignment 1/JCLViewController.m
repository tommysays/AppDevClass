//
//  JCLViewController.m
//  Assignment 1
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/6/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLViewController.h"
static NSInteger const NUM_ANSWERS = 4;
static NSInteger const ANSWER_DEVIATION = 5;
static NSInteger const NUM_QUESTIONS = 7;
static NSInteger const MIN_NUMBER = 1;
static NSInteger const MAX_NUMBER = 15;
NSMutableArray *array;

@interface JCLViewController ()
@property (weak, nonatomic) IBOutlet UILabel *multiplierLabel;
@property (weak, nonatomic) IBOutlet UILabel *multiplicandLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *numCorrectLabel;
@property (weak, nonatomic) IBOutlet UILabel *correctLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *answersControl;
- (IBAction)answerSelected:(id)sender;
- (IBAction)nextPressed:(id)sender;

@property NSInteger numCorrect = 0;
@property NSInteger numQuestion = 0;

@end

@implementation JCLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self clearAll];
    
}

- (void)clearAll{
    self.multiplierLabel.text = @"";
    self.multiplicandLabel.text = @"";
    self.resultLabel.text = @"";
    self.numCorrectLabel.text = @"";
    self.correctLabel.text = @"";
    for (int i = 0; i < NUM_ANSWERS; i++) {
        [self.answersControl setTitle:@"" forSegmentAtIndex:i];
    }
}

- (void)multiply{
    
    
}

- (BOOL)isCorrect{
    return true;
}

- (IBAction)answerSelected:(id)sender {
    if (self.isCorrect){
        self.numCorrect++;
        self.answersControl.enabled = false;
        self.numCorrectLabel.text = @" Questions Correct";
        self.correctLabel.text = @"Correct!";
    }
}

- (IBAction)nextPressed:(id)sender {
    
}
@end
