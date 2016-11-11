//
//  WLSlice.h
//
//  Created by wanglei on 16/11/2.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, WLSliceSelectedStyle) {
    WLSliceSelectedStyleDefault,
    WLSliceSelectedStyleSpace,
    WLSliceSelectedStyleOffset,
};

@interface WLSlice : UIView

/**
 相对于1S的动画时间比例, 数值越大, 动画持续时间越长, 默认为0.6
 */
@property (nonatomic, assign) CGFloat animationDurationScale;
@property (nonatomic, assign, readonly) CGFloat animationDuration; //动画持续时间
@property (nonatomic, strong) CAShapeLayer *slice;
@property (nonatomic, strong) CAShapeLayer *maskSlice;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) WLSliceSelectedStyle selectedStyle;
@property (nonatomic, assign) CGFloat selectedSpaceStyleSpace;
@property (nonatomic, strong) UIBezierPath *interactionSlicePath;
@property (nonatomic, assign) CGFloat interactionSliceOffset;

+ (instancetype)sliceWithFrame:(CGRect)frame
                        radius:(CGFloat)radius
                    holeRadius:(CGFloat)holeRadius
                    startAngle:(CGFloat)startAngle
                      endAngle:(CGFloat)endAngle
                    sliceColor:(UIColor *)sliceColor
                    sliceSpace:(CGFloat)space
                     animation:(BOOL)animation;

- (void)setMaskSliceWithSpace:(CGFloat)sliceSpace animation:(BOOL)animation;
- (void)setSliceNewRadius:(CGFloat)newRadius;
- (CAShapeLayer *)creatMaskSliceWithOffsetX:(CGFloat)offsetX OffsetY:(CGFloat)offsetY;

- (void)performAnimationDelay:(NSTimeInterval)timeInterval; //延迟执行动画的方法
- (void)animationDidFinished:(void (^)())animationFinished; //动画完成后的回调

@end

















