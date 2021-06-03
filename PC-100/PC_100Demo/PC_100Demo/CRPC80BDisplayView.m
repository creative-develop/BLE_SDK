//
//  CRPC80BDisplayView.m
//  PC80B
//
//  Created by Creative on 17/1/22.
//  Copyright © 2017年 creative. All rights reserved.
//

#import "CRPC80BDisplayView.h"
//#define LineSpace 5
//#define MAXLength (int)(self.bounds.size.width - LineSpace)
//#define MaxValueIn(a,b) ((a)>(b)?(a):(b))
//#define MinValueIn(a,b) ((a)>(b)?(b):(a))

/** 用于实现CALayerDelegate 的代理方法，成为Layer的代理*/


@interface CRPC80BDisplayView() <CAAnimationDelegate>

/** 网格层  */
@property (nonatomic, weak) CAShapeLayer *gridLayer;

/** 心电层  */
@property (nonatomic, weak) CAShapeLayer *pathLayer;

/** 增益线层  */
@property (nonatomic, weak) CAShapeLayer *gainLayer;

/** 缩略图(展示整个测量过程的数据)  */
@property (nonatomic, weak) CAShapeLayer *contourLayer;

/** 接触不良提示  */
@property (nonatomic, weak) CATextLayer *leadOffLayer;
/** 准备测量提示  */
@property (nonatomic, weak) CATextLayer *prepareLayer;

/** 缩略图的曲线 */
@property (nonatomic, strong) UIBezierPath *contourPath;
/** 测量时的曲线 */
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic,strong) NSMutableArray<CRECGPoint *> *totalPoints;
@property (nonatomic,strong) NSArray<CRECGPoint *> *addedPoints;
@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger dropCounts;
@property (nonatomic, assign) NSInteger circleCount;

@property (nonatomic,assign) NSInteger keepDrawingCount;

/** 折线的颜色 */
@property (nonatomic, strong) UIColor *lineColor;
@end

@implementation CRPC80BDisplayView


+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initLayers];
        [self setGridlines];
        _heightScale = 1.0 / 13;
        _path = [UIBezierPath bezierPath];
        _totalPoints = [NSMutableArray array];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)initLayers
{
    //背景网格层
    CAShapeLayer *gridLayer = [CAShapeLayer layer];
    _gridLayer = gridLayer;
    _gridLayer.frame = self.bounds;
    gridLayer.strokeColor = [UIColor grayColor].CGColor;
    gridLayer.fillColor = [UIColor clearColor].CGColor;
    gridLayer.lineWidth = 1;
    gridLayer.lineDashPattern = @[@2,@2];
    gridLayer.lineDashPhase = 1;
    [self.layer addSublayer:gridLayer];
    
    //曲线层
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.strokeColor = [UIColor greenColor].CGColor;
    pathLayer.fillColor = [UIColor clearColor].CGColor;
    pathLayer.lineWidth = 1;
    _pathLayer = pathLayer;
    [self.layer addSublayer:pathLayer];
    
    //增益线层
    CAShapeLayer *gainLayer = [CAShapeLayer layer];
    gainLayer.strokeColor = [UIColor blueColor].CGColor;
    gainLayer.fillColor = [UIColor clearColor].CGColor;
    gainLayer.lineWidth = 1;
    gainLayer.frame = CGRectMake(0, 0, 20, self.bounds.size.height);
    _gainLayer = gainLayer;
    [self.layer addSublayer:gainLayer];
    
    //接触不良提示层
    CATextLayer *leadOffL = [CATextLayer layer];
    leadOffL.string = NSLocalizedString(@"接触不良?", @"接触不良?");
    leadOffL.contentsScale = [UIScreen mainScreen].scale;
    self.leadOffLayer = leadOffL;
    leadOffL.hidden = YES;
    //字体大小
    leadOffL.fontSize = 20.f;
    //对齐方式
    leadOffL.alignmentMode = kCAAlignmentCenter;
    //    //背景颜色
    //    resultLayer.backgroundColor = [UIColor orangeColor].CGColor;
    //字体颜色
    leadOffL.foregroundColor = [UIColor whiteColor].CGColor;
    leadOffL.frame = CGRectMake( self.bounds.size.width * 0.26, self.bounds.size.height * 0.6, self.bounds.size.width *0.48, 50);
    [self.layer addSublayer:leadOffL];
    
    CATextLayer *prepareL = [CATextLayer layer];
    prepareL.string = NSLocalizedString(@"准备测量", @"准备测量");
    prepareL.contentsScale = [UIScreen mainScreen].scale;
    self.prepareLayer = prepareL;
    prepareL.hidden = YES;
    //字体大小
    prepareL.fontSize = 20.f;
    //对齐方式
    prepareL.alignmentMode = kCAAlignmentCenter;
    prepareL.foregroundColor = [UIColor lightGrayColor].CGColor;
    prepareL.frame = CGRectMake( 20, 20, self.bounds.size.width *0.4, 50);
    [self.layer addSublayer:prepareL];

}

