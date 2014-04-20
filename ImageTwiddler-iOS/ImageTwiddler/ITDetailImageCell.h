//
//  ITDetailImageCell.h
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/20/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * DetailImageCellIdentifier = @"DetailImageCell";

@interface ITDetailImageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *imageSizeLabel;

@end
