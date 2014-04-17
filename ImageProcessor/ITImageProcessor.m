//
//  ITImageProcessor.m
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/16/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import "ITImageProcessor.h"
#import "ITRenderedImageObject.h"

static NSInteger bytesPerPixel = 4;
static NSInteger bitsPerComponent = 8;

@interface ITImageProcessor()

+(ITRenderedImageObject *) ApplyGaussianBlurToImage:(CGImageRef)source withThreads:(NSInteger) threads;
+(ITRenderedImageObject *) ApplyBlackAndWhiteToImage:(CGImageRef)source withThreads:(NSInteger) threads;
+(Byte *) RawDataForImage: (CGImageRef)image;

@end

@implementation ITImageProcessor

+(ITRenderedImageObject *) ApplyEffect:(ITImageEffect)effect toSourceImage:(CGImageRef)source withThreads:(NSInteger)threads
{
    NSDate *start = [NSDate date];
    ITRenderedImageObject *returnObject;
    switch (effect) {
        case ITImageEffectBlackAndWhite:
            returnObject = [ITImageProcessor ApplyBlackAndWhiteToImage:source withThreads:threads];
            break;
            
        case ITImageEffectGaussianBlur:
            returnObject =  [ITImageProcessor ApplyGaussianBlurToImage:source withThreads:threads];
        default:
            break;
    }
    
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    returnObject.calculationDuration = timeInterval * -1;
    
    return returnObject;
}

+(ITRenderedImageObject *) ApplyGaussianBlurToImage:(CGImageRef)source withThreads:(NSInteger)threads
{
    return NULL;
}

+(ITRenderedImageObject *) ApplyBlackAndWhiteToImage:(CGImageRef)source withThreads:(NSInteger)threads
{
    // Thanks: http://brandontreb.com/image-manipulation-retrieving-and-updating-pixel-values-for-a-uiimage/

    NSInteger width = CGImageGetWidth(source);
    NSInteger height = CGImageGetHeight(source);
    NSInteger totalBytes = width * height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    Byte *rawData = malloc(height * width * 4);
    NSUInteger bytesPerRow = bytesPerPixel * width;
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), source);
    CGContextRelease(context);
    
    dispatch_group_t myGroup = dispatch_group_create();
    
    int byteIndex = 0;
    for (NSInteger t = 0; t < threads; t++)
    {
        __block NSInteger threadByteIndex = byteIndex;
        dispatch_group_async(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (NSInteger ii = 0; ii < totalBytes/threads ; ii++ )
            {
                int grey = (rawData[threadByteIndex] + rawData[threadByteIndex+1] + rawData[threadByteIndex+2]) / 3;
                
                rawData[threadByteIndex] = grey;
                rawData[threadByteIndex+1] = grey;
                rawData[threadByteIndex+2] = grey;
                
                threadByteIndex += 4;
            }
        
        });
        
        byteIndex += totalBytes/threads * bytesPerPixel;
    }
    
    
    dispatch_group_wait(myGroup, DISPATCH_TIME_FOREVER);
    
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
