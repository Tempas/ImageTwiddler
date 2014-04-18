//
//  ITMainWindow.m
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/15/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import "ITMainWindow.h"
#import "ITImageTableCellView.h"
#import "EffectsConstants.h"
#import "ITImageProcessor.h"
#import "ITRenderedImageObject.h"

static NSInteger NumberOfImages = 12;



@interface ITMainWindow()

@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic) __block BOOL resetPressed;

@end

@implementation ITMainWindow

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        
    }
    
    return self;
}
-(id) initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self)
    {
        [self initializeImages];

        _detailImageView.image = nil;
        _detailImageView.imageScaling = NSScaleProportionally;
    }
    
    return self;
}

-(void) awakeFromNib
{
    [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    _dimensionLabel.layer.cornerRadius = 30;
    _dimensionLabel.layer.masksToBounds = YES;
    [self initializeEffectPopupButton];
    [self initializeThreadPopupButton];
    _resetPressed = NO;
    
    [self enableControls:YES];
}

-(void) initializeImages
{
    _images = [[NSMutableArray alloc] init];
    for (int i = 0; i < NumberOfImages; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"image%d", i ];
        NSImage *image = [NSImage imageNamed:imageName];
        [_images addObject:image];
    }
    
    [_images sortUsingComparator:^ NSComparisonResult(NSImage *i1, NSImage *i2) {
        CGFloat image1Size = i1.size.width * i1.size.height;
        CGFloat image2Size = i2.size.width * i2.size.height;
        
        if (image1Size > image2Size)
            return NSOrderedDescending;
        if (image1Size < image2Size)
            return NSOrderedAscending;
        
        return NSOrderedSame;
    }];
}


-(void) initializeThreadPopupButton
{
    [_threadCountPopupButton removeAllItems];
    [_threadCountPopupButton addItemsWithTitles:@[@"1", @"2", @"4", @"8", @"16"]];
}

-(void) initializeEffectPopupButton
{
    [_effectPopupButton removeAllItems];
    [_effectPopupButton addItemsWithTitles:[ITImageProcessor ImageEffectsTitleArray]];
}

-(void) setDimensionLabelText
{
    CGSize imageSize = _detailImageView.image.size;
    NSString * dimensionText = [NSString stringWithFormat:@"%dx%d", (int)imageSize.width, (int)imageSize.height];
    _dimensionLabel.stringValue = dimensionText;
}


#pragma mark NSTableView datasource methods

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_images count];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    ITImageTableCellView *result = (ITImageTableCellView *)[tableView makeViewWithIdentifier:ImageTableCellIdentifier owner:self];
    
    result.imageView.image = _images[row];
    return result;
    
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger selectedRow = [_tableView selectedRow];

    if (selectedRow != -1) {
        _detailImageView.image =_images[selectedRow];
        _detailImageView.alphaValue = 1;
        [self setDimensionLabelText];
        [self enableControls:YES];
    }
    else {
        _detailImageView.image = nil;
    }
}

#pragma mark controls logic

- (IBAction)renderButtonPressed:(id)sender {
    [self enableControls:NO];
    _resetPressed = NO;
    
    NSInteger selectedThreadIndex = [_threadCountPopupButton indexOfSelectedItem];
    NSInteger numberOfThreads = pow(2, selectedThreadIndex);
    
    ITImageEffect effectToApply = (ITImageEffect)[_effectPopupButton indexOfSelectedItem];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSImage *selectedImage = _images[[_tableView selectedRow]];
        CGImageSourceRef source;
        source = CGImageSourceCreateWithData((__bridge CFDataRef)[selectedImage TIFFRepresentation], NULL);
        CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
        
        ITRenderedImageObject * result = [ITImageProcessor ApplyEffect:effectToApply toSourceImage:maskRef withThreads:numberOfThreads];
        if (!_resetPressed)
        {
            // get and set duration text
            int maxDigitsAfterDecimal = 4; // here's where you set the dp
            NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
            [nf setMaximumFractionDigits:maxDigitsAfterDecimal];
            [nf setMinimumIntegerDigits:1];
            NSString * trimmed = [nf stringFromNumber:[NSNumber numberWithDouble:result.calculationDuration]];
            _timeLabel.stringValue = trimmed;
            
            // get and set the resulting image
            NSImage *resultImage = [[NSImage alloc] initWithCGImage:result.image size:selectedImage.size];
            _detailImageView.image = resultImage;
            
            self.timeInfoView.alphaValue = 1;
        }
    });
}

- (IBAction)resetButtonPressed:(id)sender {
    [self enableControls:YES];
    _resetPressed = YES;
    
    _detailImageView.image = _images[[_tableView selectedRow]];
}

-(void) enableControls:(BOOL)enable
{
    if (enable)
    {
        _resetButton.alphaValue = 0;
        _timeInfoView.alphaValue = 0;
    }
    else
    {
        _resetButton.alphaValue = 1;
    }
    
    [_renderButton setEnabled:enable];
    [_threadCountPopupButton setEnabled:enable];
    [_effectPopupButton setEnabled:enable];
}
@end
