// Part of BarrageRenderer. Created by UnAsh.
// Blog: http://blog.exbye.com
// Github: https://github.com/unash/BarrageRenderer

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2015年 UnAsh.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "BarrageCanvas.h"

@implementation BarrageCanvas

- (instancetype)init
{
    if (self = [super init]) {
//        self.userInteractionEnabled = NO;
//        self.backgroundColor = [UIColor clearColor];
//        self.clipsToBounds = YES;
        _margin = NSEdgeInsetsZero;
        _masked = YES;
    }
    return self;
}

- (void)layout
{
    [super layout];
    if (self.superview) {
        CGRect frame = CGRectMake(self.superview.bounds.origin.x - self.margin.left, self.superview.bounds.origin.y - self.margin.top,  self.superview.bounds.size.width - self.margin.left - self.margin.right, self.superview.bounds.size.height - self.margin.top - self.margin.bottom);
        if (!CGRectEqualToRect(self.frame, frame)) {
            self.frame = frame;
        }
    }
}

- (void)setMargin:(NSEdgeInsets)margin
{
    if(!NSEdgeInsetsEqual(margin, margin))
    {
        _margin = margin;
        [self setNeedsLayout:true];
    }
}

- (void)didMoveToSuperview
{
    [self setNeedsLayout:true];
}

- (NSView *)hitTest:(NSPoint)point {
    if (self.masked) return [super hitTest:point];
    for (NSView *view in self.subviews) {
        NSView *responder = [view hitTest:[view convertPoint:point fromView:self]];
        if (responder) return responder;
    }
    return nil;
}

- (BOOL)isFlipped {
    return YES;
}

@end
