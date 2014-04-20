//
//  ITImageCell.h
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/19/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * ImageCellIdentifier = @"ImageCell";

@interface ITImageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