- (CAShapeLayer *)contourLayer
{
    if (!_contourLayer)
    {
        CAShapeLayer *contourL = [CAShapeLayer layer];
        [self.layer addSublayer:contourL];
        contourL.masksToBounds = YES;
        contourL.strokeColor = [UIColor whiteColor].CGColor;
        contourL.fillColor = [UIColor clearColor].CGColor;
        contourL.lineWidth = 0.25;
        contourL.backgroundColor = [UIColor grayColor].CGColor;
        CGSize size = self.bounds.size;
        //        contourL.frame = CGRectMake(0, size.height, size.width, _heightScale * size.height);
        contourL.frame = CGRectMake(0, (1-_heightScale) * size.height, size.width, _heightScale * size.height);
        _contourLayer = contourL;
        
        
        //        [self messurementAnimation];
        //        [self setGridlines];
    }
    return  _contourLayer;
}

- (void)messurementAnimation
{
    CGSize size = self.bounds.size;
    
    //    _pathLayer.frame = CGRectMake(0, 0, size.width, (1-_heightScale) * size.height);
    //    _gridLayer.frame = CGRectMake(0, 0, size.width, (1-_heightScale) * size.height);
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.y"];
    anim.fromValue = [NSNumber numberWithFloat:size.height];
    anim.toValue = [NSNumber numberWithFloat:(1-_heightScale) * size.height];
    anim.duration = 0.5;
    [_contourLayer addAnimation:anim forKey:@""];
    
}

//设置网格线
- (void)setNeedGrade:(BOOL)needGrade
{
    _needGrade = needGrade;
    if (!_needGrade)
    {
        _gridLayer.path = [UIBezierPath bezierPath].CGPath;
    }
}

- (void)setGridlines
{
    CAShapeLayer *layer = _gridLayer;
    _gridLayer.path = nil;
    UIBezierPath *gridlinesPath = [UIBezierPath bezierPath];
    float space = _gridLayer.frame.size.height * 1.0 / 6;
    for (int i = 1; i < 6; i++)
    {
        [gridlinesPath moveToPoint:CGPointMake(0, i * space)];
        [gridlinesPath addLineToPoint:CGPointMake(_gridLayer.frame.size.width, i *space)];
    }
    int horizontalLines = (_gridLayer.frame.size.width / space) + 1;
    
    for (int i = 1 ; i < horizontalLines; i++)
    {
        [gridlinesPath moveToPoint:CGPointMake(i * space ,0)];
        [gridlinesPath addLineToPoint:CGPointMake(i * space , _gridLayer.frame.size.height)];
    }
    layer.path = gridlinesPath.CGPath;
}

- (void)setLineColor:(UIColor *)lineColor
{
    if (lineColor)
    {
        _lineColor = lineColor;
        _pathLayer.strokeColor = lineColor.CGColor;
    }
}
- (void)setLeadOffColor:(UIColor *)leadOffColor
{
    if (leadOffColor)
        _leadOffColor = leadOffColor;
    else
        _leadOffColor = [UIColor whiteColor];
    _leadOffLayer.foregroundColor = _leadOffColor.CGColor;
}

