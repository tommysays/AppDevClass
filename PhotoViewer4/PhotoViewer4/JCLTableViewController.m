//
//  JCLTableViewController.m
//  PhotoViewer2
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/24/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLScrollView.h"
#import "JCLDetailViewController.h"
#import "JCLTableViewController.h"
#import "JCLAddPhotoViewController.h"
#import "JCLTableViewCell.h"
#import "JCLModel.h"
#import "JCLConstants.h"



@interface JCLTableViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

- (IBAction)addButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) JCLModel *model;
@property (nonatomic, strong) NSMutableDictionary *closedSections;
@property (nonatomic, strong) NSIndexPath* indexToSend;
@property (nonatomic, strong) JCLDetailViewController *detailViewController;
@property UIActionSheet *addSheet;
@property JCLAddPhotoViewController *addPhotoController;

@end

@implementation JCLTableViewController

-(void)awakeFromNib
{
    UINavigationController *navController = [self.splitViewController.viewControllers lastObject];
    self.detailViewController = (id)navController.topViewController;
    self.splitViewController.delegate = self.detailViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _model = [JCLModel sharedInstance];
        _closedSections = [[NSMutableDictionary alloc] init];
            }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        _model = [JCLModel sharedInstance];
        _closedSections = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}
#pragma mark - Editing methods.

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [self.model numberOfSets]; ++i){
        for (NSInteger j = 0; j < [self tableView:self.tableView numberOfRowsInSection:i]; ++j){
            [paths addObject:[NSIndexPath indexPathForRow:j inSection:i]];
        }
    }
    [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
}

// Prevent user from trying to drop cell in another section.
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    
    if (sourceIndexPath.section != proposedDestinationIndexPath.section){
        return sourceIndexPath;
    } else{
        return proposedDestinationIndexPath;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if (fromIndexPath.section == toIndexPath.section){
		[self.model moveImageFrom:fromIndexPath.row to:toIndexPath.row fromSet:fromIndexPath.section];
	}
    [self.tableView reloadData];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.model removeImage:indexPath.row fromSet:indexPath.section];
		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.model numberOfSets];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.closedSections objectForKey:[NSNumber numberWithInteger:section]]){
        return 0;
    } else{
        return [self.model sizeOfSet:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JCLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    
    NSInteger photosetIndex = indexPath.section;
    NSInteger photoIndex = indexPath.row;
    
    cell.photoCaption.text = [self.model nameOfImage:photoIndex fromSet:photosetIndex];
    cell.imgView.image = [self.model image:photoIndex fromSet:photosetIndex];
    if (!self.editing){
        cell.imgView.hidden = NO;
    } else{
        cell.imgView.hidden = YES;
    }
    cell.imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionName = [self.model nameOfSet:section];
    CGFloat width = self.view.frame.size.width;
    CGFloat height = tableView.sectionHeaderHeight;
    
    CGRect frame = CGRectMake(0, 0, width, height);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = kHeaderBackgroundColor;
    
    // Constructing left/right icons.
    
    CGFloat iconOffset = (height - kHeaderIconSize) / 2;
    
    CGRect leftIconFrame = CGRectMake(iconOffset, iconOffset, kHeaderIconSize, kHeaderIconSize);
    UIImageView *leftIcon = [[UIImageView alloc] initWithFrame:leftIconFrame];
    leftIcon.image = [self.model nationalParkImage];
    leftIcon.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:leftIcon];
    
    CGRect rightIconFrame = CGRectMake(width - iconOffset - kHeaderIconSize, iconOffset, kHeaderIconSize, kHeaderIconSize);
    UIImageView *rightIcon = [[UIImageView alloc] initWithFrame:rightIconFrame];
    rightIcon.image = [self.model nationalParkImage];
    rightIcon.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:rightIcon];
    
    // Constructing label.
    
    CGRect lblFrame = CGRectMake(0, kHeaderLabelY, width, kHeaderLabelHeight - 2 * kHeaderLabelY);
    UILabel *lbl = [[UILabel alloc] initWithFrame:lblFrame];
    lbl.text = sectionName;
    lbl.font = [UIFont systemFontOfSize:kHeaderFontSize];
    lbl.textColor = kHeaderFontColor;
    lbl.textAlignment = NSTextAlignmentCenter;
    [view addSubview:lbl];
    
    // Constructing button.
    
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    btn.tag = section;
    [btn addTarget:self action:@selector(sectionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    return view;
}

#pragma mark TableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    self.indexToSend = indexPath;
    [self performSegueWithIdentifier:@"TableToDetail" sender:self];
}

#pragma mark Button Reactions

- (IBAction)sectionPressed:(id)sender{
    NSInteger sectionIndex = [sender tag];
    if ([self.closedSections objectForKey:[NSNumber numberWithInteger:sectionIndex]]){
        [self.closedSections removeObjectForKey:[NSNumber numberWithInteger:sectionIndex]];
        NSInteger numRows = [self tableView:self.tableView numberOfRowsInSection:sectionIndex];
        NSMutableArray *paths = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < numRows; i++){
            [paths addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
        }
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
    } else{
        NSInteger numRows = [self tableView:self.tableView numberOfRowsInSection:sectionIndex];
        NSMutableArray *paths = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < numRows; i++){
            [paths addObject:[NSIndexPath indexPathForRow:i inSection:sectionIndex]];
        }
        [self.closedSections setObject:@"closed" forKey:[NSNumber numberWithInteger:sectionIndex]];
        
        [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
    }
    //[self.tableView reloadData];
}

- (IBAction)addButtonPressed:(id)sender{
	self.addSheet = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New Park", @"New Photo", nil];
    [self.addSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 0){
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Enter Park Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		alert.alertViewStyle = UIAlertViewStylePlainTextInput;
		UITextField * alertTextField = [alert textFieldAtIndex:0];
		alertTextField.keyboardType = UIKeyboardTypeAlphabet;
		alertTextField.placeholder = @"My Park";
		[alert show];
	} else if (buttonIndex == 1){
        [self performSegueWithIdentifier:@"TableToAddPhoto" sender:self];
	}
}

#pragma mark Alert Delegate Methods.

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1){
        NSString *name = [alertView textFieldAtIndex:0].text;
        // Only add park if name has at least 1 non-whitespace character.
        if ([[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0){
            NSInteger sectionIndex = [self.model addPark:[alertView textFieldAtIndex:0].text];
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:sectionIndex];
            [self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        }
	}
}

#pragma mark Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"TableToDetail"]){
        JCLDetailViewController *destController = segue.destinationViewController;
        destController.image = [self.model image:self.indexToSend.row fromSet:self.indexToSend.section];
        destController.captionText = [self.model nameOfImage:self.indexToSend.row fromSet:self.indexToSend.section];
        destController.navigationItem.title = [self.model nameOfSet:self.indexToSend.section];
        destController.modelIndexPath = self.indexToSend;
    } else if ([segue.identifier isEqualToString:@"TableToAddPhoto"]){
        JCLAddPhotoViewController *destController = segue.destinationViewController;
        self.addPhotoController = destController;
        destController.parentView = self;
    }
}

- (void) dismissAddPhotoView{
    if (!self.addPhotoController.didCancel){
        NSInteger section = self.addPhotoController.selectedPark;
        NSInteger row = [self.model sizeOfSet:section];
        [self.model addImage:self.addPhotoController.selectedImage toSet:self.addPhotoController.selectedPark];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]]withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.addPhotoController dismissViewControllerAnimated:true completion:^{}];
}

@end
