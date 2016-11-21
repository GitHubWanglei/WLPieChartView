//
//  ViewController.m
//  WLPieChartViewDemo
//
//  Created by wanglei on 16/11/10.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "ViewController.h"
#import "WLPieChartView.h"

#define UIColorFromHexValue(HexValue)                               \
[UIColor colorWithRed:((float)((HexValue & 0xFF0000) >> 16))/255.0  \
green:((float)((HexValue & 0xFF00) >> 8))/255.0                     \
blue:((float)(HexValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController ()
@property (nonatomic, strong) WLPieChartView *pieChart;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addRefreshBtn];
    
    // 基本设置
    WLPieChartView *pieChart = [[WLPieChartView alloc] initWithFrame:CGRectMake(0, 0, 160, 140)];
    self.pieChart = pieChart;
    pieChart.center = self.view.center;
    pieChart.sliceScales = [NSMutableArray arrayWithArray:@[@(0.23), @(0.07), @(0.35), @(0.2), @(0.15)]];
    
    //动画时间
    [self setAnimationDuradion];
    
    //设置起始位置
    [self setStartAngle];
    
    //设置内标题自适应
//    [pieChart adjustLayoutTitlesAndLinesWithThresholdScale:0.1];
    
    //设置区块间距
    [self setSliceSpace];
    
    //设置初始化时选中的区块
    [self setInitialSelectedSlice];
    
    //设置区块颜色
    [self setSliceColor];
    
    //设置区块内标题
    [self addTitleInSlice];
    
    //设置折线及外标题
    [self addLinesAndTitleOutSlice];
    
    //设置中间圆孔
    [self addHole];
    
    //设置自定义区块外标题
    [self addCustomTitleViewOutSlice];
    
    //设置交互效果
    [self addInteractionStyle];
    
    //设置点击回调
    [self setDidClickSliceCallbackBlock];
    
    [pieChart drawChartWithAnimation:YES];
    [self.view addSubview:pieChart];
}

- (void)setAnimationDuradion{
    self.pieChart.animationDuration = 0.5;
}

- (void)setStartAngle{
    self.pieChart.startAngle = -M_PI / 4;
}

- (void)setSliceSpace{
    self.pieChart.sliceSpace = 3;
}

- (void)setInitialSelectedSlice{
    self.pieChart.selectedIndex = self.pieChart.sliceScales.count - 1;
}

- (void)setSliceColor{
    NSMutableArray *colors = [NSMutableArray array];
    [colors addObject:UIColorFromHexValue(0x99CC00)];
    [colors addObject:UIColorFromHexValue(0x9999FF)];
    [colors addObject:UIColorFromHexValue(0x99CC99)];
    [colors addObject:UIColorFromHexValue(0x00CC66)];
    [colors addObject:UIColorFromHexValue(0x00CCFF)];
    self.pieChart.sliceColors = [NSMutableArray arrayWithArray:colors];
}

- (void)addTitleInSlice{
    self.pieChart.titlesInSlices = [NSMutableArray arrayWithArray:@[@"23%", @"7%", @"35%", @"20%", @"15%"]];
    self.pieChart.titleFontInSlice = [UIFont systemFontOfSize:10];
    self.pieChart.titleColorInSlice = [UIColor blackColor];
}

- (void)addLinesAndTitleOutSlice{
    self.pieChart.showLinesAndTitlesOutSideSlice = YES;
    self.pieChart.titlesOutsideSlices = [NSMutableArray arrayWithArray:@[@"slice 1", @"slice 2", @"slice 3", @"slice 4", @"slice 5"]];
    self.pieChart.titleFontOutsideSlice = [UIFont systemFontOfSize:12];
    self.pieChart.titleColorOutSideSlice = [UIColor blackColor];
    self.pieChart.titleOutsideSliceOffsetToLine = 3;
    
    self.pieChart.linePart1OffsetPercentage = 0.9;
    self.pieChart.linePart1Length = 20;
    self.pieChart.linePart1Color = [UIColor blackColor];
    self.pieChart.linePart1Width = 1;
    
    self.pieChart.linePart2Length = 20;
    self.pieChart.linePart2Color = [UIColor blackColor];
    self.pieChart.linePart2Width = 1;
}

- (void)addHole{
    self.pieChart.showHoleView = YES;
    self.pieChart.holeTitle = @"HOLE";
    self.pieChart.holeTitleFont = [UIFont boldSystemFontOfSize:14];
    self.pieChart.holeTitleColor = [UIColor brownColor];
}

- (void)addCustomTitleViewOutSlice{
    NSMutableArray<UIView *> *customTitleViews = [NSMutableArray array];
    NSMutableArray<NSString *> *customTitleViewsSize = [NSMutableArray array];
    for (NSInteger i = 0; i < self.pieChart.sliceScales.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"image%ld.png", (long)i]]];
        CGSize size = CGSizeMake(30, 30);
        [customTitleViews addObject:imageView];
        [customTitleViewsSize addObject:NSStringFromCGSize(size)];
    }
    [self.pieChart addCustomTitleViewsOutsideSliceWithViews:customTitleViews sizes:customTitleViewsSize offsetToLine:3];
}

- (void)addInteractionStyle{
    [self setSelectedDefaultStyle];   //样式一
//    [self setSelectedSpaceStyle];     //样式二
//    [self setSelectedOffsetStyle];    //样式三
}

- (void)setSelectedDefaultStyle{
    self.pieChart.selectedEnable = YES;
    self.pieChart.selectedStyle = WLSliceSelectedStyleDefault;
    self.pieChart.selectedDefaultStyleNewRadius = 80;
}

- (void)setSelectedSpaceStyle{
    self.pieChart.selectedEnable = YES;
    self.pieChart.selectedStyle = WLSliceSelectedStyleSpace;
    self.pieChart.selectedSpaceStyleSpace = 5;
    self.pieChart.selectedSpaceStyleAnimation = YES;
}

- (void)setSelectedOffsetStyle{
    self.pieChart.selectedEnable = YES;
    self.pieChart.selectedStyle = WLSliceSelectedStyleOffset;
    self.pieChart.selectedOffsetStyleOffset = 5;
    self.pieChart.selectedOffsetStyleAnimation = YES;
}

- (void)setDidClickSliceCallbackBlock{
    [self.pieChart didClickSlice:^(WLSlice *slice, NSInteger index) {
        NSLog(@"_________click index: %ld", index);
        NSLog(@"---------slice selected status: %d", slice.selected);
    }];
}

- (void)addRefreshBtn{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 80/2, self.view.bounds.size.height - 80, 80, 30)];
    [btn setTitle:@"刷新" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)tap{
    [self.pieChart refreshChartWithAnimation:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
