//
//  CRWavesView.m
//  AP-20Demo
//
//  Created by Creative on 2020/12/25.
//

#import "CRWavesView.h"
#define LineSpace 35
#define MAXLength (int)(self.bounds.size.width - LineSpace)
#define MaxValueIn(a,b) ((a)>(b)?(a):(b))
#define MinValueIn(a,b) ((a)>(b)?(b):(a))
#define WaveSreenScale self.bounds.size.height * 1.0 / 4096

@interface CRWavesView ()

//第一条红线
@property (nonatomic,strong) NSMutableArray<CRPoint *> *totalPoints1;
@property (nonatomic,strong) UIBezierPath *path1;
@property (nonatomic,strong) CAShapeLayer *layer1;
//第二条绿线
@property (nonatomic,strong) NSMutableArray<CRPoint *> *totalPoints2;
@property (nonatomic,strong) UIBezierPath *path2;
@property (nonatomic,strong) CAShapeLayer *layer2;
//第三条蓝线
@property (nonatomic,strong) NSMutableArray<CRPoint *> *totalPoints3;
@property (nonatomic,strong) UIBezierPath *path3;
@property (nonatomic,strong) CAShapeLayer *layer3;

/** 记录波形形变的长度*/
@property (nonatomic,assign) NSInteger circleCount;
/** 记录已经丢失点的个数*/
@property (nonatomic,assign) NSInteger dropCounts;
/** 记录是否已经画满一个屏*/
@property (nonatomic,assign) NSInteger totalCount;
/** 提示文字  */
@property (nonatomic, weak) CATextLayer *leadOffLayer;


@end

@implementation CRWavesView

//替换View的layer类型
+(Class)layerClass
{
    return [CAShapeLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        layer.strokeColor = [UIColor redColor].CGColor;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.lineWidth = 1;
        layer.contentsScale = [UIScreen mainScreen].scale;
        
        
        //接触不良提示层
        CATextLayer *leadOffL = [CATextLayer layer];
        leadOffL.string = NSLocalizedString(@"手指脱落", @"手指脱落");
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
        leadOffL.foregroundColor = [UIColor lightGrayColor].CGColor;
        leadOffL.frame = CGRectMake( self.bounds.size.width * 0.3, self.bounds.size.height * 0.6, self.bounds.size.width *0.4, 50);
        [self.layer addSublayer:leadOffL];
    }
    return self;
}

- (void)addPoints1:(NSArray <CRPoint *>*)points1 points2:(nullable NSArray <CRPoint *>*)points2 points3:(nullable NSArray <CRPoint *>*)points3 {
    NSInteger circleCount = self.circleCount;
    NSInteger dropCounts = self.dropCounts;
    NSInteger totalCount = self.totalCount;
    if (points1.count > 0) {
        [self addPoints:points1 tag:1];
    }
    if (points2.count > 0) {
        self.circleCount = circleCount;
        self.dropCounts = dropCounts;
        self.totalCount = totalCount;
        [self addPoints:points2 tag:2];
    }
    if (points3.count > 0) {
        self.circleCount = circleCount;
        self.dropCounts = dropCounts;
        self.totalCount = totalCount;
        [self addPoints:points3 tag:3];
    }
}

