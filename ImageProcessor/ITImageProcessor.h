//
//  ITImageProcessor.h
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/16/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EffectsConstants.h"

@class ITRenderedImageObject;

@interface ITImageProcessor : NSObject

+ (ITRenderedImageObject *) ApplyEffect:(ITImageEffect)effect toSourceImage:(CGImageRef)source withThreads:(NSInteger) threads;

+ (NSArray *) ImageEffectsTitleArray;

@end
