//
//  AvatarBarrageView.m
//  BarrageRendererDemo
//
//  Created by InAsh on 20/07/2017.
//  Copyright © 2017 ExBye Inc. All rights reserved.
//

#import "AvatarBarrageView.h"
#import <BarrageRendererMac/NSView+BarrageView.h>

@interface AvatarBarrageView ()
@property(nonatomic,strong)NSImageView *imageView;
@property(nonatomic,strong)NSTextField *titleLabel;
@property(nonatomic,assign)NSTimeInterval time;
@property(nonatomic,strong)NSArray *titles;
@end

@implementation AvatarBarrageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self loadSubviews];
    }
    return self;
}

- (void)loadSubviews
{
    _imageView = [[NSImageView alloc]init];
    self.imageView.image = [NSImage imageNamed:@"avatar"];
    [self addSubview:self.imageView];
    
    _titleLabel = [[NSTextField alloc]init];
    self.titleLabel.textColor = [NSColor purpleColor];
    self.titleLabel.font = [NSFont systemFontOfSize:16.0f];
    [self addSubview:self.titleLabel];
}

- (void)layout
{
    CGFloat const imageWidth = 30.0f;
    [super layout];
    NSTimeInterval time = self.time*10;
    NSInteger num = 10;
    NSInteger frame = fabs(num/2 - time + (NSInteger)(time/num)*num);
    CGFloat newImageWidth = imageWidth*pow(0.9, frame);
    self.imageView.frame = CGRectMake((imageWidth-newImageWidth)/2, (imageWidth-newImageWidth)/2, newImageWidth, newImageWidth);
    self.titleLabel.frame = CGRectMake(imageWidth, 0, self.bounds.size.width-imageWidth, self.bounds.size.height);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat const imageWidth = 30.0f;
    NSTextField *prototypeLabel = self.titleLabel;
    CGFloat maxWidth = 0;
    CGFloat maxHeight = 0;
    for (NSString *title in self.titles) {
        prototypeLabel.stringValue = title;
        CGSize titleSize = [prototypeLabel sizeThatFits:CGSizeMake(10000, 10)];
        if (titleSize.width>maxWidth) {
            maxWidth = titleSize.width;
        }
        if (titleSize.height>maxHeight) {
            maxHeight = titleSize.height;
        }
    }
    if (imageWidth>maxHeight) {
        maxHeight = imageWidth;
    }
    maxWidth+= imageWidth;
    return CGSizeMake(maxWidth, maxHeight);
}

- (void)sizeToFit {
    [super sizeToFit];
    NSSize size = [self sizeThatFits:self.frame.size];
    self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

#pragma mark - BarrageViewProtocol

- (void)configureWithParams:(NSDictionary *)params
{
    [super configureWithParams:params];
    self.titles = params[@"titles"];
    self.titleLabel.stringValue = [self.titles firstObject];
}

- (void)updateWithTime:(NSTimeInterval)time
{
    _time = time;
    [self updateTexts];
    [self setNeedsLayout:true];
}

- (void)updateTexts
{
    if (!self.titles.count) {
        return;
    }
    NSInteger frame = ((NSInteger)floor(self.time*5)) % self.titles.count;
    self.titleLabel.stringValue = self.titles[frame];
}

@end
