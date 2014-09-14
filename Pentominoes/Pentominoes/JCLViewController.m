//
//  JCLViewController.m
//  Pentominoes
//
//  Created by JOSHUA CHRISTOPHER LEE on 9/13/14.
//  Copyright (c) 2014 Joshua Lee. All rights reserved.
//

#import "JCLViewController.h"

@interface JCLViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *boardView;
- (IBAction)boardButtonPressed:(UIButton *)sender;
- (IBAction)solvePresssed:(id)sender;
- (IBAction)resetPressed:(id)sender;

@property NSInteger height, width;

@end

@implementation JCLViewController

const NSInteger NUM_BOARDS = 6;
const NSInteger NUM_TILES = 12;
const NSInteger MAX_TILE_WIDTH = 150;
const NSInteger MAX_TILE_HEIGHT = 150;
const NSInteger STARTING_Y = 550;
NSMutableArray *boardImages;
NSMutableDictionary *tiles;
NSArray *tileKeys;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.height = self.view.bounds.size.height;
    self.width = self.view.bounds.size.width;
    [self loadBoardImages];
    [self loadTiles];
    [self initTilePositions];
}

- (void) loadBoardImages{
    boardImages = [[NSMutableArray alloc] init];
    for (int i = 0; i < NUM_BOARDS; ++i){
        NSString *imageName = [NSString stringWithFormat:@"Board%d", i];
        [boardImages addObject:[UIImage imageNamed:imageName]];
    }
}

- (void) loadTiles{
    tiles = [[NSMutableDictionary alloc] init];
    tileKeys = @[@"F", @"I", @"L", @"N", @"P", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    for (NSString *key in tileKeys){
        UIImage *img = [UIImage imageNamed:[@"tile" stringByAppendingString:key]];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
        tiles[key] = imgView;
    }
    /*
    tiles = [[NSMutableArray alloc] init];
    UIImage *img = [UIImage imageNamed:@"tileF"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    [tiles addObject:imgView];
    img = [UIImage imageNamed:@"tileI"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [tiles addObject:imgView];
    img = [UIImage imageNamed:@"tileL"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [tiles addObject:imgView];
    img = [UIImage imageNamed:@"tileN"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [tiles addObject:imgView];
    img = [UIImage imageNamed:@"tileP"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [tiles addObject:imgView];
    img = [UIImage imageNamed:@"tileT"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [tiles addObject:imgView];
    img = [UIImage imageNamed:@"tileU"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [tiles addObject:imgView];
    img = [UIImage imageNamed:@"tileV"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [tiles addObject:imgView];
    img = [UIImage imageNamed:@"tileW"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [tiles addObject:imgView];
    img = [UIImage imageNamed:@"tileX"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [tiles addObject:imgView];
    img = [UIImage imageNamed:@"tileY"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [tiles addObject:imgView];
    img = [UIImage imageNamed:@"tileZ"];
    imgView = [[UIImageView alloc] initWithImage:img];
    [tiles addObject:imgView];
      */
}

// Placing tiles in their initial position.
- (void) initTilePositions{
    NSInteger tilesAcross = self.width / MAX_TILE_WIDTH;
    NSInteger tilesDown = NUM_TILES / tilesAcross;
    if (NUM_TILES % tilesAcross != 0){
        tilesDown++;
    }
    NSInteger remainder = self.width % MAX_TILE_WIDTH;
    NSInteger padding = remainder / tilesAcross;
    NSInteger x = padding;
    NSInteger y = STARTING_Y;
    NSInteger xCounter = 0;
    
    for (NSString *key in tileKeys){
        UIImageView *tile = tiles[key];
        CGSize imgSize = [[tile image] size];
        x = xCounter * (padding + MAX_TILE_WIDTH) + padding;
        CGRect dim = CGRectMake(x, y, imgSize.width, imgSize.height);
        tile.frame = dim;
        tile.contentMode = UIViewContentModeTopLeft;
        [[self view] addSubview:tile];
        
        xCounter++;
        if (xCounter >= tilesAcross){
            xCounter = 0;
            y += MAX_TILE_HEIGHT + padding;
        }
    }
}

- (IBAction)boardButtonPressed:(UIButton *)sender {
    [self.boardView setImage:[boardImages objectAtIndex:sender.tag]];
}

- (IBAction)solvePresssed:(id)sender {
}

- (IBAction)resetPressed:(id)sender {
}
@end
