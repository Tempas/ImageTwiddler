//
//  NSImage+CGImageRefHelper.h
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/19/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (CGImageRefHelper)

-(CGImageRef) getCGImageRef;
+(NSImage *) ImageWithCGImage:(CGImageRef)cgImage;

@end
