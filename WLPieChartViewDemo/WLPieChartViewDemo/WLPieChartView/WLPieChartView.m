//
//  WLPieChartView.m
//
//  Created by wanglei on 16/11/1.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "WLPieChartView.h"

#define COLOR_RANDOM [UIColor colorWithRed:(arc4random() % 255) / 255.0 green:(arc4random() % 255) / 255.0 blue:(arc4random() % 255) / 255.0 alpha:1]
#define SLICE_TAG 1000000

@interface WLPieChartView ()
@property (nonatomic, strong) NSMutableArray *startAngles;
@property (nonatomic, strong) NSMutableArray *endAngles;
@property (nonatomic, assign) CGFloat threshold;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSMutableArray *customTitleViewsOustsideSlice;
@property (nonatomic, strong) NSMutableArray *customTitleViewsOustsideSliceSizes;
@property (nonatomic, assign) CGFloat customTitleViewsOffsetToLinePart2;
@property (nonatomic, strong) void (^animationFinished)();
@property (nonatomic, strong) void (^selectedHandler)(WLSlice *slice,NSInteger index);
@end

@implementation WLPieChartView

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self setDefaultValue];
}

- (void)setDefaultValue{
    _startAngle = -M_PI / 2;
    _threshold = -1;
    _sliceSpace = -1;
    _radius = (self.frame.size.width > self.frame.size.height) ? (self.frame.size.height / 2) : (self.frame.size.width / 2);
    _animationDuration = 0.6;
    
    _showTitlesInslices = YES;
    _titleFontInSlice = [UIFont systemFontOfSize:10];
    _titleColorInSlice = [UIColor blackColor];
    _titleInSliceOffsetPercentage = 0.6;
    _titleFontOutsideSlice = [UIFont systemFontOfSize:10];
    _titleColorOutSideSlice = [UIColor blackColor];
    _titleOutsideSliceOnLinePart2Top = NO;
    _titleOutsideSliceOffsetToLine = 3;
    
    _showLinesAndTitlesOutSideSlice = YES;
    _linePart1OffsetPercentage = 0.8;
    _linePart1Length = _radius * (1 - _linePart1OffsetPercentage) + 15;
    _linePart1Width = 1;
    _linePart1Color = [UIColor blackColor];
    _linePart2Length = 15;
    _linePart2Width = 1;
    _linePart2Color = [UIColor blackColor];
    
    _showHoleView = NO;
    _holeRadiusPercentage = 0.4;
    _holeTitle = @"HOLE";
    _holeTitleColor = [UIColor blackColor];
    _holeTitleFont = [UIFont systemFontOfSize:10];
    
    _customTitleViewsOffsetToLinePart2 = 3;
    
    _selectedEnable = YES;
    _selectedStyle = WLSliceSelectedStyleDefault;
    _selectedIndex = -1;
    _selectedDefaultStyleNewRadius = _radius + 10;
    _selectedSpaceStyleSpace = 5;
    _selectedOffsetStyleOffset = 5;
    _selectedSpaceStyleAnimation = YES;
    _selectedOffsetStyleAnimation = YES;
}

#pragma mark - Draw method

