//
//  ITRenderedImageObject.h
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/16/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITRenderedImageObject : NSObject

@property (nonatomic) CGImageRef image;
@property (nonatomic) double calculationDuration;
@property (nonatomic) NSString *calculationDurationText;
@property (nonatomic) NSInteger numberOfThreads;

-(id) initWithImage:(CGImageRef)image calcDuration:(double)duration numberOfThreads:(NSInteger)threads;

@end
