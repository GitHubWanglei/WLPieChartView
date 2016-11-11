//
//  WLSlice.m
//
//  Created by wanglei on 16/11/2.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "WLSlice.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface WLSlice ()<CAAnimationDelegate>
#else
@interface WLSlice ()
#endif

@property (nonatomic, assign) CGFloat holeRadius;
@property (nonatomic, assign) CGFloat sliceSpace;
@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, strong) UIColor *sliceColor;
@property (nonatomic, assign) CGFloat interactionRadius;
@property (nonatomic, strong) void (^animationFinished)();

@end

@implementation WLSlice

+ (instancetype)sliceWithFrame:(CGRect)frame radius:(CGFloat)radius holeRadius:(CGFloat)holeRadius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle sliceColor:(UIColor *)sliceColor sliceSpace:(CGFloat)space animation:(BOOL)animation{
    if (holeRadius >= radius) {
        return nil;
    }
    return [[self alloc] initWithFrame:frame radius:radius holeRadius:holeRadius startAngle:startAngle endAngle:endAngle sliceColor:sliceColor sliceSpace:space animation:animation];
}

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius holeRadius:(CGFloat)holeRadius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle sliceColor:(UIColor *)sliceColor sliceSpace:(CGFloat)space animation:(BOOL)animation
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValue];
        _radius = radius;
        _holeRadius = holeRadius;
        _startAngle = startAngle;
        _endAngle = endAngle;
        _sliceColor = sliceColor;
        _sliceSpace = space <= 0 ? -1 : space;
        _interactionRadius = _radius;
        [self drawSliceWithAnimation:animation];
    }
    return self;
}

- (void)setDefaultValue{
    _animationDurationScale = 0.6;
    _selected = NO;
    _interactionSliceOffset = 0.0;
}

- (void)drawSliceWithAnimation:(BOOL)animation{
    self.backgroundColor = [UIColor clearColor];
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.frame = self.bounds;
    slice.path = [self creatSlicePath].CGPath;
    slice.fillColor = [UIColor clearColor].CGColor;
    slice.backgroundColor = [UIColor clearColor].CGColor;
    slice.strokeColor = self.sliceColor.CGColor;
    slice.lineWidth = _radius - _holeRadius;
    slice.strokeStart = 0;
    slice.strokeEnd = 0;
    slice.lineCap = @"butt";
    self.slice = slice;
    if (!animation) {
        slice.strokeEnd = 1;
        [self.layer addSublayer:self.slice];
    }
    if (_sliceSpace < 0) {
        return;
    }
    [self addMaskSliceWithSpace:_sliceSpace animation:NO];
}

- (UIBezierPath *)creatSlicePath{
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    return [UIBezierPath bezierPathWithArcCenter:center
                                          radius:_holeRadius + (_radius - _holeRadius) / 2
                                      startAngle:_startAngle
                                        endAngle:_endAngle
                                       clockwise:YES];
}

- (UIBezierPath *)creatNewSlicePathWithRadius:(CGFloat)newRadius{
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    return [UIBezierPath bezierPathWithArcCenter:center
                                          radius:_holeRadius + (newRadius - _holeRadius) / 2
                                      startAngle:_startAngle
                                        endAngle:_endAngle
                                       clockwise:YES];
}

- (void)addMaskSliceWithSpace:(CGFloat)sliceSpace animation:(BOOL)animation{
    _sliceSpace = sliceSpace;
    CGFloat offsetRadius = _sliceSpace / 2 / sinf((_endAngle - _startAngle) / 2.0);
    CGFloat offsetX = offsetRadius * cosf(_startAngle + (_endAngle - _startAngle) / 2.0);
    CGFloat offsetY = offsetRadius * sinf(_startAngle + (_endAngle - _startAngle) / 2.0);
    if (!animation) {
        CAShapeLayer *maskSlice = [self creatMaskSliceWithOffsetX:offsetX OffsetY:offsetY];
        _slice.mask = maskSlice;
    }else{
        CAShapeLayer *maskSlice = [self creatMaskSliceWithOffsetX:0 OffsetY:0];
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.keyPath = @"position";
        animation.duration = 1 / 3.0;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(maskSlice.bounds.size.width / 2, maskSlice.bounds.size.height / 2)];
        [path addLineToPoint:CGPointMake(offsetX + maskSlice.bounds.size.width / 2, offsetY + maskSlice.bounds.size.height / 2)];
        animation.path = path.CGPath;
        animation.autoreverses = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [maskSlice addAnimation:animation forKey:nil];
        _slice.mask = maskSlice;
    }
}