//新增点
- (void)addPoints:(NSArray <CRPoint *>*)points tag:(int)tag
{
    //是否需要画满一屏
    if (self.totalCount < (int)self.bounds.size.width)
    {
        //用于画线的点
        NSArray *left = [points subarrayWithRange:NSMakeRange( 0,MinValueIn((int)self.bounds.size.width - self.totalCount, points.count))];
        [self drawLineWithPoints:left tag:tag];
        //如果已经画满，剩余的点要丢弃
        if (points.count - left.count)
        {
            //剩余丢弃的点
            NSArray *right = [points subarrayWithRange:NSMakeRange(left.count, points.count - left.count)];
            [self dropPoints:right.count tag:tag];
        }
        return;
    }
    //是否还需要丢弃点
    else if(self.dropCounts < LineSpace)
    {
        //继续丢弃点
        NSArray *left = [points subarrayWithRange:NSMakeRange( 0,MinValueIn(LineSpace - self.dropCounts , points.count))];
        
        [self dropPoints:left.count tag:tag];
        
        //丢弃的点已经足够，剩余的点进行形变
        if (points.count - left.count)
        {
            //进行形变的点
            NSArray *right = [points subarrayWithRange:NSMakeRange(left.count, points.count - left.count)];
            [self makeShape2:right tag:tag];
        }
        return;
    }
    //不用画满也不用丢弃点的时候，一直做形变
    else
    {
        //形变的点
        NSArray *left = [points subarrayWithRange:NSMakeRange( 0,MinValueIn((int)self.bounds.size.width - LineSpace - self.circleCount , points.count))];
        [self makeShape2:left tag:tag];
        //是否形变结束，结束后，剩余的点用于画满
        if (points.count - left.count)
        {
            self.dropCounts = 0;
            self.circleCount = 0;
            self.totalCount = self.bounds.size.width - LineSpace;
            //用于画满一屏
            NSArray *right = [points subarrayWithRange:NSMakeRange(left.count, points.count - left.count)];
            [self drawLineWithPoints:right tag:tag];
        }
        return;
    }

}

- (void)setLeadOff:(BOOL)leadOff
{
    _leadOffLayer.hidden = !leadOff;
}
//根据点的个数，丢弃对应个数的点
- (void)dropPoints:(NSInteger)pointsCount tag:(int)tag
{
    CAShapeLayer *layer;
    UIBezierPath *path;
    UIColor *color;
    NSMutableArray<CRPoint *> *totalPoints;
    NSInteger offset = 0;
    if (tag == 1) {
        layer = self.layer1;
        path = self.path1;
        totalPoints = self.totalPoints1;
        color = [UIColor redColor];
    } else if (tag == 2) {
        layer = self.layer2;
        path = self.path2;
        totalPoints = self.totalPoints2;
        color = [UIColor greenColor];
        offset = 10;
    } else {
        layer = self.layer3;
        path = self.path3;
        totalPoints = self.totalPoints3;
        color = [UIColor blueColor];
        offset = 20;
    }
    for (int i = 0; i < pointsCount; i++)
    {
        [totalPoints removeObjectAtIndex:0];
    }
    [path removeAllPoints];
    self.dropCounts += pointsCount;
    [path moveToPoint:CGPointMake(self.dropCounts, totalPoints[0].y * WaveSreenScale - offset)];
    for (int i = 1; i < totalPoints.count; i++)
    {
        [path addLineToPoint:CGPointMake(self.dropCounts + i, totalPoints[i].y * WaveSreenScale - offset)];
    }
    layer.path = path.CGPath;
    layer.strokeColor = color.CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
}


//形变，左右同时绘制。
- (void)makeShape2:(NSArray <CRPoint *>*)points tag:(int)tag
{
    CAShapeLayer *layer;
    UIBezierPath *path;
    UIColor *color;
    NSMutableArray<CRPoint *> *totalPoints;
    NSInteger offset = 0;
    if (tag == 1) {
        layer = self.layer1;
        path = self.path1;
        totalPoints = self.totalPoints1;
        color = [UIColor redColor];
    } else if (tag == 2) {
        layer = self.layer2;
        path = self.path2;
        totalPoints = self.totalPoints2;
        color = [UIColor greenColor];
        offset = 10;
    } else {
        layer = self.layer3;
        path = self.path3;
        totalPoints = self.totalPoints3;
        color = [UIColor blueColor];
        offset = 20;
    }
//    //用新的点置换旧点
    [totalPoints addObjectsFromArray:points];
    for (int i = 0; i < points.count; i++)
    {
        [totalPoints removeObjectAtIndex:0];
    }
    //绘制左右两边
    [path removeAllPoints];
    self.circleCount += points.count;
    //绘制右边
    [path moveToPoint:CGPointMake(self.circleCount + LineSpace, totalPoints[0].y * WaveSreenScale - offset)];
    for (int i = 1; i < totalPoints.count - self.circleCount; i++)
    {
        [path addLineToPoint:CGPointMake(i + self.circleCount + LineSpace, totalPoints[i].y * WaveSreenScale - offset)];
    }
    //绘制左边
    [path moveToPoint:CGPointMake(0, totalPoints[totalPoints.count - self.circleCount].y * WaveSreenScale - offset)];
    for (int i = 1; i < self.circleCount; i ++)
    {
        [path addLineToPoint:CGPointMake(i, totalPoints[totalPoints.count - self.circleCount + i].y * WaveSreenScale - offset)];
    }
    layer.path = path.CGPath;
    layer.strokeColor = color.CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
}

