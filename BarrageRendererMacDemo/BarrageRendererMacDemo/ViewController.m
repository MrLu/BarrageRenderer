//
//  ViewController.m
//  BarrageRendererMacDemo
//
//  Created by Mrlu on 2020/11/11.
//  Copyright © 2020 mrlu. All rights reserved.
//

#import "ViewController.h"
#import <BarrageRendererMac/BarrageRenderer.h>
#import "NSSafeObject.h"
#import "AvatarBarrageView.h"
#import "FlowerBarrageSprite.h"

@interface ViewController()<BarrageRendererDelegate>
{
    BarrageRenderer * _renderer;
    NSTimer * _timer;
    NSInteger _index;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _index = 0;
    [self initBarrageRenderer];
}

- (void)initBarrageRenderer
{
    _renderer = [[BarrageRenderer alloc]init];
    _renderer.smoothness = .2f;
    _renderer.delegate = self;
    [self.view addSubview:_renderer.view];
    _renderer.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    _renderer.canvasMargin = NSEdgeInsetsMake(10, 10, 10, 10);
    // 若想为弹幕增加点击功能, 请添加此句话, 并在Descriptor中注入行为
//    _renderer.view.userInteractionEnabled = YES;
    [self.view addSubview:_renderer.view];
}

- (void)viewDidAppear {
    [super viewDidAppear];
}

- (void)startMockingBarrageMessage
{
    [_timer invalidate];
    NSSafeObject * safeObj = [[NSSafeObject alloc]initWithObject:self withSelector:@selector(autoSendBarrage)];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:safeObj selector:@selector(excute) userInfo:nil repeats:YES];
}

- (void)stopMockingBarrageMessage
{
    [_timer invalidate];
}

- (void)dealloc
{
    [_renderer stop];
}

- (void)autoSendBarrage
{
    NSInteger spriteNumber = [_renderer spritesNumberWithName:nil];
//    self.infoLabel.text = [NSString stringWithFormat:@"当前屏幕弹幕数量: %ld",(long)spriteNumber];
    if (spriteNumber <= 500) { // 用来演示如何限制屏幕上的弹幕量
        [_renderer receive:[self walkTextSpriteDescriptorWithDirection:BarrageWalkDirectionR2L side:BarrageWalkSideLeft]];
        [_renderer receive:[self walkTextSpriteDescriptorWithDirection:BarrageWalkDirectionR2L side:BarrageWalkSideDefault]];

        [_renderer receive:[self walkTextSpriteDescriptorWithDirection:BarrageWalkDirectionB2T side:BarrageWalkSideLeft]];
        [_renderer receive:[self walkTextSpriteDescriptorWithDirection:BarrageWalkDirectionB2T side:BarrageWalkSideRight]];
        
        [_renderer receive:[self flowerImageSpriteDescriptor]];

        [_renderer receive:[self avatarBarrageViewSpriteDescriptorWithDirection:BarrageWalkDirectionR2L side:BarrageWalkSideDefault]];
        [_renderer receive:[self avatarBarrageViewSpriteDescriptorWithDirection:BarrageWalkDirectionR2L side:BarrageWalkSideDefault]];
        
        [_renderer receive:[self floatTextSpriteDescriptorWithDirection:BarrageFloatDirectionB2T side:BarrageFloatSideCenter]];
        [_renderer receive:[self floatTextSpriteDescriptorWithDirection:BarrageFloatDirectionT2B side:BarrageFloatSideLeft]];
        [_renderer receive:[self floatTextSpriteDescriptorWithDirection:BarrageFloatDirectionT2B side:BarrageFloatSideRight]];
        
        [_renderer receive:[self walkImageSpriteDescriptorWithDirection:BarrageWalkDirectionL2R]];
        [_renderer receive:[self walkImageSpriteDescriptorWithDirection:BarrageWalkDirectionL2R]];
        
        [_renderer receive:[self floatImageSpriteDescriptorWithDirection:BarrageFloatDirectionT2B]];
    }
}

#pragma mark - 弹幕描述符生产方法

