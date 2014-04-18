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


// Image Effect Names
static NSString * GaussianBlurEffectTitle = @"Gaussian Blur with Radius:";
static NSString * BlackAndWhiteEffectTitle = @"Black and White";



@interface ITImageProcessor()

+(ITRenderedImageObject *) ApplyGaussianBlurToImage:(CGImageRef)source withRadius:(NSInteger)radius andThreads:(NSInteger) threads andProgressListener:(NSObject<ITImageEffectProgressListener>  *)listener ;
+(ITRenderedImageObject *) ApplyBlackAndWhiteToImage:(CGImageRef)source withThreads:(NSInteger) threads andProgressListener:(NSObject <ITImageEffectProgressListener> *)listener;

@end

@implementation ITImageProcessor

+(ITRenderedImageObject *) ApplyEffect:(ITImageEffect)effect toSourceImage:(CGImageRef)source withThreads:(NSInteger)threads andProgressListener:(NSObject<ITImageEffectProgressListener> *)listener
{
    NSDate *start = [NSDate date];
    ITRenderedImageObject *returnObject;
    switch (effect) {
        case ITImageEffectBlackAndWhite:
            returnObject = [ITImageProcessor ApplyBlackAndWhiteToImage:source withThreads:threads andProgressListener:listener];
            break;
            
        case ITImageEffectGaussianBlurRadius5:
            returnObject =  [ITImageProcessor ApplyGaussianBlurToImage:source withRadius:5 andThreads:threads andProgressListener:listener];
            break;
            
        case ITImageEffectGaussianBlurRadius10:
            returnObject =  [ITImageProcessor ApplyGaussianBlurToImage:source withRadius:10 andThreads:threads andProgressListener:listener];

            break;
            
        case ITImageEffectGaussianBlurRadius15:
            returnObject =  [ITImageProcessor ApplyGaussianBlurToImage:source withRadius:15 andThreads:threads andProgressListener:listener];
            break;
            
        default:
            break;
    }
    
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    returnObject.calculationDuration = timeInterval * -1;
    
    return returnObject;
}

+ (ITRenderedImageObject *) ApplyEffect:(ITImageEffect)effect toSourceImage:(CGImageRef)source withThreads:(NSInteger)threads
{
    return [ITImageProcessor ApplyEffect:effect toSourceImage:source withThreads:threads andProgressListener:nil];
}

+(NSArray *) ImageEffectsTitleArray
{
    NSString *gaussianBlurRadius5Title = [GaussianBlurEffectTitle stringByAppendingString:@" 5"];
    NSString *gaussianBlurRadius10Title = [GaussianBlurEffectTitle stringByAppendingString:@" 10"];
    NSString *gaussianBlurRadius15Title = [GaussianBlurEffectTitle stringByAppendingString:@" 15"];
    
    return @[BlackAndWhiteEffectTitle, gaussianBlurRadius5Title, gaussianBlurRadius10Title, gaussianBlurRadius15Title];
}

#pragma mark private rendering functions


// thanks to http://blog.ivank.net/fastest-gaussian-blur.html#results

+(ITRenderedImageObject *) ApplyGaussianBlurToImage:(CGImageRef)source withRadius:(NSInteger)radius andThreads:(NSInteger)threads andProgressListener:(NSObject<ITImageEffectProgressListener> *)listener
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
    
    double gr = radius * 0.41;
    
    __block NSInteger pixelsProcessed = 0;
    __block NSInteger pixelsProcessedSinceUpdate = 0;
    NSInteger totalPixels = width * height;
    
    dispatch_group_t myGroup = dispatch_group_create();
    
    for (NSInteger t = 0; t < threads; t++)
    {
        dispatch_group_async(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

            for (NSInteger i = t*height/threads; i < height * ((t+1)/(double)threads) ; i++)
            {
                for (NSInteger j = 0; j < width; j ++)
                {
                    if (![listener shouldContinueProcessing])
                    {
                        break;
                    }
                    NSInteger fx = MAX(j - radius, 0);
                    NSInteger fy = MAX(i - radius, 0);
                    NSInteger tx = MIN(j + radius + 1, width);
                    NSInteger ty = MIN(i + radius + 1, height);
                    
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
                    }
                    
                    destData[(i * width + j) * bytesPerPixel] = pixelRValue;
                    destData[(i * width + j) * bytesPerPixel + 1] = pixelBValue;
                    destData[(i * width + j) * bytesPerPixel + 2] = pixelGValue;
                    destData[(i * width + j) * bytesPerPixel + 3] = rawData[(i * width + j) * bytesPerPixel + 3];
                    pixelsProcessed++;
                    pixelsProcessedSinceUpdate++;

                    if ((pixelsProcessedSinceUpdate/(double)totalPixels > .10 || pixelsProcessed/(double)totalPixels > .85) && [listener shouldContinueProcessing])
                    {
                        pixelsProcessedSinceUpdate = 0;
                        //NSLog(@"%@",@((double)pixelsProcessed/(double)totalPixels));
                        [listener performSelectorOnMainThread:@selector(updateProgressToPercent:) withObject:@((double)pixelsProcessed/(double)totalPixels) waitUntilDone:NO];
                    }
                        
                    
                }
            }
        });
    }
    
    dispatch_group_wait(myGroup, DISPATCH_TIME_FOREVER);

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

+(ITRenderedImageObject *) ApplyBlackAndWhiteToImage:(CGImageRef)source withThreads:(NSInteger)threads andProgressListener:(NSObject<ITImageEffectProgressListener> *)listener
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