- (void)drawChartWithAnimation:(BOOL)animation{
    if (self.sliceScales.count == 0) {
        return;
    }
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    _contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:_contentView];
    [self setAngles];
    
    if (_showHoleView) {
        [self addHoleTitle];
    }
    
    CGFloat duration = 0.0;
    if (_sliceColors.count < _sliceScales.count) {
        _sliceColors = [NSMutableArray array];
        for (NSInteger i = 0; i < _sliceScales.count; i++) {
            [_sliceColors addObject:COLOR_RANDOM];
        }
    }
    CGFloat holeRadius = _showHoleView ? _radius * _holeRadiusPercentage : 0;
    for (int i = 0; i < _sliceScales.count; i++) {
        WLSlice *slice;
        if (_selectedIndex == i) {
            if (_selectedStyle == WLSliceSelectedStyleDefault) {
                slice = [WLSlice sliceWithFrame:_contentView.bounds
                                         radius:_selectedDefaultStyleNewRadius
                                     holeRadius:holeRadius
                                     startAngle:[_startAngles[i] floatValue]
                                       endAngle:[_endAngles[i] floatValue]
                                     sliceColor:_sliceColors[i]
                                     sliceSpace:_sliceSpace
                                      animation:animation];
                slice.radius = _radius;
            }else if (_selectedStyle == WLSliceSelectedStyleSpace){
                slice = [WLSlice sliceWithFrame:_contentView.bounds
                                         radius:_radius
                                     holeRadius:holeRadius
                                     startAngle:[_startAngles[i] floatValue]
                                       endAngle:[_endAngles[i] floatValue]
                                     sliceColor:_sliceColors[i]
                                     sliceSpace:_sliceSpace
                                      animation:animation];
                [slice setMaskSliceWithSpace:_selectedSpaceStyleSpace animation:NO];
            }else{
                slice = [WLSlice sliceWithFrame:_contentView.bounds
                                         radius:_radius
                                     holeRadius:holeRadius
                                     startAngle:[_startAngles[i] floatValue]
                                       endAngle:[_endAngles[i] floatValue]
                                     sliceColor:_sliceColors[i]
                                     sliceSpace:_sliceSpace
                                      animation:animation];
                if (!slice.selected) {
                    CGFloat startAngle = [_startAngles[i] floatValue];
                    CGFloat endAngle = [_endAngles[i] floatValue];
                    CGFloat offsetRadius = _selectedOffsetStyleOffset / sinf((endAngle - startAngle) / 2.0);
                    CGFloat offsetX = offsetRadius * cosf(startAngle + (endAngle - startAngle) / 2.0);
                    CGFloat offsetY = offsetRadius * sinf(startAngle + (endAngle - startAngle) / 2.0);
                    if (!animation) {
                        slice.center = CGPointMake(slice.center.x + offsetX, slice.center.y + offsetY);
                    }else{
                        [UIView animateWithDuration:1 / 5.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            slice.center = CGPointMake(slice.center.x + offsetX, slice.center.y + offsetY);
                        } completion:nil];
                    }
                    slice.selected = YES;
                    slice.interactionSliceOffset = offsetRadius;
                }else{
                    slice.selected = NO;
                    slice.frame = CGRectMake(0, 0, slice.bounds.size.width, slice.bounds.size.height);
                }
            }
            slice.selected = YES;
        }else{
            slice = [WLSlice sliceWithFrame:_contentView.bounds
                                     radius:_radius
                                 holeRadius:holeRadius
                                 startAngle:[_startAngles[i] floatValue]
                                   endAngle:[_endAngles[i] floatValue]
                                 sliceColor:_sliceColors[i]
                                 sliceSpace:_sliceSpace
                                  animation:animation];
        }
        slice.selectedStyle = _selectedStyle;
        slice.selectedSpaceStyleSpace = _selectedSpaceStyleSpace;
        slice.tag = SLICE_TAG + i;
        [_contentView addSubview:slice];
        if (animation == NO) { // add lines and titles
            [self addLinesAndTitleWithSlice:slice Index:i view:self];
            continue;
        }
        
        // perform animation
        slice.animationDurationScale = _animationDuration;
        __block __weak typeof(self) weakSelf = self;
        [slice animationDidFinished:^{
            // add lines and titles
            [weakSelf addLinesAndTitleWithSlice:slice Index:i view:weakSelf];
            if (i == _sliceScales.count - 1 && _animationFinished) {
                weakSelf.animationFinished();
            }
        }];
        
        // perform next animation
        if (slice.tag == SLICE_TAG) {
            [slice performAnimationDelay:0];
            continue;
        }
        WLSlice *tempSlice = [self viewWithTag:slice.tag - 1];
        duration += tempSlice.animationDuration;
        [slice performAnimationDelay:duration];
    }
}

- (void)refreshChartWithAnimation:(BOOL)animation{
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    [self drawChartWithAnimation:animation];
}

#pragma mark - Add lines and titles

