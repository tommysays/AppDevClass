//
//  JCLAddPhotoViewController.m
//  PhotoViewer4
//
//  Created by JOSHUA CHRISTOPHER LEE on 11/9/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLAddPhotoViewController.h"
#import "JCLModel.h"

@interface JCLAddPhotoViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UIImageView *promptPhoto;


@property JCLModel *model;
@property BOOL photoIsSet;

- (IBAction)cancelPressed:(id)sender;
- (IBAction)addPhotoPressed:(id)sender;

@end

@implementation JCLAddPhotoViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.model = [JCLModel sharedInstance];
    self.photoIsSet = false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Picker View Delegate and Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.model numberOfSets];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.model nameOfSet:row];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Button methods

- (IBAction)cancelPressed:(id)sender {
    self.didCancel = YES;
    [self.parentView dismissAddPhotoView];
}

- (IBAction)addPhotoPressed:(id)sender {
    if (!self.photoIsSet){
        // Throw alert method
    } else{
        self.didCancel = NO;
        self.selectedPark = [self.pickerView selectedRowInComponent:0];
        self.selectedImage = self.promptPhoto.image;
        [self.parentView dismissAddPhotoView];
    }
    
}
@end
