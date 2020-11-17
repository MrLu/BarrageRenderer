/*
* This file is part of the SDWebImage package.
* (c) Olivier Poitrey <rs@dailymotion.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/
#import <TargetConditionals.h>
#import "BarrageDisplayLink.h"
#import "BarrageWeakProxy.h"
#if IS_MAC
#import <CoreVideo/CoreVideo.h>
#elif TARGET_OS_IOS || TARGET_OS_TV
#import <QuartzCore/QuartzCore.h>
#endif

#if IS_MAC
static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext);
#endif

#define kSDDisplayLinkInterval 1.0 / 60

@interface BarrageDisplayLink ()

#if IS_MAC
@property (nonatomic, assign) CVDisplayLinkRef displayLink;
@property (nonatomic, assign) CVTimeStamp outputTime;
@property (nonatomic, copy) NSRunLoopMode runloopMode;
#elif TARGET_OS_IOS || TARGET_OS_TV
@property (nonatomic, strong) CADisplayLink *displayLink;
#else
@property (nonatomic, strong) NSTimer *displayLink;
@property (nonatomic, strong) NSRunLoop *runloop;
@property (nonatomic, copy) NSRunLoopMode runloopMode;
@property (nonatomic, assign) NSTimeInterval currentFireDate;
#endif

@end

@implementation BarrageDisplayLink

- (void)dealloc {
#if IS_MAC
    if (_displayLink) {
        CVDisplayLinkRelease(_displayLink);
        _displayLink = NULL;
    }
#elif TARGET_OS_IOS || TARGET_OS_TV
    [_displayLink invalidate];
    _displayLink = nil;
#else
    [_displayLink invalidate];
    _displayLink = nil;
#endif
}

- (instancetype)initWithTarget:(id)target selector:(SEL)sel {
    self = [super init];
    if (self) {
        _target = target;
        _selector = sel;
#if IS_MAC
        CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
        CVDisplayLinkSetOutputCallback(_displayLink, DisplayLinkCallback, (__bridge void *)self);
#elif TARGET_OS_IOS || TARGET_OS_TV
        BarrageWeakProxy *weakProxy = [BarrageWeakProxy proxyWithTarget:self];
        _displayLink = [CADisplayLink displayLinkWithTarget:weakProxy selector:@selector(displayLinkDidRefresh:)];
#else
        BarrageWeakProxy *weakProxy = [BarrageWeakProxy proxyWithTarget:self];
        _displayLink = [NSTimer timerWithTimeInterval:kSDDisplayLinkInterval target:weakProxy selector:@selector(displayLinkDidRefresh:) userInfo:nil repeats:YES];
#endif
    }
    return self;
}

+ (instancetype)displayLinkWithTarget:(id)target selector:(SEL)sel {
    BarrageDisplayLink *displayLink = [[BarrageDisplayLink alloc] initWithTarget:target selector:sel];
    return displayLink;
}

- (CFTimeInterval)duration {
#if IS_MAC
    CVTimeStamp outputTime = self.outputTime;
    NSTimeInterval duration = 0;
    double periodPerSecond = (double)outputTime.videoTimeScale * outputTime.rateScalar;
    if (periodPerSecond > 0) {
        duration = (double)outputTime.videoRefreshPeriod / periodPerSecond;
    }
#elif TARGET_OS_IOS || TARGET_OS_TV
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSTimeInterval duration = self.displayLink.duration * self.displayLink.frameInterval;
#pragma clang diagnostic pop
#else
    NSTimeInterval duration = 0;
    if (self.displayLink.isValid && self.currentFireDate != 0) {
        NSTimeInterval nextFireDate = CFRunLoopTimerGetNextFireDate((__bridge CFRunLoopTimerRef)self.displayLink);
        duration = nextFireDate - self.currentFireDate;
    }
#endif
    if (duration == 0) {
        duration = kSDDisplayLinkInterval;
    }
    return duration;
}

- (BOOL)isRunning {
#if IS_MAC
    return CVDisplayLinkIsRunning(self.displayLink);
#elif TARGET_OS_IOS || TARGET_OS_TV
    return !self.displayLink.isPaused;
#else
    return self.displayLink.isValid;
#endif
}

- (void)addToRunLoop:(NSRunLoop *)runloop forMode:(NSRunLoopMode)mode {
    if  (!runloop || !mode) {
        return;
    }
#if IS_MAC
    self.runloopMode = mode;
#elif TARGET_OS_IOS || TARGET_OS_TV
    [self.displayLink addToRunLoop:runloop forMode:mode];
#else
    self.runloop = runloop;
    self.runloopMode = mode;
    CFRunLoopMode cfMode;
    if ([mode isEqualToString:NSDefaultRunLoopMode]) {
        cfMode = kCFRunLoopDefaultMode;
    } else if ([mode isEqualToString:NSRunLoopCommonModes]) {
        cfMode = kCFRunLoopCommonModes;
    } else {
        cfMode = (__bridge CFStringRef)mode;
    }
    CFRunLoopAddTimer(runloop.getCFRunLoop, (__bridge CFRunLoopTimerRef)self.displayLink, cfMode);
#endif
}

- (void)removeFromRunLoop:(NSRunLoop *)runloop forMode:(NSRunLoopMode)mode {
    if  (!runloop || !mode) {
        return;
    }
#if IS_MAC
    self.runloopMode = nil;
#elif TARGET_OS_IOS || TARGET_OS_TV
    [self.displayLink removeFromRunLoop:runloop forMode:mode];
#else
    self.runloop = nil;
    self.runloopMode = nil;
    CFRunLoopMode cfMode;
    if ([mode isEqualToString:NSDefaultRunLoopMode]) {
        cfMode = kCFRunLoopDefaultMode;
    } else if ([mode isEqualToString:NSRunLoopCommonModes]) {
        cfMode = kCFRunLoopCommonModes;
    } else {
        cfMode = (__bridge CFStringRef)mode;
    }
    CFRunLoopRemoveTimer(runloop.getCFRunLoop, (__bridge CFRunLoopTimerRef)self.displayLink, cfMode);
#endif
}

- (void)start {
#if IS_MAC
    CVDisplayLinkStart(self.displayLink);
#elif TARGET_OS_IOS || TARGET_OS_TV
    self.displayLink.paused = NO;
#else
    if (self.displayLink.isValid) {
        [self.displayLink fire];
    } else {
        BarrageWeakProxy *weakProxy = [BarrageWeakProxy proxyWithTarget:self];
        self.displayLink = [NSTimer timerWithTimeInterval:kSDDisplayLinkInterval target:weakProxy selector:@selector(displayLinkDidRefresh:) userInfo:nil repeats:YES];
        [self addToRunLoop:self.runloop forMode:self.runloopMode];
    }
#endif
}

- (void)stop {
#if IS_MAC
    CVDisplayLinkStop(self.displayLink);
#elif TARGET_OS_IOS || TARGET_OS_TV
    self.displayLink.paused = YES;
#else
    [self.displayLink invalidate];
#endif
}

- (void)displayLinkDidRefresh:(id)displayLink {
#if IS_MAC
    // CVDisplayLink does not use runloop, but we can provide similar behavior for modes
    // May use `default` runloop to avoid extra callback when in `eventTracking` (mouse drag, scroll) or `modalPanel` (modal panel)
    NSString *runloopMode = self.runloopMode;
    if (![runloopMode isEqualToString:NSRunLoopCommonModes] && ![runloopMode isEqualToString:NSRunLoop.mainRunLoop.currentMode]) {
        return;
    }
#endif
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_target performSelector:_selector withObject:self];
#pragma clang diagnostic pop
#if TARGET_OS_WATCH
    self.currentFireDate = CFRunLoopTimerGetNextFireDate((__bridge CFRunLoopTimerRef)self.displayLink);
#endif
}

@end

#if IS_MAC
static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext) {
    // CVDisplayLink callback is not on main queue
    BarrageDisplayLink *object = (__bridge BarrageDisplayLink *)displayLinkContext;
    if (inOutputTime) {
        object.outputTime = *inOutputTime;
    }
    __weak BarrageDisplayLink *weakObject = object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakObject displayLinkDidRefresh:(__bridge id)(displayLink)];
    });
    return kCVReturnSuccess;
}
#endif
