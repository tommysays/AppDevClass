//
//  JCLTableViewController.m
//  PhotoViewer2
//
//  Created by JOSHUA CHRISTOPHER LEE on 10/24/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLTableViewController.h"
#import "JCLTableViewCell.h"
#import "JCLModel.h"

@interface JCLTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) JCLModel *model;

@end

@implementation JCLTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        _model = [JCLModel sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.model numberOfSets];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.model sizeOfSet:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    JCLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    
    NSInteger photosetIndex = indexPath.section;
    NSInteger photoIndex = indexPath.row;
    cell.photoCaption.text = [self.model nameOfImage:photoIndex fromSet:photosetIndex];
    cell.imageView.image = [self.model image:photoIndex fromSet:photosetIndex];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}

/*
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionName = [self.model nameOfSet:section];
    CGFloat width = self.view.frame.size.width;
    CGFloat height = tableView.sectionFooterHeight;
    CGRect frame = CGRectMake(0, 0, width, height);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    [view addSubview:lbl];
    return view;
}
*/


// Section titles & index
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.model nameOfSet:section];
}
/*

-(NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *titles = [NSMutableArray array];
    for (int i=0; i<[self numberOfSectionsInTableView:tableView]; i++) {
        [titles addObject:[NSString stringWithFormat:@"%02d", i*sectionSize]];
    }
    return titles;
}
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
