//
//  NSImage+CGImageRefHelper.m
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/19/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import "NSImage+CGImageRefHelper.h"

@implementation NSImage (CGImageRefHelper)

-(CGImageRef) getCGImageRef
{
    CGImageSourceRef source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)[self TIFFRepresentation], NULL);
    CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    return maskRef;
}

+(NSImage *) ImageWithCGImage:(CGImageRef)cgImage
{
    size_t sizeWidth = CGImageGetWidth(cgImage);
    size_t sizeHeight = CGImageGetHeight(cgImage);
    CGSize size = CGSizeMake(sizeWidth, sizeHeight);
    
    return [[NSImage alloc] initWithCGImage:cgImage size:size];
}

@end
