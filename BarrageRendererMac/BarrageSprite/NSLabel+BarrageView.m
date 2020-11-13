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

#import "NSLabel+BarrageView.h"
#import "NSView+BarrageView.h"

@implementation NSTextField (BarrageView)

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.stringValue = @"";
    self.attributedStringValue = [[NSAttributedString alloc]init];
}

- (void)configureWithParams:(NSDictionary *)params
{
    [super configureWithParams:params];
    
    self.selectable = NO;
    self.editable = NO;
    self.bordered = NO;
    self.backgroundColor = [NSColor clearColor];
    
    NSString *text = params[@"text"];
    if (text) self.stringValue = text;
    
    NSColor *textColor = params[@"textColor"];
    if (textColor) self.textColor = textColor;
    else self.textColor = [NSColor blackColor];
    
    NSColor *shadowColor = params[@"shadowColor"];
    if (shadowColor) self.layer.shadowColor = shadowColor.CGColor;
    else self.layer.shadowColor = [NSColor clearColor].CGColor;
    
    id shadowOffsetObj = params[@"shadowOffset"];
    if (shadowOffsetObj) self.layer.shadowOffset = [shadowOffsetObj sizeValue];
    else self.layer.shadowOffset = CGSizeZero;
    
    id fontSizeObj = params[@"fontSize"];
    CGFloat fontSize = fontSizeObj?[fontSizeObj doubleValue]:16.0f;
    
    NSString *fontFamily = params[@"fontFamily"];
    self.font = fontFamily?[NSFont fontWithName:fontFamily size:fontSize]:[NSFont systemFontOfSize:fontSize];
    
    NSAttributedString *attributedText = params[@"attributedText"];
    if (attributedText) self.attributedStringValue = attributedText;
}

@end
