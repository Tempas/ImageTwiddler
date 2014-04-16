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

@end
