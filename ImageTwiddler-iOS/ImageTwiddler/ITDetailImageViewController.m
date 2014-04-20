//
//  ITDetailImageViewController.m
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/20/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import "ITDetailImageViewController.h"
#import "ITDetailImageCell.h"

@interface ITDetailImageViewController ()

@property (nonatomic) NSInteger initialSelectionIndex;

@end

@implementation ITDetailImageViewController

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
    // Do any additional setup after loading the view.
    self.backButton.layer.cornerRadius = self.backButton.frame.size.width/2;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_initialSelectionIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setInitialSelectionIndex:(NSInteger)selectionIndex
{
    _initialSelectionIndex = selectionIndex;
}


- (IBAction)backButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UICollectionView datasource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_imageSource numberOfImages];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ITDetailImageCell *cell = (ITDetailImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:DetailImageCellIdentifier forIndexPath:indexPath];
    
    cell.imageView.image = [_imageSource imageForCellAtIndexPath:indexPath];
    
    return cell;
}
@end
