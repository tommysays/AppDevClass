//
//  JCLViewController.m
//  Assignment 1
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/6/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLViewController.h"
static NSInteger const NUM_SEGMENTS = 4;
static NSInteger const ANSWER_DEVIATION = 5;
static NSInteger const NUM_QUESTIONS = 10;
static NSInteger const MIN_NUMBER = 1;
static NSInteger const MAX_NUMBER = 15;

@interface JCLViewController ()
@property (weak, nonatomic) IBOutlet UILabel *multiplierLabel;
@property (weak, nonatomic) IBOutlet UILabel *multiplicandLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *numCorrectLabel;
@property (weak, nonatomic) IBOutlet UILabel *correctLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *answersControl;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
- (IBAction)answerSelected:(id)sender;
- (IBAction)nextPressed:(id)sender;

@property NSInteger numCorrect;
@property NSInteger numQuestion;
@property NSInteger answer;

@end

@implementation JCLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.answersControl removeAllSegments];
    for (int i = 0; i < NUM_SEGMENTS; ++i){
        [self.answersControl insertSegmentWithTitle:@"" atIndex:0 animated:false];
    }
    [self clearAll];
    [self.nextButton setTitle:@"Start" forState:UIControlStateNormal];
}

- (void)clearAll{
    self.multiplierLabel.text = @"";
    self.multiplicandLabel.text = @"";
    self.resultLabel.text = @"";
    self.numCorrectLabel.text = @"";
    self.correctLabel.text = @"";
    for (int i = 0; i < NUM_SEGMENTS; i++) {
        [self.answersControl setTitle:@"" forSegmentAtIndex:i];
    }
    self.numCorrect = 0;
    self.numQuestion = 0;
    self.answer = 0;
}

- (void)generateProblem{
    int multiplier = arc4random_uniform(MAX_NUMBER) + MIN_NUMBER;
    int multiplicand = arc4random_uniform(MAX_NUMBER) + MIN_NUMBER;
    self.answer = multiplier * multiplicand;
    self.multiplierLabel.text = [NSString stringWithFormat:@"%d", multiplier];
    self.multiplicandLabel.text = [NSString stringWithFormat:@"%d", multiplicand];
    
}

- (BOOL)isCorrect{
    int index = self.answersControl.selectedSegmentIndex;
    if (self.answer == [[self.answersControl titleForSegmentAtIndex:index] intValue]){
        return true;
    }
    return false;
}

- (IBAction)answerSelected:(id)sender {
    if (self.isCorrect){
        self.numCorrect++;
        self.correctLabel.text = @"Correct!";
    } else{
        self.correctLabel.text = @"Incorrect.";
    }
    self.answersControl.enabled = false;
    self.resultLabel.text = [NSString stringWithFormat:@"%d", self.answer];
    self.numCorrectLabel.text = [NSString stringWithFormat:@"%d/%d Questions Correct", self.numCorrect, self.numQuestion];
}

- (IBAction)nextPressed:(id)sender {
    if (self.numQuestion == 0){
        [self generateProblem];
        [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
        self.numQuestion++;
    } else if (self.numQuestion < NUM_QUESTIONS - 1){
        [self generateProblem];
        self.numQuestion++;
    } else if (self.numQuestion < NUM_QUESTIONS){
        [self.nextButton setTitle:@"Reset" forState:UIControlStateNormal];
    } else{
        [self clearAll];
        [self.nextButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}
@end