- (void)addLinesAndTitleWithSlice:(WLSlice *)slice Index:(NSInteger)i view:(WLPieChartView *)weakSelf{
    NSString *titleInSlice;
    NSString *titleOutSlice;
    if (_titlesInSlices.count > 0) {
        //fault tolerant
        if (_titlesInSlices.count < _sliceScales.count) {
            for (NSInteger i = _titlesInSlices.count; i < _sliceScales.count; i++) {
                [_titlesInSlices addObject:@""];
            }
        }
        titleInSlice = _titlesInSlices[i];
    }
    if (_titlesOutsideSlices.count > 0) {
        //fault tolerant
        if (_titlesOutsideSlices.count < _sliceScales.count) {
            for (NSInteger i = _titlesOutsideSlices.count; i < _sliceScales.count; i++) {
                [_titlesOutsideSlices addObject:@""];
            }
        }
        titleOutSlice = _titlesOutsideSlices[i];
    }
    
    CGFloat angle = [_endAngles[i] floatValue] - ([_endAngles[i] floatValue] - [_startAngles[i] floatValue]) / 2;
    CGPoint center = CGPointMake(weakSelf.bounds.size.width / 2, weakSelf.bounds.size.height / 2);
    if (_threshold < 0) { // normal layout
        // add label in slice
        if (_showTitlesInslices && _titlesInSlices.count > 0) {
            CGPoint label_center = [weakSelf pointWithCenter:center radius:_radius * _titleInSliceOffsetPercentage angle:angle];
            if (_titlesInSlices.count > 0) {
                [weakSelf addTitleInSliceWithTitle:titleInSlice labelCenter:label_center index:i];
            }
        }
        // add lalel outside slice
        if (_showLinesAndTitlesOutSideSlice && _titlesOutsideSlices.count > 0) {
            [weakSelf addTitleOutSliceWithTitle:titleOutSlice Angle:angle center:center view:weakSelf index:i];
        }else if (_customTitleViewsOustsideSlice > 0){
            UIView *titleView = _customTitleViewsOustsideSlice[i];
            CGSize size = CGSizeFromString(_customTitleViewsOustsideSliceSizes[i]);
            [weakSelf addCustomTitleViewsOutSliceWithView:titleView size:size Angle:angle center:center view:weakSelf index:i];
        }
    }else{ // adjust layout
        titleOutSlice = titleInSlice;
        if (([_sliceScales[i] floatValue] > _threshold) && _titlesInSlices.count > 0) {
            // add label in slice
            if (_showTitlesInslices) {
                CGPoint label_center = [weakSelf pointWithCenter:center radius:_radius * _titleInSliceOffsetPercentage angle:angle];
                if (_titlesInSlices.count > 0) {
                    [weakSelf addTitleInSliceWithTitle:titleInSlice labelCenter:label_center index:i];
                }
            }
        }else{
            // add lalel outside slice
            if (_showLinesAndTitlesOutSideSlice && _titlesOutsideSlices.count > 0) {
                [weakSelf addTitleOutSliceWithTitle:titleOutSlice Angle:angle center:center view:weakSelf index:i];
            }
        }
    }
}