/// 生成精灵描述 - 过场文字弹幕
- (BarrageDescriptor *)walkTextSpriteDescriptorWithDirection:(BarrageWalkDirection)direction
{
    return [self walkTextSpriteDescriptorWithDirection:direction side:BarrageWalkSideDefault];
}

/// 生成精灵描述 - 过场文字弹幕
- (BarrageDescriptor *)walkTextSpriteDescriptorWithDirection:(BarrageWalkDirection)direction side:(BarrageWalkSide)side
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([BarrageWalkTextSprite class]);
    descriptor.params[@"bizMsgId"] = [NSString stringWithFormat:@"%ld",(long)_index];
    descriptor.params[@"text"] = [NSString stringWithFormat:@"过场文字弹幕:%ld",(long)_index++];
    descriptor.params[@"textColor"] = [NSColor blueColor];
    descriptor.params[@"speed"] = @(100 * (double)random()/RAND_MAX+50);
    descriptor.params[@"direction"] = @(direction);
    descriptor.params[@"side"] = @(side);
//    descriptor.params[@"clickAction"] = ^(NSDictionary *params){
//        NSString *msg = [NSString stringWithFormat:@"弹幕 %@ 被点击",params[@"bizMsgId"]];
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
//        [alertView show];
//    };
    return descriptor;
}

/// 演示自定义弹幕样式
- (BarrageDescriptor *)avatarBarrageViewSpriteDescriptorWithDirection:(BarrageWalkDirection)direction side:(BarrageWalkSide)side
{
    NSArray *titles1 = @[@"♪└|°з°|┐♪",@"♪└|°ε°|┘♪",@"♪┌|°з°|┘♪",@"♪┌|°ε°|┐♪"];
    NSArray *titles2 = @[@"ʕ•̫͡•ʔ",@"ʕ•̫͡•̫͡•ʔ",@"ʕ•̫͡•=•̫͡•ʔ",@"ʕ•̫͡•ʔ ʕ•̫͡•ʔ",@"ʕ•̫͡•ʔ ʕ•̫͡•̫͡•ʔ",@"ʕ•̫͡•ʔ ʕ•̫͡•=•̫͡•ʔ",@"ʕ•̫͡•ʔ ʕ•̫͡•ʔ ʕ•̫͡•ʔ",
                         @"ʕ•̫͡•ʔ ʕ•̫͡•=•̫͡•ʔ",@"ʕ•̫͡•ʔ ʕ•̫͡•̫͡•ʔ",@"ʕ•̫͡•ʔ ʕ•̫͡•ʔ",@"ʕ•̫͡•=•̫͡•ʔ",@"ʕ•̫͡•̫͡•ʔ",@"ʕ•̫͡•ʔ"];

    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([BarrageWalkSprite class]);
    descriptor.params[@"speed"] = @(100 * (double)random()/RAND_MAX+50);
    descriptor.params[@"direction"] = @(direction);
    descriptor.params[@"side"] = @(side);
    descriptor.params[@"viewClassName"] = NSStringFromClass([AvatarBarrageView class]);
    descriptor.params[@"titles"] = (_index%2) ? titles1: titles2;

    __weak BarrageRenderer *render = _renderer;
    descriptor.params[@"clickAction"] = ^(NSDictionary *params){
        [render removeSpriteWithIdentifier:params[@"identifier"]];
    };

    return descriptor;
}

- (NSString *)randomString
{
    NSInteger count = ceil(10*(double)random()/RAND_MAX);
    NSMutableString *string = [[NSMutableString alloc]initWithCapacity:10];
    for (NSInteger i = 0; i < count; i++) {
        [string appendString:@"Br"];
    }
    return [string copy];
}

- (BarrageDescriptor *)flowerImageSpriteDescriptor
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([FlowerBarrageSprite class]);
    descriptor.params[@"image"] = [NSImage imageNamed:@"avatar"];
    descriptor.params[@"duration"] = @(10);
    descriptor.params[@"viewClassName"] = NSStringFromClass([NSTextField class]);
    descriptor.params[@"text"] = @"^*-*^";
    descriptor.params[@"borderWidth"] = @(1);
    descriptor.params[@"borderColor"] = [NSColor grayColor];
    descriptor.params[@"scaleRatio"] = @(4);
    descriptor.params[@"rotateRatio"] = @(100);
    return descriptor;
}

