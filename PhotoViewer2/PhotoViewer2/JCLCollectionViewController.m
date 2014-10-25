//
//  JCLCollectionViewController.m
//  PhotoViewer2
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/23/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLCollectionViewController.h"
#import "JCLCollectionReusableView.h"
#import "JCLCollectionViewCell.h"
#import "JCLModel.h"

@interface JCLCollectionViewController () <UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) JCLModel *model;

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
        
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark Collection View Layout Protocol

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CELL_SIZE, CELL_SIZE);
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
    /* Replace with code to bring up zoomable scroll view for single image.
     
    ColorViewController *colorViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ColorViewController"];
    
    // initialize color
    NSInteger index = indexPath.section*sectionSize + indexPath.row;
    UIColor *color = [self.model backgroundColorForPage:index];
    colorViewController.pageColor = color;
    colorViewController.delegate = self;
    
    // create the popover & present
    _myPopoverController = [[UIPopoverController alloc] initWithContentViewController:colorViewController];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CGRect frame = cell.frame;
    
    
    
    
    // remember what was selected
    self.selectedIndexPath = indexPath;
    self.selectedIndex = index;
    
    [_myPopoverController presentPopoverFromRect:frame inView:self.collectionView  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
     
     */
}

@end