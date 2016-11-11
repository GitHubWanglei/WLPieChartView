
<h1 align = "center">这是居中标题</h1>

### 基本使用
```
    WLPieChartView *pieChart = [[WLPieChartView alloc] initWithFrame:CGRectMake(0, 0, 160, 140)];
    pieChart.center = self.view.center;
    pieChart.sliceScales = [NSMutableArray arrayWithArray:@[@(0.23), @(0.07), @(0.35), @(0.2), @(0.15)]];
    pieChart.titlesInSlices = [NSMutableArray arrayWithArray:@[@"23%", @"7%", @"35%", @"20%", @"15%"]];
    [pieChart drawChartWithAnimation:YES];
    [self.view addSubview:pieChart];
```
