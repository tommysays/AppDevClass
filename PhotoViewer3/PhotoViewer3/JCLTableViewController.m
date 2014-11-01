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
#import "JCLTableViewCell.h"
#import "JCLModel.h"
#import "JCLConstants.h"



@interface JCLTableViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) JCLModel *model;
@property (nonatomic, strong) NSMutableDictionary *closedSections;
@property CGRect startingFrame;
@property (nonatomic, strong) UIImage *imgToSend;
@property (nonatomic, strong) NSString *captionToSend;

@end

@implementation JCLTableViewController

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
    [self.tableView reloadData];
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
    if ([self.closedSections objectForKey:[NSNumber numberWithInteger:indexPath.section]]){
        return nil;
    }
    JCLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    
    NSInteger photosetIndex = indexPath.section;
    NSInteger photoIndex = indexPath.row;
    
    cell.photoCaption.text = [self.model nameOfImage:photoIndex fromSet:photosetIndex];
    cell.imgView.image = [self.model image:photoIndex fromSet:photosetIndex];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [tableView deselectRowAtIndexPath:indexPath animated:false];
        
        self.imgToSend = [self.model image:indexPath.row fromSet:indexPath.section];
        self.captionToSend = [self.model nameOfImage:indexPath.row fromSet:indexPath.section];
        
        [self performSegueWithIdentifier:@"TableToDetail" sender:self];
    }
}

- (IBAction)sectionPressed:(id)sender{
    NSInteger sectionIndex = [sender tag];
    if ([self.closedSections objectForKey:[NSNumber numberWithInteger:sectionIndex]]){
        [self.closedSections removeObjectForKey:[NSNumber numberWithInteger:sectionIndex]];
    } else{
        [self.closedSections setObject:@"closed" forKey:[NSNumber numberWithInteger:sectionIndex]];
    }
    [self.tableView reloadData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"TableToDetail"]){
        JCLDetailViewController *destController = segue.destinationViewController;
        destController.image = self.imgToSend;
        destController.captionText = self.captionToSend;
    }
}

@end