- (void)addTitleOutSliceWithTitle:(NSString *)titleOutSlice Angle:(CGFloat)angle center:(CGPoint)center view:(WLPieChartView *)weakSelf  index:(NSInteger)index{
    // add line part 1
    CGPoint linePart1_startPoint = [weakSelf pointWithCenter:center radius:_radius * _linePart1OffsetPercentage angle:angle];
    CGFloat offsetX = _linePart1Length * cos(angle);
    CGFloat offsetY = _linePart1Length * sin(angle);
    CGPoint linePart1_endPoint = CGPointMake(linePart1_startPoint.x + offsetX, linePart1_startPoint.y + offsetY);
    [weakSelf addLineWithStartPoint:linePart1_startPoint endPointPoint:linePart1_endPoint lineColor:_linePart1Color lineWidth:_linePart1Width index:index];
    // add line part 2
    BOOL toLeft = YES;
    if (linePart1_endPoint.x >= self.frame.size.width / 2) {
        toLeft = NO;
    }
    if (_titleOutsideSliceOnLinePart2Top) {
        CGRect rect = [titleOutSlice boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: _titleFontOutsideSlice} context:nil];
        _linePart2Length = rect.size.width;
    }
    CGFloat linePart2_endPointX = toLeft ? linePart1_endPoint.x - _linePart2Length : linePart1_endPoint.x + _linePart2Length;
    CGPoint linePart2_endPoint = CGPointMake(linePart2_endPointX, linePart1_endPoint.y);
    [weakSelf addLineWithStartPoint:linePart1_endPoint endPointPoint:linePart2_endPoint lineColor:_linePart2Color lineWidth:_linePart2Width index:index];
    // add title on line part 2
    CGRect rect = [titleOutSlice boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: _titleFontOutsideSlice} context:nil];
    CGFloat titleOutside_centerPointX = toLeft ? linePart2_endPoint.x - rect.size.width / 2 - _titleOutsideSliceOffsetToLine : linePart2_endPoint.x + rect.size.width / 2 + _titleOutsideSliceOffsetToLine;
    CGFloat titleOutsideOffset = toLeft ? -_linePart2Length / 2 : _linePart2Length / 2;
    titleOutside_centerPointX = _titleOutsideSliceOnLinePart2Top ? linePart1_endPoint.x + titleOutsideOffset : titleOutside_centerPointX;
    CGFloat titleOutside_centerPointY = _titleOutsideSliceOnLinePart2Top ? linePart2_endPoint.y - rect.size.height / 2 : linePart2_endPoint.y;
    CGPoint titleOutside_centerPoint = CGPointMake(titleOutside_centerPointX, titleOutside_centerPointY);
    [weakSelf addTitleOutsideSliceWithTitle:titleOutSlice labelCenter:titleOutside_centerPoint index:index];
}

- (void)addCustomTitleViewsOutSliceWithView:(UIView *)titleView size:(CGSize)size Angle:(CGFloat)angle center:(CGPoint)center view:(WLPieChartView *)weakSelf index:(NSInteger)index{
    // add line part 1
    CGPoint linePart1_startPoint = [weakSelf pointWithCenter:center radius:_radius * _linePart1OffsetPercentage angle:angle];
    CGFloat offsetX = _linePart1Length * cos(angle);
    CGFloat offsetY = _linePart1Length * sin(angle);
    CGPoint linePart1_endPoint = CGPointMake(linePart1_startPoint.x + offsetX, linePart1_startPoint.y + offsetY);
    [weakSelf addLineWithStartPoint:linePart1_startPoint endPointPoint:linePart1_endPoint lineColor:_linePart1Color lineWidth:_linePart1Width index:index];
    // add line part 2
    BOOL toLeft = YES;
    if (linePart1_endPoint.x >= self.frame.size.width / 2) {
        toLeft = NO;
    }
    if (_titleOutsideSliceOnLinePart2Top) {
        _linePart2Length = size.width;
    }
    CGFloat linePart2_endPointX = toLeft ? linePart1_endPoint.x - _linePart2Length : linePart1_endPoint.x + _linePart2Length;
    CGPoint linePart2_endPoint = CGPointMake(linePart2_endPointX, linePart1_endPoint.y);
    [weakSelf addLineWithStartPoint:linePart1_endPoint endPointPoint:linePart2_endPoint lineColor:_linePart2Color lineWidth:_linePart2Width index:index];
    // add custom title view on line part 2
    CGFloat titleOutside_centerPointX = toLeft ? linePart2_endPoint.x - size.width / 2 - _customTitleViewsOffsetToLinePart2 : linePart2_endPoint.x + size.width / 2 + _customTitleViewsOffsetToLinePart2;
    CGFloat titleOutsideOffset = toLeft ? -_linePart2Length / 2 : _linePart2Length / 2;
    titleOutside_centerPointX = _titleOutsideSliceOnLinePart2Top ? linePart1_endPoint.x + titleOutsideOffset : titleOutside_centerPointX;
    CGFloat titleOutside_centerPointY = _titleOutsideSliceOnLinePart2Top ? linePart2_endPoint.y - size.height / 2 : linePart2_endPoint.y;
    CGPoint customTitleViewOutside_centerPoint = CGPointMake(titleOutside_centerPointX, titleOutside_centerPointY);
    [weakSelf addCustomTitleViewOutsideSliceWithView:titleView size:size Center:customTitleViewOutside_centerPoint index:index];
}

