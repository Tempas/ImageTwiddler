//
//  ITImageEffectProgressListener.h
//  ImageTwiddler
//
//  Created by Ryan Tempas on 4/18/14.
//  Copyright (c) 2014 Tauer Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ITImageEffectProgressListener <NSObject>

-(void) updateProgressToPercent:(double) percent;

@end
