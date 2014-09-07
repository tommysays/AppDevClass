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
@property (weak, nonatomic) IBOutlet UILabel *barLabel;
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
    self.barLabel.hidden = true;
    self.resultLabel.text = @"";
    self.numCorrectLabel.text = @"";
    self.correctLabel.text = @"";
    for (int i = 0; i < NUM_SEGMENTS; i++) {
        [self.answersControl setTitle:@"" forSegmentAtIndex:i];
    }
    self.answersControl.selectedSegmentIndex = -1;
    self.answersControl.enabled = false;
    self.numCorrect = 0;
    self.numQuestion = 0;
    self.answer = 0;
}

- (void)generateProblem{
    //Resetting some labels.
    self.resultLabel.text = @"";
    self.numCorrectLabel.text = @"";
    self.correctLabel.text = @"";
    self.barLabel.hidden = false;
    
    //Generating numbers and answer.
    int multiplier = arc4random_uniform(MAX_NUMBER) + MIN_NUMBER;
    int multiplicand = arc4random_uniform(MAX_NUMBER) + MIN_NUMBER;
    self.answer = multiplier * multiplicand;
    self.multiplierLabel.text = [NSString stringWithFormat:@"%d", multiplier];
    self.multiplicandLabel.text = [NSString stringWithFormat:@"%d", multiplicand];
    
    //Generate list of all wrong answers within the proper range.
    NSMutableArray *answers = [NSMutableArray array];
    for (int i = 0; i < ANSWER_DEVIATION * 2 + 1; ++i){
        if (i != ANSWER_DEVIATION){
            NSInteger ans = self.answer - i + ANSWER_DEVIATION;
            [answers addObject:[NSString stringWithFormat:@"%d", ans]];
        }
    }
    //Of that list, add random ones to a new list until we have added NUM_SEGMENTS - 1 answers.
    NSMutableArray *toSegments = [NSMutableArray array];
    for (int i = 0; i < NUM_SEGMENTS - 1; ++i){
        int index = arc4random_uniform(answers.count);
        [toSegments addObject:answers[index]];
        [answers removeObjectAtIndex:index];
    }
    
    //Add the real answer to the new list.
    [toSegments addObject:[NSString stringWithFormat:@"%d", self.answer]];
    
    //Finally, add all the (randomly selected) answers in a random order to our segmented control.
    for (int i = 0; i < NUM_SEGMENTS; ++i){
        int index = arc4random_uniform(toSegments.count);
        [self.answersControl setTitle:toSegments[index] forSegmentAtIndex:i];
        [toSegments removeObjectAtIndex:index];
    }
    self.answersControl.selectedSegmentIndex = -1;
    self.answersControl.enabled = true;
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
    self.nextButton.enabled = true;
}

- (IBAction)nextPressed:(id)sender {
    if (self.numQuestion == 0){
        [self generateProblem];
        [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
        self.numQuestion++;
        self.nextButton.enabled = false;
    } else if (self.numQuestion < NUM_QUESTIONS - 1){
        [self generateProblem];
        self.numQuestion++;
        self.nextButton.enabled = false;
    } else if (self.numQuestion < NUM_QUESTIONS){
        [self.nextButton setTitle:@"Reset" forState:UIControlStateNormal];
        [self generateProblem];
        self.numQuestion++;
        self.nextButton.enabled = false;
    } else{
        [self clearAll];
        [self.nextButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}
@end
