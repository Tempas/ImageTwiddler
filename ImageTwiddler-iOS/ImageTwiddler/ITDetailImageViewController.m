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
#import "ITRenderedImageObject.h"

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

@property (nonatomic) NSInteger numberOfThreads;
@property (nonatomic) ITImageEffect imageEffect;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property (nonatomic) BOOL refreshPressed;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *timeContainerView;

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
    
    self.refreshButton.layer.cornerRadius = self.refreshButton.frame.size.width/2;
    
    self.threadCountLabel.layer.cornerRadius = self.threadCountLabel.frame.size.height/2;
    self.effectLabel.layer.cornerRadius = self.effectLabel.frame.size.height/2;
    
    _threadTitleArray = [ITImageProcessor ThreadCountsTitleArray];
    _effectTitleArray = [ITImageProcessor ImageEffectsTitleArray];
    
    _effectsActionSheet = [self actionSheetWithTitle:@"Select Effect" andItems:_effectTitleArray];
    _threadsActionSheet = [self actionSheetWithTitle:@"Number of Threads" andItems:_threadTitleArray];
    
    _effectLabel.text = _effectTitleArray[0];
    _threadCountLabel.text = [_threadTitleArray[0] stringByAppendingString:@" Threads"];
    _numberOfThreads = [ITImageProcessor NumberOfThreadsForThreadIndexSelected:0];
    _imageEffect = 0;
    
    _refreshPressed = NO;
    
    [self revealTimeContainer:NO withAnimation:NO];
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
    
    cell.imageSizeLabel.text = [NSString stringWithFormat:@"%d x %d", (int)cell.imageView.image.size.width, (int)cell.imageView.image.size.height ];
    
    return cell;
}

#pragma mark UICollectionView delegate methods

-(void) collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self revealTimeContainer:NO withAnimation:YES];
}

- (IBAction)effectsPressed:(id)sender {
    [_effectsActionSheet showFromBarButtonItem:_effectsBarButton animated:YES];
}

- (IBAction)threadsPressed:(id)sender {
    [_threadsActionSheet showFromBarButtonItem:_threadsBarButton animated:YES];
}

- (IBAction)renderPressed:(id)sender {
    _refreshPressed = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSIndexPath *currentIndexPath = self.collectionView.indexPathsForVisibleItems[0];
        ITDetailImageCell *cell = (ITDetailImageCell *)[self.collectionView cellForItemAtIndexPath:currentIndexPath];
        UIImage *selectedImage = cell.imageView.image;
        
        ITRenderedImageObject * result = [ITImageProcessor ApplyEffect:_imageEffect toSourceImage:selectedImage.CGImage withThreads:_numberOfThreads andProgressListener:self];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            self.timeLabel.text = result.calculationDurationText;
            [self revealTimeContainer:YES withAnimation:YES];
            self.progressBar.progress = 1;
            self.progressBar.progress = 0;
            
            if (!_refreshPressed)
            {
                cell.imageView.image = [[UIImage alloc] initWithCGImage: result.image];
            }

        });
    });
}

#pragma mark UIActionSheet delegate methods

-(void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet == _threadsActionSheet)
    {
        _threadCountLabel.text = [_threadTitleArray[buttonIndex] stringByAppendingString:@" Threads"];
        _numberOfThreads = [ITImageProcessor NumberOfThreadsForThreadIndexSelected:buttonIndex];
    }
    else
    {
        _effectLabel.text = _effectTitleArray[buttonIndex];
        _imageEffect = buttonIndex;
    }
}

#pragma mark ITImageEffectProgressListener Protocol methods

-(BOOL)shouldContinueProcessing
{
    return !_refreshPressed;
}

-(void) updateProgressToPercent:(NSNumber *)percent
{
    self.progressBar.progress = [percent floatValue];
}

- (IBAction)refreshButtonPressed:(id)sender {
    NSIndexPath *currentIndexPath = self.collectionView.indexPathsForVisibleItems[0];
    ITDetailImageCell *cell = (ITDetailImageCell *)[self.collectionView cellForItemAtIndexPath:currentIndexPath];
    cell.imageView.image = [_imageSource imageForCellAtIndexPath:currentIndexPath];
    self.progressBar.progress = 0;
    
    [self revealTimeContainer:NO withAnimation:YES];
    
    _refreshPressed = YES;
}

-(void) revealTimeContainer:(BOOL)reveal withAnimation:(BOOL)animation
{
    double endAlpha = reveal ? 1 : 0;
    
    [UIView animateWithDuration: animation ? .3 : 0
                     animations:^{
                         self.timeContainerView.alpha = endAlpha;
                     }];

}
@end