- (void)addTitleInSliceWithTitle:(NSString *)title labelCenter:(CGPoint)center index:(NSInteger)index{
    CGRect rect = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: _titleFontInSlice} context:nil];
    UILabel *title_label = [[UILabel alloc] initWithFrame:rect];
    title_label.center = center;
    title_label.text = title;
    title_label.font = _titleFontInSlice;
    title_label.textColor = _titleColorInSlice;
    title_label.textAlignment = NSTextAlignmentCenter;
    title_label.backgroundColor = [UIColor clearColor];
    [[_contentView viewWithTag:SLICE_TAG + index] addSubview:title_label];
}

- (void)addTitleOutsideSliceWithTitle:(NSString *)title labelCenter:(CGPoint)center index:(NSInteger)index{
    CGRect rect = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: _titleFontOutsideSlice} context:nil];
    UILabel *title_label = [[UILabel alloc] initWithFrame:rect];
    title_label.center = center;
    title_label.text = title;
    title_label.font = _titleFontOutsideSlice;
    title_label.textColor = _titleColorOutSideSlice;
    title_label.textAlignment = NSTextAlignmentCenter;
    title_label.backgroundColor = [UIColor clearColor];
    [[_contentView viewWithTag:SLICE_TAG + index] addSubview:title_label];
}

- (void)addCustomTitleViewOutsideSliceWithView:(UIView *)titleView size:(CGSize)size Center:(CGPoint)center index:(NSInteger)index{
    titleView.frame = CGRectMake(0, 0, size.width, size.height);
    titleView.center = center;
    [[_contentView viewWithTag:SLICE_TAG + index] addSubview:titleView];
}

- (void)addLineWithStartPoint:(CGPoint)startPoint endPointPoint:(CGPoint)endPoint lineColor:(UIColor *)color lineWidth:(CGFloat)width index:(NSInteger)index{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    
    CAShapeLayer *line = [CAShapeLayer layer];
    line.path = path.CGPath;
    line.fillColor = [UIColor clearColor].CGColor;
    line.backgroundColor = [UIColor clearColor].CGColor;
    line.strokeColor = color.CGColor;
    line.lineWidth = width;
    line.strokeStart = 0;
    line.strokeEnd = 1;
    line.lineCap = @"round";
    
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = line.frame;
    lineView.backgroundColor = [UIColor clearColor];
    [lineView.layer addSublayer:line];
    [[_contentView viewWithTag:SLICE_TAG + index ] addSubview:lineView];
}

#pragma mark - Add hole title

- (void)addHoleTitle{
    if (!_holeTitle.length) {
        return;
    }
    CGRect rect = [_holeTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: _holeTitleFont} context:nil];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];;
    label.center = CGPointMake(_contentView.bounds.size.width / 2, _contentView.bounds.size.height / 2);
    label.text = _holeTitle;
    label.textColor = _holeTitleColor;
    label.font = _holeTitleFont;
    [_contentView addSubview:label];
}

#pragma mark - User interaction method

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_selectedEnable) {
        return;
    }
    CGPoint point = [[touches anyObject] locationInView:self];
    for (NSInteger i = 0; i < _sliceScales.count; i++) {
        WLSlice *slice = [self viewWithTag:SLICE_TAG + i];
        if ([slice.interactionSlicePath containsPoint:point]) {
            if (self.selectedHandler != nil) {
                self.selectedHandler(slice, i);
            }
            [self makeSliceSelectedWithIndex:i style:_selectedStyle];
        }
    }
}