- (void)setPrepareState:(BOOL)bePrepare
{
    _prepareLayer.hidden = !bePrepare;
}
//增益线段
- (void)drawGainLineWithGain:(int)gain
{
    int maxGain = 6;
    float realGain = gain;
    if (gain == 0)
    {
        realGain = 0.5;
    }
    float space = self.bounds.size.height * 1.0 / maxGain;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, (maxGain - realGain) * 1.0 / 2 * space)];
    [path addLineToPoint:CGPointMake(10, (maxGain - realGain) * 1.0 / 2 * space)];
    [path moveToPoint:CGPointMake(5,  (maxGain - realGain) * 1.0 / 2 *space)];
    [path addLineToPoint:CGPointMake(5 ,(maxGain * 0.5 + 0.5 * realGain) * space)];
    [path moveToPoint:CGPointMake(0, (maxGain * 0.5 + 0.5 * realGain) *space)];
    [path addLineToPoint:CGPointMake(10, (maxGain * 0.5 + 0.5 * realGain) *space)];
    
    _gainLayer.path = path.CGPath;
}

//接到新的点数组
- (void)addPoints:(NSArray <CRECGPoint *>*)points InModel:(int )model Formal:(BOOL)formal
{
    _addedPoints = points;
    //所有测量模式都使用同一样式绘制
    //是否需要画满一屏  -------阶段一 至阶段二
    if (self.totalCount < (int)self.bounds.size.width)
    {
        [self phase1WithPoints:points];
    }
    //是否还需要丢弃点 -------阶段二 至阶段三
    else if(self.dropCounts < LineSpace)
    {
        [self phase2WithPoints:points];
    }
    //不用画满也不用丢弃点的时候，一直做形变 -------阶段三 至阶段一
    else
    {
        [self phase3WithPoints:points];
    }
    //正式测量且是标准模式下，才需要绘制缩略图
    if (formal && model)
        [self drawContoursPath:points];
}

- (void)phase1WithPoints:(NSArray <CRECGPoint *>*)points
{
    //用于画线的点
    NSArray *left = [points subarrayWithRange:NSMakeRange( 0,MinValueIn((int)self.bounds.size.width - self.totalCount, points.count))];
    [self drawLineWithPoints:left];
    
    //如果已经画满，剩余的点要丢弃
    if (points.count - left.count)
    {
        //剩余丢弃的点
        NSArray *right = [points subarrayWithRange:NSMakeRange(left.count, points.count - left.count)];
        [self dropPoints:right.count];
        //            _animDisappearLayer.path = nil;
    }
}

- (void)phase2WithPoints:(NSArray <CRECGPoint *>*)points
{
    //继续丢弃点
    NSArray *left = [points subarrayWithRange:NSMakeRange( 0,MinValueIn(LineSpace - self.dropCounts , points.count))];
    [self dropPoints:left.count];
    
    //丢弃的点已经足够，剩余的点进行形变
    if (points.count - left.count)
    {
        //进行形变的点
        NSArray *right = [points subarrayWithRange:NSMakeRange(left.count, points.count - left.count)];
        [self makeShape:right];
    }
}

- (void)phase3WithPoints:(NSArray <CRECGPoint *>*)points
{
    //形变的点
    NSArray *left = [points subarrayWithRange:NSMakeRange( 0,MinValueIn((int)self.bounds.size.width - LineSpace - self.circleCount , points.count))];
    [self makeShape:left];
    //是否形变结束，结束后，剩余的点用于画满
    if (points.count - left.count)
    {
        self.dropCounts = 0;
        self.circleCount = 0;
        self.totalCount = self.bounds.size.width - LineSpace;
        //用于画满一屏
        NSArray *right = [points subarrayWithRange:NSMakeRange(left.count, points.count - left.count)];
        [self drawLineWithPoints:right];
    }
}


//画满一屏
- (void)drawLineWithPoints:(NSArray <CRECGPoint *>*)points
{
    CGFloat height = self.bounds.size.height;
    CGFloat pointY = 0;
    if (self.totalCount == 0)
    {
        [self.path removeAllPoints];
        pointY = [self checkPointY: height -points[0].y * 1.0*height/ MaxWaveValue];
        [self.path moveToPoint:CGPointMake(0, pointY)];
    }
    
    for (int i = 0; i < points.count ; i++)
    {
        pointY = [self checkPointY: height -points[i].y * 1.0 * height/ MaxWaveValue ];
        
        [self.path addLineToPoint:CGPointMake(self.totalPoints.count + i,pointY )];
    }
    [self.totalPoints addObjectsFromArray:points];
    
    self.pathLayer.path = self.path.CGPath;
    self.totalCount += points.count;
    
}

