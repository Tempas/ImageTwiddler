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

static NSInteger GaussianRadius = 10;

@interface ITImageProcessor()

+(ITRenderedImageObject *) ApplyGaussianBlurToImage:(CGImageRef)source withThreads:(NSInteger) threads;
+(ITRenderedImageObject *) ApplyBlackAndWhiteToImage:(CGImageRef)source withThreads:(NSInteger) threads;


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


// thanks to http://blog.ivank.net/fastest-gaussian-blur.html#results

+(ITRenderedImageObject *) ApplyGaussianBlurToImage:(CGImageRef)source withThreads:(NSInteger)threads
{
    NSInteger width = CGImageGetWidth(source);
    NSInteger height = CGImageGetHeight(source);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    Byte *rawData = malloc(height * width * 4);
    NSUInteger bytesPerRow = bytesPerPixel * width;
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), source);
    CGContextRelease(context);
    
    Byte * destData = malloc(height * width * 4);
    
    double gr = GaussianRadius * 0.41;
    
    for (NSInteger i = 0; i < height; i++)
    {
        for (NSInteger j = 0; j < width; j ++)
        {
            NSInteger fx = MAX(j - GaussianRadius, 0);
            NSInteger fy = MAX(i - GaussianRadius, 0);
            NSInteger tx = MIN(j + GaussianRadius + 1, width);
            NSInteger ty = MIN(i + GaussianRadius + 1, height);
            
            double pixelRValue = 0;
            double pixelGValue = 0;
            double pixelBValue = 0;
            
            for (NSInteger y = fy; y < ty; y++ )
            {
                for (NSInteger x = fx; x < tx; x++)
                {
                    NSInteger dsq = (x-j) * (x-j) + (y-i) * (y-i);
                    double weight = exp(-dsq / (2 * gr * gr)) / (M_PI * 2 * gr * gr);
                    pixelRValue += rawData[bytesPerPixel * (y*width+x)] * weight;
                    pixelBValue += rawData[bytesPerPixel * (y*width+x) + 1] * weight;
                    pixelGValue += rawData[bytesPerPixel * (y*width+x) + 2] * weight;
                }
                
                destData[(i * width + j) * bytesPerPixel] = pixelRValue;
                destData[(i * width + j) * bytesPerPixel + 1] = pixelBValue;
                destData[(i * width + j) * bytesPerPixel + 2] = pixelGValue;
                destData[(i * width + j) * bytesPerPixel + 3] = rawData[(i * width + j) * bytesPerPixel + 3];
            }
        }
    }

    CGContextRef ctx;
    ctx = CGBitmapContextCreate(destData,
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
            for (NSInteger i = 0; i < totalBytes/threads ; i++ )
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



@end
