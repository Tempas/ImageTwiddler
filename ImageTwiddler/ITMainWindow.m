//
//  ITMainWindow.m
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/15/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import "ITMainWindow.h"
#import "ITImageTableCellView.h"

static NSInteger NumberOfImages = 11;

@interface ITMainWindow()

@property (nonatomic, retain) NSMutableArray *images;

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

-(void) initializeImages
{
    _images = [[NSMutableArray alloc] init];
    for (int i = 0; i < NumberOfImages; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"image%d", i ];
        NSImage *image = [NSImage imageNamed:imageName];
        [_images addObject:image];
    }
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
    }
    else {
        _detailImageView.image = nil;
    }
}




@end
