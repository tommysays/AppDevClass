//
//  JCLTableViewController.m
//  PhotoViewer2
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/24/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLScrollView.h"
#import "JCLTableViewController.h"
#import "JCLTableViewCell.h"
#import "JCLModel.h"
#import "JCLConstants.h"



@interface JCLTableViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) JCLModel *model;
@property (nonatomic, strong) NSMutableDictionary *closedSections;
@property CGRect startingFrame;

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
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
    // Get cell and its imageview so that we can set frame origin and size to correct values.
    
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    UIImageView *cellImageView = ((JCLTableViewCell *)cell).imgView;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(cellImageView.frame)];
    
    imageView.image = cellImageView.image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGPoint offset = tableView.contentOffset;
    CGRect adjustedFrame = CGRectMake(cellImageView.frame.origin.x + cell.frame.origin.x - offset.x, cellImageView.frame.origin.y + cell.frame.origin.y - offset.y, imageView.frame.size.width, imageView.frame.size.height);
    JCLScrollView *scrollView = [[JCLScrollView alloc] initWithFrame:adjustedFrame];
    
    self.startingFrame = adjustedFrame;
    scrollView.imgView = imageView;
    [scrollView addSubview:imageView];
    scrollView.imgView.frame = CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    [scrollView addGestureRecognizer:tapRecognizer];
    [self.view addSubview:scrollView];
    
    // Disable user interaction while animating, keep table disabled until tap.
    
    [self.tableView setUserInteractionEnabled:false];
    [UIView animateWithDuration:kResizeAnimationTime animations:^{
        scrollView.frame = self.view.frame;
        scrollView.imgView.frame = scrollView.frame;
        self.tableView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [scrollView setUserInteractionEnabled:true];
        [scrollView adjustContentSize];
        //[scrollView setContentSize:((UIView*)[[scrollView subviews] objectAtIndex:0]).bounds.size];
    }];
}

- (void)tapRecognized:(UITapGestureRecognizer *)recognizer{
    
    // Only allow dismissal of scroll if zoomed to 1.0
    
    JCLScrollView *scrollView = (JCLScrollView *)(recognizer.view);
    if (scrollView.zoomScale != 1.0){
        return;
    }
    
    // Animate view back to its starting position, remove it, and restore user interaction.
    
    [UIView animateWithDuration:kResizeAnimationTime animations:^{
        scrollView.frame = self.startingFrame;
        scrollView.imgView.frame = CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
        self.tableView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [scrollView removeFromSuperview];
        [self.tableView setUserInteractionEnabled:true];
    }];
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

@end