// 生成精灵描述 - 浮动文字弹幕
- (BarrageDescriptor *)floatTextSpriteDescriptorWithDirection:(NSInteger)direction
{
    return [self floatTextSpriteDescriptorWithDirection:direction side:BarrageFloatSideCenter];
}

/// 生成精灵描述 - 浮动文字弹幕
- (BarrageDescriptor *)floatTextSpriteDescriptorWithDirection:(NSInteger)direction side:(BarrageFloatSide)side
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([BarrageFloatTextSprite class]);
    descriptor.params[@"text"] = [NSString stringWithFormat:@"AA-图文混排/::B过场弹幕:%ld",(long)_index++];
    descriptor.params[@"viewClassName"] = @"NSTextField";
    descriptor.params[@"textColor"] = [NSColor purpleColor];
    descriptor.params[@"duration"] = @(3);
    descriptor.params[@"fadeInTime"] = @(1);
    descriptor.params[@"fadeOutTime"] = @(1);
    descriptor.params[@"direction"] = @(direction);
    descriptor.params[@"side"] = @(side);
    return descriptor;
}

/// 生成精灵描述 - 过场图片弹幕
- (BarrageDescriptor *)walkImageSpriteDescriptorWithDirection:(NSInteger)direction
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([BarrageWalkImageSprite class]);
    descriptor.params[@"image"] = [NSImage imageNamed:@"avatar"];
    descriptor.params[@"speed"] = @(100 * (double)random()/RAND_MAX+50);
    descriptor.params[@"direction"] = @(direction);
    descriptor.params[@"trackNumber"] = @5; // 轨道数量
    descriptor.params[@"size"] = @(CGSizeMake(30, 30));
    return descriptor;
}

///// 生成精灵描述 - 浮动图片弹幕
- (BarrageDescriptor *)floatImageSpriteDescriptorWithDirection:(NSInteger)direction
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([BarrageFloatImageSprite class]);
    descriptor.params[@"image"] = [NSImage imageNamed:@"avatar"];
    descriptor.params[@"duration"] = @(3);
    descriptor.params[@"direction"] = @(direction);
    descriptor.params[@"size"] = @(CGSizeMake(30, 30));
    return descriptor;
}

#pragma mark - BarrageRendererDelegate

/// 演示如何拿到弹幕的生命周期
- (void)barrageRenderer:(BarrageRenderer *)renderer spriteStage:(BarrageSpriteStage)stage spriteParams:(NSDictionary *)params
{
    NSString *subid = [params[@"identifier"] substringToIndex:8];
    if (stage == BarrageSpriteStageBegin) {
        NSLog(@"id:%@,bizMsgId:%@ =>进入",subid,params[@"bizMsgId"]);
    } else if (stage == BarrageSpriteStageEnd) {
        NSLog(@"id:%@,bizMsgId:%@ =>离开",subid,params[@"bizMsgId"]);
        /* 注释代码演示了如何复制一条弹幕
        BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
        descriptor.spriteName = NSStringFromClass([BarrageWalkTextSprite class]);
        [descriptor.params addEntriesFromDictionary:params];
        descriptor.params[@"delay"] = @(0);
        [renderer receive:descriptor];
        */
    }
}


#pragma mark - Action
- (IBAction)start:(id)sender
{
    [_renderer start];
    [self startMockingBarrageMessage];
//    [self autoSendBarrage];
}
- (IBAction)stop:(id)sender
{
    [_renderer stop];
    [self stopMockingBarrageMessage];
}
- (IBAction)pause:(id)sender
{
    [_renderer pause];
}
- (IBAction)resume:(id)sender
{
    [_renderer start];
}

- (IBAction)faster:(id)sender
{
    CGFloat speed = _renderer.speed + 0.5;
    if (speed >= 10) {
        speed = 10.0f;
    }
    _renderer.speed = speed;
}
- (IBAction)slower:(id)sender
{
    CGFloat speed = _renderer.speed - 0.5;
    if (speed <= 0.5f) {
        speed = 0.5;
    }
    _renderer.speed = speed;
}

@end