//画满一屏
- (void)drawLineWithPoints:(NSArray <CRPoint *>*)points tag:(int)tag
{
    CAShapeLayer *layer;
    UIBezierPath *path;
    UIColor *color;
    NSMutableArray<CRPoint *> *totalPoints;
    NSInteger offset = 0;
    if (tag == 1) {
        layer = self.layer1;
        path = self.path1;
        totalPoints = self.totalPoints1;
        color = [UIColor redColor];
    } else if (tag == 2) {
        layer = self.layer2;
        path = self.path2;
        totalPoints = self.totalPoints2;
        color = [UIColor greenColor];
        offset = 10;
    } else {
        layer = self.layer3;
        path = self.path3;
        totalPoints = self.totalPoints3;
        color = [UIColor blueColor];
        offset = 20;
    }
    if (self.totalCount == 0)
    {
        [path removeAllPoints];
        [path moveToPoint:CGPointMake(0, points[0].y * WaveSreenScale - offset)];
    }
   
    for (int i = 0; i < points.count ; i++)
    {
        [path addLineToPoint:CGPointMake(totalPoints.count + i, points[i].y * WaveSreenScale - offset)];
    }
    [totalPoints addObjectsFromArray:points];
    layer.path = path.CGPath;
    layer.strokeColor = color.CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    self.totalCount += points.count;
}


//清屏，各数据恢复到原始值
- (void)clearPath
{
    self.totalPoints1 = nil;
    self.totalPoints2 = nil;
    self.totalPoints3 = nil;
//    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
//    [path removeAllPoints];
//    layer.path = self.path.CGPath;
     self.circleCount = 0;
    self.totalCount = 0;
    self.dropCounts = 0;
//    self.blankLayerX = -LineSpace;
}

- (UIBezierPath *)path1 {
    if (!_path1) {
        _path1 = [UIBezierPath bezierPath];
    }
    return _path1;
}

- (UIBezierPath *)path2 {
    if (!_path2) {
        _path2 = [UIBezierPath bezierPath];
    }
    return _path2;
}

- (UIBezierPath *)path3 {
    if (!_path3) {
        _path3 = [UIBezierPath bezierPath];
    }
    return _path3;
}

- (NSMutableArray<CRPoint *> *)totalPoints1 {
    if (!_totalPoints1) {
        _totalPoints1 = [NSMutableArray array];
    }
    return _totalPoints1;
}

- (NSMutableArray<CRPoint *> *)totalPoints2 {
    if (!_totalPoints2) {
        _totalPoints2 = [NSMutableArray array];
    }
    return _totalPoints2;
}

- (NSMutableArray<CRPoint *> *)totalPoints3 {
    if (!_totalPoints3) {
        _totalPoints3 = [NSMutableArray array];
    }
    return _totalPoints3;
}

- (CAShapeLayer *)layer1 {
    if (!_layer1) {
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        [self.layer addSublayer:layer];
        _layer1 = layer;
    }
    return _layer1;
}

- (CAShapeLayer *)layer2 {
    if (!_layer2) {
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        [self.layer addSublayer:layer];
        _layer2 = layer;
    }
    return _layer2;
}

- (CAShapeLayer *)layer3 {
    if (!_layer3) {
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        [self.layer addSublayer:layer];
        _layer3 = layer;
    }
    return _layer3;
}

@end
