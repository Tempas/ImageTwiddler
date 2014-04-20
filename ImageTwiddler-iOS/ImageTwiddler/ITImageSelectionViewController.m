//
//  ITImageSelectionViewController.m
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/19/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import "ITImageSelectionViewController.h"
#import "EffectsConstants.h"


@interface ITImageSelectionViewController ()

@property (nonatomic, retain) NSMutableArray *images;

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
        NSString *imageName = [NSString stringWithFormat:@"image%d", i ];
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
