
<h1 align = "center" style="color:red">WLPieChartView</h1>

### 一、基本使用

代码如下:

```
WLPieChartView *pieChart = [[WLPieChartView alloc] initWithFrame:CGRectMake(0, 0, 160, 140)];//饼图半径为宽和高最大值的一半
pieChart.sliceScales = [NSMutableArray arrayWithArray:@[@(0.23), @(0.07), @(0.35), @(0.2), @(0.15)]];//设置区块比例
pieChart.titlesInSlices = [NSMutableArray arrayWithArray:@[@"23%", @"7%", @"35%", @"20%", @"15%"]];//设置内标题
[pieChart drawChartWithAnimation:YES];//开始绘制
[self.view addSubview:pieChart];
```

效果如下:

![效果图](https://github.com/GitHubWanglei/WLPieChartView/blob/master/%E5%9F%BA%E6%9C%AC%E4%BD%BF%E7%94%A8.png)

### 二、其它设置

1. 可设置中间圆孔、圆孔上的文字、区块间距、当内标题显示不下时进行自适应等, 如下图:

![](https://github.com/GitHubWanglei/WLPieChartView/blob/master/%E5%86%85%E6%A0%87%E9%A2%98%E5%92%8C%E8%87%AA%E9%80%82%E5%BA%94.png)

2.可设置外标题、折线位置颜色宽度、初始状态下选中某个区块儿、选中的样式等, 如下图:

![](https://github.com/GitHubWanglei/WLPieChartView/blob/master/%E5%A4%96%E6%A0%87%E9%A2%98%E5%92%8C%E5%88%9D%E5%A7%8B%E9%80%89%E4%B8%AD%E7%8A%B6%E6%80%81.png)

3.可设置是否能点击区块, 点击区块的交互效果, 共三种交互效果, 如下图:

![](https://github.com/GitHubWanglei/WLPieChartView/blob/master/%E4%BA%A4%E4%BA%92%E6%95%88%E6%9E%9C.gif)