- (void)makeSliceSelectedWithIndex:(NSInteger)index style:(WLSliceSelectedStyle)style{
    switch (_selectedStyle) {
        case WLSliceSelectedStyleDefault:
        {
            [self setSliceNewRadius:_selectedDefaultStyleNewRadius index:index];
        }
            break;
        case WLSliceSelectedStyleSpace:
        {
            [self setMaskSliceWithSpace:_selectedSpaceStyleSpace index:index animation:_selectedSpaceStyleAnimation];
        }
            break;
        case WLSliceSelectedStyleOffset:
        {
            [self setSliceOffset:_selectedOffsetStyleOffset index:index animation:_selectedOffsetStyleAnimation];
        }
            break;
        default:
            break;
    }
}

// Default style
- (void)setSliceNewRadius:(CGFloat)newRadius index:(NSInteger)index{
    WLSlice *slice = [self viewWithTag:SLICE_TAG + index];
    [self setSliceToNormalStatusWithOutIndex:index];
    if (!slice.selected) {
        [slice setSliceNewRadius:newRadius];
        slice.selected = YES;
    }else{
        slice.selected = NO;
    }
}

// Space style
- (void)setMaskSliceWithSpace:(CGFloat)sliceSpace index:(NSInteger)index animation:(BOOL)animation{
    WLSlice *slice = [self viewWithTag:SLICE_TAG + index];
    [self setSliceToNormalStatusWithOutIndex:index];
    if (!slice.selected) {
        if (_sliceSpace > 0) {
            slice.selected = YES;
        }else{
            [slice setMaskSliceWithSpace:sliceSpace animation:animation];
            slice.selected = YES;
        }
    }else{
        slice.selected = NO;
    }
}

// Offseet style
- (void)setSliceOffset:(CGFloat)offset index:(NSInteger)index animation:(BOOL)animation{
    WLSlice *slice = [self viewWithTag:SLICE_TAG + index];
    [self setSliceToNormalStatusWithOutIndex:index];
    if (!slice.selected) {
        CGFloat startAngle = [_startAngles[index] floatValue];
        CGFloat endAngle = [_endAngles[index] floatValue];
        CGFloat offsetRadius = offset / sinf((endAngle - startAngle) / 2.0);
        CGFloat offsetX = offsetRadius * cosf(startAngle + (endAngle - startAngle) / 2.0);
        CGFloat offsetY = offsetRadius * sinf(startAngle + (endAngle - startAngle) / 2.0);
        if (!animation) {
            slice.center = CGPointMake(slice.center.x + offsetX, slice.center.y + offsetY);
        }else{
            [UIView animateWithDuration:1 / 5.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                slice.center = CGPointMake(slice.center.x + offsetX, slice.center.y + offsetY);
            } completion:nil];
        }
        slice.selected = YES;
        slice.interactionSliceOffset = offsetRadius;
    }else{
        slice.selected = NO;
        slice.interactionSliceOffset = 0.0;
        slice.frame = CGRectMake(0, 0, slice.bounds.size.width, slice.bounds.size.height);
    }
}

// Set other slice to normal status
- (void)setSliceToNormalStatusWithOutIndex:(NSInteger)index{
    for (NSInteger i = 0; i < _sliceScales.count; i++) {
        if (i != index) {
            WLSlice *slice = [self viewWithTag:SLICE_TAG + i];
            if (slice.selected) {
                slice.selected = NO;
                if (_sliceSpace > 0) {
                    switch (_selectedStyle) {
                        case WLSliceSelectedStyleDefault:
                        {
                            [slice setMaskSliceWithSpace:_sliceSpace / 2 animation:NO];
                        }
                            break;
                        case WLSliceSelectedStyleSpace:
                        {
                            [slice setMaskSliceWithSpace:_sliceSpace / 2 animation:NO];
                        }
                            break;
                        case WLSliceSelectedStyleOffset:
                        {
                            CGFloat startAngle = [_startAngles[i] floatValue];
                            CGFloat endAngle = [_endAngles[i] floatValue];
                            CGFloat offsetRadius = -_selectedOffsetStyleOffset / sinf((endAngle - startAngle) / 2.0);
                            CGFloat offsetX = offsetRadius * cosf(startAngle + (endAngle - startAngle) / 2.0);
                            CGFloat offsetY = offsetRadius * sinf(startAngle + (endAngle - startAngle) / 2.0);
                            slice.center = CGPointMake(slice.center.x + offsetX, slice.center.y + offsetY);
                            slice.interactionSliceOffset = 0.0;
                        }
                            break;
                        default:
                            break;
                    }
                }else{
                    slice.frame = CGRectMake(0, 0, slice.bounds.size.width, slice.bounds.size.height);
                }
            }
        }
    }
}

