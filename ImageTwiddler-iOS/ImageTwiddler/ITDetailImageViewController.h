//
//  ITDetailImageViewController.h
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/20/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITImageEffectProgressListener.h"

@protocol ITDetailImageControllerImageSource <NSObject>

-(NSInteger) numberOfImages;
-(UIImage *) imageForCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ITDetailImageViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, ITImageEffectProgressListener>

@property (nonatomic, weak) NSObject <ITDetailImageControllerImageSource> * imageSource;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backButtonPressed:(id)sender;

-(void) setInitialSelectionIndex:(NSInteger) selectionIndex;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *effectLabel;
@property (weak, nonatomic) IBOutlet UILabel *threadCountLabel;

@end
