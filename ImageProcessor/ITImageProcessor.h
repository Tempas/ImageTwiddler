//
//  ITImageProcessor.h
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/16/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EffectsConstants.h"
#import "ITImageEffectProgressListener.h"


#if TARGET_OS_IPHONE
#import "GPUImage.h"
#else
#import <GPUImage/GPUImage.h>
#endif

@class ITRenderedImageObject;

@interface ITImageProcessor : NSObject{
    GPUImagePicture *inputPicture;
    GPUImageFilter *imageFilter;
}

+ (ITRenderedImageObject *) ApplyEffect:(ITImageEffect)effect toSourceImage:(CGImageRef)source withThreads:(NSInteger) threads;
+ (ITRenderedImageObject *) ApplyEffect:(ITImageEffect)effect toSourceImage:(CGImageRef)source withThreads:(NSInteger)threads andProgressListener:(NSObject <ITImageEffectProgressListener> *) listener;

+ (NSArray *) ImageEffectsTitleArray;
+ (NSArray *) ThreadCountsTitleArray;
+ (NSInteger) NumberOfThreadsForThreadIndexSelected:(NSInteger)index;



@end
