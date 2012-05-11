//
//  ViewController.m
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

#import "ViewController.h"

#import "SlidingTextSelectorView.h"
#import "ActiveTextView.h"

//Enable this to run an example that creates a view that places a highlight
//rectangle behind the view that animates to new positions when a new
//active region is tapped by the user.
#define USE_SLIDING_SELECTOR

@interface ViewController ()
@property(nonatomic, strong) ActiveTextView *activeText;

-(void) defaultExample;
-(void) slidingSelectorExample;

@end

@implementation ViewController

@synthesize activeText;

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    
#ifndef USE_SLIDING_SELECTOR
    [self defaultExample];
#else
    [self slidingSelectorExample];
#endif
    
    [super viewDidLoad];
}

-(void) selectedHere1:(NSString*)selectedString
{
    //You can change the color of the text when the user selects it like so:
    //[activeText setColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5] forTextRange:NSMakeRange(53, 4)];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Selected First String!" message:@"This is a custom tap action" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];                                        
    [alert show];
    
#if !__has_feature(objc_arc)
    [alert release];
#endif
}

-(void) selectedHere2:(NSString*)selectedString
{
    //You can change the color of the text when the user selects it like so:
    //[activeText setColor:[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5] forTextRange:NSMakeRange(61, 4)];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Selected Second String!" message:@"This is a custom tap action" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];                                        
    [alert show];
    
#if !__has_feature(objc_arc)
    [alert release];
#endif 
}

-(void) slidingSelectorExample
{
    const CGRect textFrame = CGRectMake(10, 10, 300, 200);
    
    SlidingTextSelectorView *slidingTextSelectorView = [[SlidingTextSelectorView alloc] initWithFrame:textFrame];
    slidingTextSelectorView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:slidingTextSelectorView];
    
#if !__has_feature(objc_arc)
    [slidingTextSelectorView release];
#endif 
    
    const CGRect activeTextFrame = CGRectMake(0, 0, textFrame.size.width, textFrame.size.height);
    
    ActiveTextView *activeTextView = [[ActiveTextView alloc] initWithFrame:activeTextFrame slidingSelectorView:slidingTextSelectorView];
    
    self.activeText = activeTextView;
    self.activeText.highlightSelectedTextBackground = NO;
    [slidingTextSelectorView addSubview:activeText];
    activeText.delegate = self;
    
#if !__has_feature(objc_arc)
    [activeTextView release];
#endif 
    
    self.activeText.textSelector = slidingTextSelectorView;
    
    NSString *demoString = @"Hi! This is a demo of an ActiveTextView. You can tap here or here.";
    
    //First, set the main string.
    [activeText setText:demoString];
    
    //Now, we can set the font that will be used for the entire string. 
    [activeText setFont:[UIFont systemFontOfSize:28] forTextRange:NSMakeRange(0, [demoString length])];
    
    //We can set different fonts for different substrings.
    [activeText setFont:[UIFont boldSystemFontOfSize:28] forTextRange:NSMakeRange(25, 15)];
    
    //Here, we would like to make a region of text selectable. First, we give it a color
    // and then we attach an action.
    [activeText setColor:[UIColor redColor] forTextRange:NSMakeRange(53, 4)];
    [activeText setAction:@"selectedHere1:" forTextRange:NSMakeRange(53, 4)];
    
    [activeText setColor:[UIColor blueColor] forTextRange:NSMakeRange(61, 4)];
    [activeText setAction:@"selectedHere2:" forTextRange:NSMakeRange(61, 4)];
    
    activeText.backgroundColor = [UIColor clearColor];
}

-(void) defaultExample
{
    const CGRect textFrame = CGRectMake(10, 10, 300, 200);
    
    ActiveTextView *activeTextView = [[ActiveTextView alloc] initWithFrame:textFrame slidingSelectorView:nil];
    self.activeText = activeTextView;
    self.activeText.highlightSelectedTextBackground = YES;
    
#if !__has_feature(objc_arc)
    [activeTextView release];
#endif 
    
    [self.view addSubview:activeText];
    activeText.delegate = self;
    
    NSString *demoString = @"Hi! This is a demo of an ActiveTextView. You can tap here or here.";
    
    //First, set the main string.
    [activeText setText:demoString];
    
    //Now, we can set the font that will be used for the entire string. 
    [activeText setFont:[UIFont systemFontOfSize:28] forTextRange:NSMakeRange(0, [demoString length])];
    
    //We can set different fonts for different substrings.
    [activeText setFont:[UIFont boldSystemFontOfSize:28] forTextRange:NSMakeRange(25, 15)];
    
    //Here, we would like to make a region of text selectable. First, we give it a color
    // and then we attach an action.
    [activeText setColor:[UIColor redColor] forTextRange:NSMakeRange(53, 4)];
    [activeText setAction:@"selectedHere1:" forTextRange:NSMakeRange(53, 4)];
    
    [activeText setColor:[UIColor blueColor] forTextRange:NSMakeRange(61, 4)];
    [activeText setAction:@"selectedHere2:" forTextRange:NSMakeRange(61, 4)];
    
    activeText.backgroundColor = [UIColor clearColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
