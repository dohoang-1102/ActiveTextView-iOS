//
//  ActiveTextView.m
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

#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

#import "ActiveTextView.h"
#import "SlidingTextSelectorView.h"

@interface ActiveTextView()

@property(readwrite) CGRect selectedRect;
@property(nonatomic, strong) UIFont *atFont;
@property(nonatomic, assign) CTFramesetterRef atFramesetter;
@property(nonatomic, strong) NSMutableAttributedString *atText;
@property(nonatomic, strong) NSMutableDictionary *actionDict;

@end

@implementation ActiveTextView

@synthesize text;
@synthesize atFont;
@synthesize atText;
@synthesize delegate;
@synthesize actionDict;
@synthesize selectedRect;
@synthesize textSelector;
@synthesize atFramesetter;
@synthesize highlightSelectedTextBackground;

- (id)initWithFrame:(CGRect)frame slidingSelectorView:(SlidingTextSelectorView*)slidingSelector
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.delegate = nil;
        self.atFramesetter = NULL;
        self.textSelector = slidingSelector;
        self.highlightSelectedTextBackground = NO;
        
        //If we aren't using a container view, we need to flip the geometry ourselves.
        if(!self.textSelector)
        {
            self.layer.geometryFlipped = YES;
        }
        
        self.selectedRect = CGRectZero;
        
        NSMutableDictionary *_actionDict = [[NSMutableDictionary alloc] initWithCapacity:1];
        self.actionDict = _actionDict;
        
#if !__has_feature(objc_arc)
        [_actionDict release];
#endif
        
        NSMutableAttributedString  *_atText = [[NSMutableAttributedString alloc] initWithString:@""];
        self.atText = _atText;
        
#if !__has_feature(objc_arc)
        [_atText release];
#endif
        
        self.atFont = [UIFont systemFontOfSize:16];
        
        UITapGestureRecognizer *selectTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        selectTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:selectTap];
        selectTap.delegate = self;
        
#if !__has_feature(objc_arc)
        [selectTap release];
#endif
        
    }
    return self;
}

-(void) dealloc
{
    if(atFramesetter)
        CFRelease(atFramesetter);
        
    self.atText = nil;
    self.delegate = nil;
    self.actionDict = nil;
    
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

-(void) setAction:(NSString*)actionName forTextRange:(NSRange)range
{
    [self.actionDict setObject:[NSValue valueWithRange:range] forKey:actionName];
}

-(void) setColor:(UIColor*)color forTextRange:(NSRange)range
{
    [self.atText beginEditing];
    
    NSRange theRange = range;
    
    if((range.location + range.length) > [self.text length])
        theRange = NSMakeRange(range.location, [self.text length] - range.location);
    
    //Clear out any previous colors sitting here.
    [self.atText removeAttribute:(NSString*)kCTForegroundColorAttributeName range:theRange];
    
    [self.atText addAttribute:(NSString*)kCTForegroundColorAttributeName
                                value:(id)color.CGColor
                                range:theRange];
    
    [self.atText endEditing];
    
    [self setNeedsDisplay];
}

-(void) setFont:(UIFont*)font forTextRange:(NSRange)range
{
    [self.atText beginEditing];
    
    NSRange theRange = range;
    
    if((range.location + range.length) > [self.text length])
        theRange = NSMakeRange(range.location, [self.text length] - range.location);
    
    //Clear out any previous fonts sitting here.
    [self.atText removeAttribute:(NSString*)kCTFontAttributeName range:theRange];
    
#if !__has_feature(objc_arc)
    CTFontRef theFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    [self.atText addAttribute:(id)kCTFontAttributeName value:(id)theFont range:theRange];
#else
    CTFontRef theFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    [self.atText addAttribute:(id)kCTFontAttributeName value:(__bridge id)theFont range:theRange];
#endif
    
    CFRelease(theFont);
    [self.atText endEditing];
    
    [self setNeedsDisplay];
}

-(void) setText:(NSString *)_text
{
    text = _text;
    NSAttributedString *atStr = [[NSAttributedString alloc] initWithString:self.text];
    [self.atText setAttributedString:atStr];
#if !__has_feature(objc_arc)
    [atStr release];
#endif
    
    if(atFramesetter)
    {
        CFRelease(atFramesetter);
        self.atFramesetter = NULL;
    }
    
    [self setNeedsDisplay];
}

-(void) tap:(UIGestureRecognizer*)sender
{
    if(!self.delegate) return;
    
    if(!atFramesetter)
    {
        if(atText)
        {
#if !__has_feature(objc_arc)
            atFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)atText);
#else
            atFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)atText); 
