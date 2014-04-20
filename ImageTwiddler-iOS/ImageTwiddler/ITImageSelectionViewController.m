//
//  ITImageSelectionViewController.m
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/19/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import "ITImageSelectionViewController.h"
#import "EffectsConstants.h"
#import "ITImageCell.h"



@interface ITImageSelectionViewController ()

@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic) NSInteger selectedRow;

@end

@implementation ITImageSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeImages];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initializeImages
{
    _images = [[NSMutableArray alloc] init];
    for (int i = 0; i < NumberOfImages; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"image%d.png", i ];
        UIImage *image = [UIImage imageNamed:imageName];
        [_images addObject:image];
    }
    
    [_images sortUsingComparator:^ NSComparisonResult(UIImage *i1, UIImage *i2) {
        CGFloat image1Size = i1.size.width * i1.size.height;
        CGFloat image2Size = i2.size.width * i2.size.height;
        
        if (image1Size > image2Size)
            return NSOrderedDescending;
        if (image1Size < image2Size)
            return NSOrderedAscending;
        
        return NSOrderedSame;
    }];
}

#pragma mark UICollectionView datasource methods

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_images count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ITImageCell * cell = (ITImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ImageCellIdentifier forIndexPath:indexPath];
    
    cell.imageView.image = _images[indexPath.row];
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ITDetailImageViewController * detailController = (ITDetailImageViewController *)[segue destinationViewController];
    detailController.imageSource = self;
    
    NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems[0];
    [detailController setInitialSelectionIndex:selectedIndexPath.row];
}

#pragma mark ITDetailImageViewController image source methods

-(NSInteger)numberOfImages
{
    return [_images count];
}

-(UIImage *)imageForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return _images[indexPath.row];
}



@end
