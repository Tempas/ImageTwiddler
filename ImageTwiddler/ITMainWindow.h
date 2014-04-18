//
//  ITMainWindow.h
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/15/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ITMainWindow : NSWindow <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSImageView *detailImageView;
@property (weak) IBOutlet NSPopUpButton *effectPopupButton;
@property (weak) IBOutlet NSPopUpButton *threadCountPopupButton;
@property (weak) IBOutlet NSButton *resetButton;
@property (weak) IBOutlet NSButton *renderButton;
@property (weak) IBOutlet NSView *timeInfoView;
@property (weak) IBOutlet NSTextField *timeLabel;
@property (weak) IBOutlet NSTextField *dimensionLabel;

- (IBAction)renderButtonPressed:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;

@end