- (void)setMaskSliceWithSpace:(CGFloat)sliceSpace animation:(BOOL)animation{
    if (sliceSpace <= 0) {
        return;
    }
    CGFloat offsetRadius = sliceSpace / sinf((_endAngle - _startAngle) / 2.0);
    CGFloat offsetX = offsetRadius * cosf(_startAngle + (_endAngle - _startAngle) / 2.0);
    CGFloat offsetY = offsetRadius * sinf(_startAngle + (_endAngle - _startAngle) / 2.0);
    if (!_maskSlice) {
        [_maskSlice removeFromSuperlayer];
    }
    if (!animation) {
        _maskSlice = [self creatMaskSliceWithOffsetX:offsetX OffsetY:offsetY];
    }else{
        _maskSlice = [self creatMaskSliceWithOffsetX:0 OffsetY:0];
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.keyPath = @"position";
        animation.duration = 1 / 5.0;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(_maskSlice.bounds.size.width / 2, _maskSlice.bounds.size.height / 2)];
        [path addLineToPoint:CGPointMake(offsetX + _maskSlice.bounds.size.width / 2, offsetY + _maskSlice.bounds.size.height / 2)];
        animation.path = path.CGPath;
        animation.autoreverses = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [_maskSlice addAnimation:animation forKey:nil];
    }
    _slice.mask = _maskSlice;
}

- (void)setSliceNewRadius:(CGFloat)newRadius{
    if (newRadius <= 0) {
        return;
    }
    _interactionRadius = newRadius;
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.frame = self.bounds;
    slice.path = [self creatNewSlicePathWithRadius:newRadius].CGPath;
    slice.fillColor = [UIColor clearColor].CGColor;
    slice.backgroundColor = [UIColor clearColor].CGColor;
    slice.strokeColor = self.sliceColor.CGColor;
    slice.lineWidth = newRadius - _holeRadius;
    slice.strokeStart = 0;
    slice.strokeEnd = 1;
    slice.lineCap = @"butt";
    [self.layer insertSublayer:slice below:self.slice];
    [self.slice removeFromSuperlayer];
    self.slice = slice;
    if (_sliceSpace > 0) {
        CGFloat offsetRadius = _sliceSpace / 2 / sinf((_endAngle - _startAngle) / 2.0);
        CGFloat offsetX = offsetRadius * cosf(_startAngle + (_endAngle - _startAngle) / 2.0);
        CGFloat offsetY = offsetRadius * sinf(_startAngle + (_endAngle - _startAngle) / 2.0);
        CAShapeLayer *maskSlice = [CAShapeLayer layer];
        maskSlice.frame = CGRectMake(offsetX , offsetY, self.bounds.size.width, self.bounds.size.height);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(maskSlice.bounds.size.width / 2, maskSlice.bounds.size.height / 2)
                                                            radius:newRadius / 2
                                                        startAngle:_startAngle
                                                          endAngle:_endAngle
                                                         clockwise:YES];
        maskSlice.path = path.CGPath;
        maskSlice.fillColor = [UIColor clearColor].CGColor;
        maskSlice.backgroundColor = [UIColor clearColor].CGColor;
        maskSlice.strokeColor = [UIColor blackColor].CGColor;
        maskSlice.lineWidth = newRadius;
        maskSlice.strokeStart = 0;
        maskSlice.strokeEnd = 1;
        maskSlice.lineCap = @"butt";
        self.slice.mask = maskSlice;
    }
}

