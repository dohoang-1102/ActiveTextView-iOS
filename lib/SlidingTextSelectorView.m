//
//  SlidingTextSelectorView.m
//  ActiveTextView
//
//  Created by buza on 5/7/12.
//  Copyright (c) 2012 Storify. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

#import <QuartzCore/QuartzCore.h>

#import "SlidingTextSelectorView.h"

@interface SlidingTextSelectorView()
{
    CGFloat animationDuration;
}
@property(nonatomic, strong) CAShapeLayer *selectedLayer;
@end

@implementation SlidingTextSelectorView

@synthesize selectedLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        animationDuration = 0.15;
        self.layer.geometryFlipped = YES;
        self.selectedLayer = [CAShapeLayer layer];
        self.selectedLayer.backgroundColor = [UIColor blueColor].CGColor;
        self.selectedLayer.opacity = 0.3;
        [self.layer addSublayer:self.selectedLayer];
    }
    return self;
}

-(void) dealloc
{
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

-(void) setSelectedRect:(CGRect)rect
{
    //Build a rounded rectangle that will be used to animate between different
    //selected locations, and drawn behind the text itself.
    CGMutablePathRef retPath = CGPathCreateMutable();
    {    
        const CGFloat radius = 4;
        CGRect _rect = CGRectInset(rect, radius, radius);
        
        CGFloat in_r = _rect.origin.x + _rect.size.width;
        CGFloat out_r = rect.origin.x + rect.size.width;
        CGFloat in_b = _rect.origin.y + _rect.size.height;
        CGFloat out_b = rect.origin.y + rect.size.height;
        
        CGFloat in_t = _rect.origin.y;
        CGFloat out_t = rect.origin.y;
        CGFloat out_l = rect.origin.x;
        
        CGPathMoveToPoint(retPath, NULL, _rect.origin.x, out_t);
        
        CGPathAddLineToPoint(retPath, NULL, in_r,  out_t);
        CGPathAddArcToPoint (retPath, NULL, out_r, out_t, out_r, in_t, radius);
        CGPathAddLineToPoint(retPath, NULL, out_r, in_b);
        CGPathAddArcToPoint (retPath, NULL, out_r, out_b, in_r, out_b, radius);
        
        CGPathAddLineToPoint(retPath, NULL, _rect.origin.x, out_b);
        CGPathAddArcToPoint (retPath, NULL, out_l, out_b, out_l, in_b, radius);
        CGPathAddLineToPoint(retPath, NULL, out_l, in_t);
        CGPathAddArcToPoint (retPath, NULL, out_l, out_t, _rect.origin.x, out_t, radius);
        
        CGPathCloseSubpath(retPath);
    }
    
    //Animate the old path to the new one.
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = animationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.autoreverses = NO;
    animation.repeatCount = 0;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeBoth;    
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^ { self.selectedLayer.path = retPath; }];
    animation.fromValue = (id)self.selectedLayer.path;
    
#if !__has_feature(objc_arc)
    animation.toValue = (id)retPath;
#else
    animation.toValue = (__bridge id)retPath;
#endif

    [self.selectedLayer addAnimation:animation forKey:@"animatePath"];
    [CATransaction commit];
    
    CGPathRelease(retPath);
}

@end
