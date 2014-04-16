//
//  ITImageProcessor.m
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/16/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import "ITImageProcessor.h"
#import "ITRenderedImageObject.h"

@interface ITImageProcessor()

+(ITRenderedImageObject *) ApplyGaussianBlurToImage:(CGImageRef)source withThreads:(NSInteger) threads;
+(ITRenderedImageObject *) ApplyBlackAndWhiteToImage:(CGImageRef)source withThreads:(NSInteger) threads;
+(Byte *) RawDataForImage: (CGImageRef)image;

@end

@implementation ITImageProcessor

+(ITRenderedImageObject *) ApplyEffect:(ITImageEffect)effect toSourceImage:(CGImageRef)source withThreads:(NSInteger)threads
{
    switch (effect) {
        case ITImageEffectBlackAndWhite:
            return [ITImageProcessor ApplyBlackAndWhiteToImage:source withThreads:threads];
            break;
            
        case ITImageEffectGaussianBlur:
            return [ITImageProcessor ApplyGaussianBlurToImage:source withThreads:threads];
            
        default:
            break;
    }
    
    return NULL;
}

+(ITRenderedImageObject *) ApplyGaussianBlurToImage:(CGImageRef)source withThreads:(NSInteger)threads
{
    return NULL;
}

+(ITRenderedImageObject *) ApplyBlackAndWhiteToImage:(CGImageRef)source withThreads:(NSInteger)threads
{
    // Thanks: http://brandontreb.com/image-manipulation-retrieving-and-updating-pixel-values-for-a-uiimage/

    NSUInteger width = CGImageGetWidth(source);
    NSUInteger height = CGImageGetHeight(source);
    NSUInteger totalBytes = width * height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    Byte *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), source);
    CGContextRelease(context);
    
    int byteIndex = 0;
    for (int ii = 0 ; ii < totalBytes ; ++ii)
    {
        int grey = (rawData[byteIndex] + rawData[byteIndex+1] + rawData[byteIndex+2]) / 3;
        
        rawData[byteIndex] = grey;
        rawData[byteIndex+1] = grey;
        rawData[byteIndex+2] = grey;
        
        byteIndex += 4;
    }
    
    CGContextRef ctx;
    ctx = CGBitmapContextCreate(rawData,
                                width,
                                height,
                                8,
                                bytesPerRow,
                                colorSpace,
                                kCGImageAlphaPremultipliedLast );
    
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    
    
    return [[ITRenderedImageObject alloc] initWithImage:imageRef
                                           calcDuration:0
                                        numberOfThreads:threads];
}

#pragma mark helper methods

+(Byte *)RawDataForImage:(CGImageRef)image
{
    return nil;
}

@end