- (CAShapeLayer *)creatMaskSliceWithOffsetX:(CGFloat)offsetX OffsetY:(CGFloat)offsetY{
    CAShapeLayer *maskSlice = [CAShapeLayer layer];
    maskSlice.frame = CGRectMake(offsetX , offsetY, self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(maskSlice.bounds.size.width / 2, maskSlice.bounds.size.height / 2)
                                                        radius:_radius / 2
                                                    startAngle:_startAngle
                                                      endAngle:_endAngle
                                                     clockwise:YES];
    maskSlice.path = path.CGPath;
    maskSlice.fillColor = [UIColor clearColor].CGColor;
    maskSlice.backgroundColor = [UIColor clearColor].CGColor;
    maskSlice.strokeColor = [UIColor blackColor].CGColor;
    maskSlice.lineWidth = _radius;
    maskSlice.strokeStart = 0;
    maskSlice.strokeEnd = 1;
    maskSlice.lineCap = @"butt";
    return maskSlice;
}

- (void)performAnimationDelay:(NSTimeInterval)timeInterval{
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.duration = [self animationDuration];
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.keyPath = @"strokeEnd";
    animation.autoreverses = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.beginTime = timeInterval + CACurrentMediaTime();
    animation.delegate = self;
    [self.slice addAnimation:animation forKey:nil];
    [self.layer addSublayer:self.slice];
}

- (CGFloat)animationDuration{
    return (_endAngle - _startAngle) / (M_PI * 2) * _animationDurationScale;
}

- (void)animationDidFinished:(void (^)())animationFinished{
    _animationFinished = animationFinished;
}

- (void)setAnimationDurationScale:(CGFloat)animationDurationScale{
    if (animationDurationScale <= 0) {
        return;
    }
    _animationDurationScale = animationDurationScale;
}

- (void)setSelected:(BOOL)selected{
    _selected = selected;
    if (!_selected) {
        if (_maskSlice) {
            [_maskSlice removeFromSuperlayer];
        }
        
        if (_selectedStyle == WLSliceSelectedStyleDefault) {
            CAShapeLayer *slice = [CAShapeLayer layer];
            slice.frame = self.bounds;
            slice.path = [self creatSlicePath].CGPath;
            slice.fillColor = [UIColor clearColor].CGColor;
            slice.backgroundColor = [UIColor clearColor].CGColor;
            slice.strokeColor = self.sliceColor.CGColor;
            slice.lineWidth = _radius - _holeRadius;
            slice.strokeStart = 0;
            slice.strokeEnd = 1;
            slice.lineCap = @"butt";
            [self.layer insertSublayer:slice below:self.slice];
            [self.slice removeFromSuperlayer];
            self.slice = slice;
            if (_sliceSpace > 0) {
                [self addMaskSliceWithSpace:_sliceSpace animation:NO];
            }
        }else if (_selectedStyle == WLSliceSelectedStyleSpace){
            if (_sliceSpace > 0) {
                CGFloat offsetRadius = _sliceSpace / 2 / sinf((_endAngle - _startAngle) / 2.0);
                CGFloat offsetX = offsetRadius * cosf(_startAngle + (_endAngle - _startAngle) / 2.0);
                CGFloat offsetY = offsetRadius * sinf(_startAngle + (_endAngle - _startAngle) / 2.0);
                _maskSlice = [self creatMaskSliceWithOffsetX:offsetX OffsetY:offsetY];;
                _slice.mask = _maskSlice;
            }else{
                if (_maskSlice) {
                    [_maskSlice removeFromSuperlayer];
                }
            }
        }else{
            
        }
    }else{
        if (_selectedStyle == WLSliceSelectedStyleSpace && _sliceSpace > 0 && selected == YES) {
            CGFloat offsetRadius = (_sliceSpace / 2 + _selectedSpaceStyleSpace / 2) / sinf((_endAngle - _startAngle) / 2.0);
            CGFloat offsetX = offsetRadius * cosf(_startAngle + (_endAngle - _startAngle) / 2.0);
            CGFloat offsetY = offsetRadius * sinf(_startAngle + (_endAngle - _startAngle) / 2.0);
            _maskSlice = [self creatMaskSliceWithOffsetX:offsetX OffsetY:offsetY];;
            _slice.mask = _maskSlice;
        }
    }
}

-(UIBezierPath *)interactionSlicePath{
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:_interactionRadius + _interactionSliceOffset
                                                    startAngle:_startAngle
                                                      endAngle:_endAngle
                                                     clockwise:YES];
    [path addLineToPoint:center];
    [path closePath];
    return path;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (self.animationFinished) {
        self.animationFinished();
    }
}

@end














