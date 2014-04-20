//
//  ITDetailImageViewController.m
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/20/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import "ITDetailImageViewController.h"
#import "ITDetailImageCell.h"
#import "ITImageProcessor.h"

@interface ITDetailImageViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *threadsBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *effectsBarButton;
@property (nonatomic) NSInteger initialSelectionIndex;
- (IBAction)effectsPressed:(id)sender;
- (IBAction)threadsPressed:(id)sender;
- (IBAction)renderPressed:(id)sender;

@property (nonatomic, retain) UIActionSheet * threadsActionSheet;
@property (nonatomic, retain) UIActionSheet * effectsActionSheet;

@property (nonatomic, retain) NSArray * threadTitleArray;
@property (nonatomic, retain) NSArray * effectTitleArray;

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
    
    self.threadCountLabel.layer.cornerRadius = self.threadCountLabel.frame.size.height/2;
    self.effectLabel.layer.cornerRadius = self.effectLabel.frame.size.height/2;
    
    _threadTitleArray = [ITImageProcessor ThreadCountsTitleArray];
    _effectTitleArray = [ITImageProcessor ImageEffectsTitleArray];
    
    _effectsActionSheet = [self actionSheetWithTitle:@"Select Effect" andItems:_effectTitleArray];
    _threadsActionSheet = [self actionSheetWithTitle:@"Number of Threads" andItems:_threadTitleArray];
    
    _effectLabel.text = _effectTitleArray[0];
    _threadCountLabel.text = [_threadTitleArray[0] stringByAppendingString:@" Threads"];
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

-(UIActionSheet *) actionSheetWithTitle:(NSString *)title andItems:(NSArray *)items
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                              delegate:self
                                     cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                     otherButtonTitles: nil];
    
    for (NSString *itemTitle in items)
    {
        [actionSheet addButtonWithTitle:itemTitle];
    }
    
    return actionSheet;
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

- (IBAction)effectsPressed:(id)sender {
    [_effectsActionSheet showFromBarButtonItem:_effectsBarButton animated:YES];
}

- (IBAction)threadsPressed:(id)sender {
    [_threadsActionSheet showFromBarButtonItem:_threadsBarButton animated:YES];
}

- (IBAction)renderPressed:(id)sender {
    
}

#pragma mark UIActionSheet delegate methods

-(void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet == _threadsActionSheet)
    {
        _threadCountLabel.text = [_threadTitleArray[buttonIndex] stringByAppendingString:@" Threads"];
    }
    else
    {
        _effectLabel.text = _effectTitleArray[buttonIndex];
    }
}
@end
