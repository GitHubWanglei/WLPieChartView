//
//  WLPieChartView.h
//
//  Created by wanglei on 16/11/1.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLSlice.h"

@interface WLPieChartView : UIView

#pragma mark - Slice
/**
 每块区域的百分比(0.0 ~ 1.0), 例如: @[@(0.3),@(0.4),@(0.2),@(0.1)]
 */
@property (nonatomic, strong) NSMutableArray<NSNumber *> *sliceScales;
@property (nonatomic, strong) NSMutableArray<UIColor *> *sliceColors;
@property (nonatomic, assign, readonly) CGFloat radius;    //半径为frame宽和高最大值的一半
@property (nonatomic, assign) CGFloat sliceSpace;          //slice 之间的距离(0.0 ~ 5.0)
@property (nonatomic, assign) CGFloat startAngle;          //第一个slice开始绘制的位置, 默认为 -M_PI / 2
@property (nonatomic, assign) CGFloat animationDuration;   //绘制动画持续时间(默认0.6s), 有动画时才有效

#pragma mark - Title
@property (nonatomic, assign) BOOL showTitlesInslices;                    //是否显示区块上的标题
@property (nonatomic, strong) NSMutableArray<NSString *> *titlesInSlices; //区块上的标题
@property (nonatomic, strong) UIFont *titleFontInSlice;     //区块上的标题字体
@property (nonatomic, strong) UIColor *titleColorInSlice;   //区块上的标题颜色
@property (nonatomic, assign) CGFloat titleInSliceOffsetPercentage;            //区块上的标题位置, 默认0.6
@property (nonatomic, strong) NSMutableArray<NSString *> *titlesOutsideSlices; //区块外的标题(折线上的标题)
@property (nonatomic, strong) UIFont *titleFontOutsideSlice;         //区块外的标题字体
@property (nonatomic, strong) UIColor *titleColorOutSideSlice;       //区块外的标题颜色
@property (nonatomic, assign) BOOL titleOutsideSliceOnLinePart2Top;  //区块外标题是否在第二段折线上面, 默认 NO
@property (nonatomic, assign) CGFloat titleOutsideSliceOffsetToLine; //区块外标题相对于折线的偏移量, 标题在折线上方时无效

#pragma mark - Line
@property (nonatomic, assign) BOOL showLinesAndTitlesOutSideSlice; //是否显示折线和区块外标题, 默认 YES
/**
 折线中第一段起始位置和圆心之间的距离占半径的比例, 数值越大, 折线起始位置距离圆心越远, 默认0.8
 */
@property (nonatomic, assign) CGFloat linePart1OffsetPercentage;
@property (nonatomic, assign) CGFloat linePart1Length;  //第一段折线长度
@property (nonatomic, assign) CGFloat linePart1Width;   //第一段折线宽度
@property (nonatomic, strong) UIColor *linePart1Color;  //第一段折线颜色
@property (nonatomic, assign) CGFloat linePart2Length;  //第二段折线长度
@property (nonatomic, assign) CGFloat linePart2Width;   //第二段折线宽度
@property (nonatomic, strong) UIColor *linePart2Color;  //第二段折线颜色

#pragma mark - Hole
@property (nonatomic, assign) BOOL showHoleView;            //是否显示中间的空心view(背景透明), 默认不显示
@property (nonatomic, assign) CGFloat holeRadiusPercentage; //半径占比
@property (nonatomic, strong) NSString *holeTitle;          //标题
@property (nonatomic, strong) UIFont *holeTitleFont;        //标题颜色
@property (nonatomic, strong) UIColor *holeTitleColor;      //标题字体

#pragma mark - User interaction
@property (nonatomic, assign) BOOL selectedEnable;                //是否可以选中, 默认 YES
@property (nonatomic, assign) WLSliceSelectedStyle selectedStyle; //选中样式
@property (nonatomic, assign) NSInteger selectedIndex;            //设置某个slice的初始状态为选中状态
@property (nonatomic, assign) CGFloat selectedDefaultStyleNewRadius;
@property (nonatomic, assign) CGFloat selectedSpaceStyleSpace;
@property (nonatomic, assign) CGFloat selectedOffsetStyleOffset;
@property (nonatomic, assign) BOOL selectedSpaceStyleAnimation;
@property (nonatomic, assign) BOOL selectedOffsetStyleAnimation;

#pragma mark - Draw method
- (void)drawChartWithAnimation:(BOOL)animation;    //开始绘制
- (void)refreshChartWithAnimation:(BOOL)animation; //刷新重绘

/**
 点击某个 slice 的回调
 */
- (void)didClickSlice:(void (^)(WLSlice *slice,NSInteger index))selectedHandler;

#pragma mark - Othre method
/**
 根据设置的区块比例阈值(0.0 ~ 1.0), 将区块内标题进行自适应, 如果小于此阈值, 区块内标题将转换为区块外标题
 调用此方法, 区块外设置的标题将不会显示
 @param threshold 阈值
 */
- (void)adjustLayoutTitlesAndLinesWithThresholdScale:(CGFloat)threshold;

/**
 添加自定义区块外 TitleView
 
 @param views  自定义 view 数组
 @param sizes  自定义 view 的 size
 @param offset 自定义 view 与折线第二段之间的间距
 */
- (void)addCustomTitleViewsOutsideSliceWithViews:(NSMutableArray<UIView *> *)views
                                           sizes:(NSMutableArray<NSString *> *)sizes
                                    offsetToLine:(CGFloat)offset;

/**
 动画完成后的回调, 有动画效果时才会回调
 */
- (void)animationDidFinished:(void (^)())completion;

@end






