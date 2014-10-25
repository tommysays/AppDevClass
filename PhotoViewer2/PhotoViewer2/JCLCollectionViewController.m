//
//  JCLCollectionViewController.m
//  PhotoViewer2
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/23/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLScrollView.h"
#import "JCLCollectionViewController.h"
#import "JCLCollectionReusableView.h"
#import "JCLCollectionViewCell.h"
#import "JCLModel.h"
#import "JCLConstants.h"

@interface JCLCollectionViewController () <UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) JCLModel *model;
- (IBAction)barPressed:(id)sender;
@property CGRect startingFrame;

@end

const CGFloat kSectionInterItemSpacing = 10.0;
const CGFloat kSectionLineSpacing = 10.0;

@implementation JCLCollectionViewController

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        _model = [JCLModel sharedInstance];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated{
    [self.collectionView reloadData];
}

- (void) viewWillAppear:(BOOL)animated{
    //[self.collectionView reloadData];
}

#pragma mark Collection View Data Source

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self.model numberOfSets];
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.model sizeOfSet:section];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CollectionCell";
    
    JCLCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSInteger photosetIndex = indexPath.section;
    NSInteger photoIndex = indexPath.row;
    UIImage *img = [self.model image:photoIndex fromSet:photosetIndex];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:img];
    cell.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
    //[cell setImage:img];
    
    return cell;
}

-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        JCLCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderView" forIndexPath:indexPath];
        NSInteger photosetIndex = indexPath.section;
        NSString *title = [self.model nameOfSet:photosetIndex];
        headerView.sectionTitle.text = title;
        headerView.sectionTitle.textColor = kHeaderFontColor;
        headerView.backgroundColor = kHeaderBackgroundColor;
        
        CGFloat height = headerView.bounds.size.height;
        CGFloat width = headerView.bounds.size.width;
        
        CGFloat iconOffset = (height - kHeaderIconSize) / 2;
        
        CGRect leftIconFrame = CGRectMake(iconOffset, iconOffset, kHeaderIconSize, kHeaderIconSize);
        UIImageView *leftIcon = [[UIImageView alloc] initWithFrame:leftIconFrame];
        leftIcon.image = [self.model nationalParkImage];
        leftIcon.contentMode = UIViewContentModeScaleAspectFit;
        [headerView addSubview:leftIcon];
        
        CGRect rightIconFrame = CGRectMake(width - iconOffset - kHeaderIconSize, iconOffset, kHeaderIconSize, kHeaderIconSize);
        UIImageView *rightIcon = [[UIImageView alloc] initWithFrame:rightIconFrame];
        rightIcon.image = [self.model nationalParkImage];
        rightIcon.contentMode = UIViewContentModeScaleAspectFit;
        [headerView addSubview:rightIcon];
        
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark Collection View Layout Protocol

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kCollectionCellSize, kCollectionCellSize);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kSectionInterItemSpacing;
}

-(CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kSectionLineSpacing;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kSectionLineSpacing, kSectionInterItemSpacing, kSectionLineSpacing, kSectionInterItemSpacing);
}

#pragma mark Collection View Delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)(cell.backgroundView);
    CGPoint offset = collectionView.contentOffset;
    CGRect realCellFrame = CGRectMake(cell.frame.origin.x - offset.x, cell.frame.origin.y - offset.y, cell.frame.size.width, cell.frame.size.height);
    JCLScrollView *scrollView = [[JCLScrollView alloc] initWithFrame:realCellFrame];
    self.startingFrame = realCellFrame;
    scrollView.imgView = imageView;
    [scrollView addSubview:imageView];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    [scrollView addGestureRecognizer:tapRecognizer];
    [self.view addSubview:scrollView];
    
    [self.collectionView setUserInteractionEnabled:false];
    [UIView animateWithDuration:kResizeAnimationTime animations:^{
        scrollView.frame = self.view.frame;
        self.collectionView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [scrollView setUserInteractionEnabled:true];
        [scrollView setContentSize:((UIView*)[[scrollView subviews] objectAtIndex:0]).bounds.size];
    }];
}
- (void)tapRecognized:(UITapGestureRecognizer *)recognizer{
    JCLScrollView *scrollView = (JCLScrollView *)(recognizer.view);
    if (scrollView.zoomScale != 1.0){
        return;
    }
    [UIView animateWithDuration:kResizeAnimationTime animations:^{
        scrollView.frame = self.startingFrame;
        self.collectionView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [scrollView removeFromSuperview];
        [self.collectionView setUserInteractionEnabled:true];
    }];
}

#pragma mark Segue

- (IBAction)barPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end