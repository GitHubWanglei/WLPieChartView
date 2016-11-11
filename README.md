
<h1 align = "center">这是居中标题</h1>

### 基本使用

代码如下:
```
WLPieChartView *pieChart = [[WLPieChartView alloc] initWithFrame:CGRectMake(0, 0, 160, 140)];//饼图半径为宽和高最大值的一半
pieChart.sliceScales = [NSMutableArray arrayWithArray:@[@(0.23), @(0.07), @(0.35), @(0.2), @(0.15)]];//设置区块比例
pieChart.titlesInSlices = [NSMutableArray arrayWithArray:@[@"23%", @"7%", @"35%", @"20%", @"15%"]];//设置内标题
[pieChart drawChartWithAnimation:YES];//开始绘制
[self.view addSubview:pieChart];
```
效果如下:
![效果图]()