//根据点的个数，丢弃对应个数的点
- (void)dropPoints:(NSInteger)pointsCount
{
    CGFloat height = self.bounds.size.height;
    CGFloat pointY = 0;
    for (int i = 0; i < pointsCount; i++)
    {
        [self.totalPoints removeObjectAtIndex:0];
    }
    [self.path removeAllPoints];
    self.dropCounts += pointsCount;
    pointY = [self checkPointY: height -self.totalPoints[0].y * 1.0 * height/ MaxWaveValue];
    [self.path moveToPoint:CGPointMake(self.dropCounts,pointY)];
    for (int i = 1; i < self.totalPoints.count; i++)
    {
        pointY = [self checkPointY:height - self.totalPoints[i].y * 1.0 * height/ MaxWaveValue];
        [self.path addLineToPoint:CGPointMake(self.dropCounts + i,pointY)];
    }
    self.pathLayer.path = self.path.CGPath;
}

//形变，左右同时绘制。
- (void)makeShape:(NSArray <CRECGPoint *>*)points
{
    CGFloat height = self.bounds.size.height;
    CGFloat pointY = 0;
    //    //用新的点置换旧点
    [self.totalPoints addObjectsFromArray:points];
    for (int i = 0; i < points.count; i++)
    {
        [self.totalPoints removeObjectAtIndex:0];
    }
    //绘制左右两边
    [self.path removeAllPoints];
    self.circleCount += points.count;
    //绘制右边
    pointY = [self checkPointY: height -self.totalPoints[0].y * 1.0 * height/ MaxWaveValue];
    [self.path moveToPoint:CGPointMake(self.circleCount + LineSpace,pointY)];
    for (int i = 1; i < self.totalPoints.count - self.circleCount; i++)
    {
        pointY = height - self.totalPoints[i].y * 1.0 * height/ MaxWaveValue;
        [self.path addLineToPoint:CGPointMake(i + self.circleCount + LineSpace,pointY)];
    }
    //绘制左边
    pointY = [self checkPointY:height -self.totalPoints[self.totalPoints.count - self.circleCount].y * 1.0 * height/ MaxWaveValue];
    [self.path moveToPoint:CGPointMake(0, pointY)];
    for (int i = 1; i < self.circleCount; i ++)
    {
        pointY = [self checkPointY:height -self.totalPoints[self.totalPoints.count - self.circleCount + i].y * 1.0 * height/ MaxWaveValue];
        [self.path addLineToPoint:CGPointMake(i, pointY)];
    }
    self.pathLayer.path = self.path.CGPath;
}

- (void)setLeadOff:(BOOL)leadOff
{
    _leadOffLayer.hidden = leadOff;
}

int pathProgress = 0;
- (void)clearPath
{
    //1.曲线清除
    _pathLayer.path = nil;
    _contourLayer.path = nil;
    _contourPath = nil;
    //2.所有全局变量复原
    _path = [UIBezierPath bezierPath];
    pathProgress = 0;
    //3.缓存清空
    _circleCount = 0;
    _totalCount = 0;
    _dropCounts = 0;
    [_totalPoints removeAllObjects];
    _addedPoints = nil;
    _keepDrawingCount = 0;
    //4.隐藏进度条
    [_contourLayer removeFromSuperlayer];
    //5.隐藏接触不良提示
    _leadOffLayer.hidden = YES;
    //6.增益线改为默认的2
    [self drawGainLineWithGain:2];
}


- (void)drawContoursPath:(NSArray <CRECGPoint *>*)points
{
    CGFloat height = self.contourLayer.frame.size.height;
    CGFloat pointY = 0;
    if (!_contourPath)
    {
        _contourPath = [UIBezierPath bezierPath];
        [_contourPath moveToPoint:CGPointMake(0,  height * 0.5)];
    }
    float widthScale = self.bounds.size.width * 1.0 / MaxPointsCount;
    for (int i = 0; i < points.count; i++)
    {
        pointY = [self checkPointY:height - points[i].y* 1.0 * height/ MaxWaveValue];
        [_contourPath addLineToPoint:CGPointMake((i + pathProgress) * widthScale, pointY)];
    }
    self.contourLayer.path = _contourPath.CGPath;
    pathProgress += points.count;
    
}


- (CGFloat)checkPointY:(CGFloat)pointY
{
    if (pointY > self.bounds.size.height)
        return self.bounds.size.height;
    if (pointY < 0)
        return 0;
    return pointY;
}
@end