#pragma mark - Click slice callback

- (void)didClickSlice:(void (^)(WLSlice *slice,NSInteger index))selectedHandler{
    _selectedHandler = selectedHandler;
}

#pragma mark - Adjust titles position method

- (void)adjustLayoutTitlesAndLinesWithThresholdScale:(CGFloat)threshold{
    _threshold = (threshold > 1.0) ? 1.0 : threshold;
    _threshold = (threshold < 0.0) ? 0.0 : threshold;
}

#pragma mark - Add custom title views

- (void)addCustomTitleViewsOutsideSliceWithViews:(NSMutableArray<UIView *> *)views sizes:(NSMutableArray<NSString *> *)sizes offsetToLine:(CGFloat)offset{
    if (views.count < _sliceScales.count || sizes.count < _sliceScales.count) {
        return;
    }
    _showLinesAndTitlesOutSideSlice = NO;
    _customTitleViewsOustsideSlice = [NSMutableArray arrayWithArray:views];
    _customTitleViewsOustsideSliceSizes = [NSMutableArray arrayWithArray:sizes];
    _customTitleViewsOffsetToLinePart2 = offset > 0 ? offset : 3;
}

#pragma mark - Animation finished callback

- (void)animationDidFinished:(void (^)())completion{
    _animationFinished = completion;
}

#pragma mark - Setter
- (void)setSliceSpace:(CGFloat)sliceSpace{
    _sliceSpace = (sliceSpace <= 0.0) ? -1 : sliceSpace;
}

- (void)setTitleInSliceOffsetPercentage:(CGFloat)titleInSliceOffsetPercentage{
    _titleInSliceOffsetPercentage = (titleInSliceOffsetPercentage > 1) ? 0.6 : titleInSliceOffsetPercentage;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    _selectedIndex = (selectedIndex >= 0 && selectedIndex < _sliceScales.count) ? selectedIndex : -1;
}

- (void)setSelectedDefaultStyleNewRadius:(CGFloat)selectedDefaultStyleNewRadius{
    _selectedDefaultStyleNewRadius = (selectedDefaultStyleNewRadius <= _radius ) ? _radius + 10 : selectedDefaultStyleNewRadius;
}

- (void)setSelectedSpaceStyleSpace:(CGFloat)selectedSpaceStyleSpace{
    _selectedSpaceStyleSpace = (selectedSpaceStyleSpace <= 0.0) ? 5 : selectedSpaceStyleSpace;
}

- (void)setSelectedOffsetStyleOffset:(CGFloat)selectedOffsetStyleOffset{
    _selectedOffsetStyleOffset = (selectedOffsetStyleOffset <= 0.0) ? 5 : selectedOffsetStyleOffset;
}

#pragma mark - Other method

- (void)setAngles{
    CGFloat cirlceAngle = M_PI * 2;
    NSMutableArray *startAngles = [NSMutableArray array];
    NSMutableArray *endAngles = [NSMutableArray array];
    CGFloat tempStartAngle = _startAngle;
    CGFloat tempEndAngle = _startAngle;
    for (int i = 0; i < _sliceScales.count; i++) {
        CGFloat startAngle;
        if (i == 0) {
            startAngle = tempStartAngle;
        }else{
            tempStartAngle += cirlceAngle * [_sliceScales[i - 1] floatValue];
            startAngle = tempStartAngle;
        }
        tempEndAngle += cirlceAngle * [_sliceScales[i] floatValue];
        [startAngles addObject:@(startAngle)];
        [endAngles addObject:@(tempEndAngle)];
    }
    _startAngles = startAngles;
    _endAngles = endAngles;
}

- (CGPoint)pointWithCenter:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle{
    CGFloat x = radius * cos(angle);
    CGFloat y = radius * sin(angle);
    return CGPointMake(x + center.x, y + center.y);
}

@end