#endif
        }
    }
    
    UIBezierPath *thePath = [UIBezierPath bezierPathWithRect:self.bounds];
    CTFrameRef theFrame = CTFramesetterCreateFrame(atFramesetter, 
                                                   (CFRange){ .length = [text length] }, 
                                                   thePath.CGPath, 
                                                   NULL);
    
#if !__has_feature(objc_arc)
    NSArray *lines = (NSArray *) CTFrameGetLines(theFrame);
#else
    NSArray *lines = (__bridge NSArray *) CTFrameGetLines(theFrame);
#endif
    
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(theFrame, CFRangeMake(0, lines.count), origins);
    
    const CGPoint point = [sender locationInView:self];
    NSInteger matchedLine = -1;
    for (int i = 0; i < lines.count; i++) 
    {
        if (point.y > origins[i].y)
        {
            matchedLine = i;
            break;
        }
    }
    
    if(matchedLine == -1) matchedLine = lines.count - 1;
    {
        NSInteger i = matchedLine;

        if (point.y > origins[i].y)
        {
            
#if !__has_feature(objc_arc)
            CTLineRef line = (CTLineRef) [lines objectAtIndex:i];
#else
            CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
#endif
            
            NSInteger tappedIndex = CTLineGetStringIndexForPosition(line, point);
            
            for(NSString *key in [actionDict allKeys])
            {
                NSValue *rangeValue = [actionDict objectForKey:key];
                NSRange theRange = [rangeValue rangeValue];
                  
                if(tappedIndex >= theRange.location && tappedIndex <= (theRange.location + theRange.length))
                {
                    //Find the bounds of the selected string so we can highlight it later.
                    for (id runObj in (__bridge NSArray *)CTLineGetGlyphRuns(line)) 
                    {
                        CTRunRef run = (__bridge CTRunRef)runObj;
                        CFRange runRange = CTRunGetStringRange(run);
                        
                        if(theRange.location == runRange.location &&
                           theRange.length == runRange.length)
                        {
                            CGRect runBounds;
                            CGFloat ascent, descent;
                            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                            runBounds.size.height = ascent + descent;
                            
                            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                            
                            self.selectedRect = CGRectMake(xOffset, origins[i].y-descent, runBounds.size.width, runBounds.size.height);
                            if(self.textSelector)
                                [self.textSelector setSelectedRect:self.selectedRect];
                        }
                    }

                    [delegate performSelector:NSSelectorFromString(key) withObject:[text substringWithRange:theRange] afterDelay:0];
                    CFRelease(theFrame);
                    CFRelease(atFramesetter);
                    self.atFramesetter = NULL;
                    [self setNeedsDisplay];
                    return;
                }
            }
        }
    }
    
    CFRelease(atFramesetter);
    self.atFramesetter = NULL;
    CFRelease(theFrame);
}

-(void) roundedRect:(CGRect)rect withRadius:(CGFloat)radius inContext:(CGContextRef)theContext
{
    CGContextMoveToPoint(theContext, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(theContext, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(theContext, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI/2, 1);
    CGContextAddLineToPoint(theContext, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
    CGContextAddArc(theContext, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI/2, 0.f, 1);
    CGContextAddLineToPoint(theContext, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(theContext, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.f, -M_PI / 2, 1);
    CGContextAddLineToPoint(theContext, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(theContext, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI/2, M_PI, 1);
}

- (void)drawRect:(CGRect)_rect
{
    UIBezierPath *thePath = [UIBezierPath bezierPathWithRect:self.bounds];
    
    if(!atFramesetter)
    {
        if(atText)
        {
#if !__has_feature(objc_arc)
            atFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)atText);
#else
            atFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)atText); 
#endif
        }
    }
    
    CTFrameRef theFrame = CTFramesetterCreateFrame(atFramesetter, 
                                                   (CFRange){ .length = [atText length] }, 
                                                   thePath.CGPath, 
                                                   NULL);
    
    CGContextRef theContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(theContext);
    
    //Draw a stroked rect around the selected text if necessary.
    if(self.highlightSelectedTextBackground && !CGRectEqualToRect(self.selectedRect, CGRectZero))
    {
        CGRect rect = self.selectedRect;
        
        CGContextSetRGBFillColor(theContext, 0, 0, 1, 0.20);
        
        const CGFloat radius = 4;
        
        [self roundedRect:rect withRadius:radius inContext:theContext];
        CGContextFillPath(theContext); 
        
        CGContextSetStrokeColorWithColor(theContext, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor);
        [self roundedRect:rect withRadius:radius inContext:theContext];
        
        CGContextStrokePath(theContext);
    }

    CTFrameDraw(theFrame, theContext);
    CGContextRestoreGState(theContext);
    CFRelease(theFrame);
    
    CFRelease(atFramesetter);
    self.atFramesetter = NULL;
}

@end