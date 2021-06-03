//
//  CRHeartLiveView.m
//  creativeExample
//
//  Created by Creative on 16/12/26.
//  Copyright © 2016年 creative. All rights reserved.
//


#import "CRHeartLiveView.h"
#define LineSpace 35
#define MAXLength (int)(self.bounds.size.width - LineSpace)
#define MaxValueIn(a,b) ((a)>(b)?(a):(b))
#define MinValueIn(a,b) ((a)>(b)?(b):(a))
#define WaveSreenScale self.bounds.size.height * 1.0 / 128
@implementation CRPoint
@end
@interface CRHeartLiveView ()
@property (nonatomic,strong) NSMutableArray<CRPoint *> *totalPoints;
@property (nonatomic,strong) UIBezierPath *path;

/** 记录波形形变的长度*/
@property (nonatomic,assign) NSInteger circleCount;
/** 记录已经丢失点的个数*/
@property (nonatomic,assign) NSInteger dropCounts;
/** 记录是否已经画满一个屏*/
@property (nonatomic,assign) NSInteger totalCount;
/** 提示文字  */
@property (nonatomic, weak) CATextLayer *leadOffLayer;
@end

@implementation CRHeartLiveView
//替换View的layer类型
+(Class)layerClass
{
    return [CAShapeLayer class];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.path = [UIBezierPath bezierPath];
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        layer.strokeColor = [UIColor redColor].CGColor;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.lineWidth = 1;
        layer.contentsScale = [UIScreen mainScreen].scale;
        self.totalPoints = [NSMutableArray array];
        
        
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


//新增点
- (void)addPoints:(NSArray <CRPoint *>*)points
{
    //是否需要画满一屏
    if (self.totalCount < (int)self.bounds.size.width)
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
        }
        return;
    }
    //是否还需要丢弃点
    else if(self.dropCounts < LineSpace)
    {
        //继续丢弃点
        NSArray *left = [points subarrayWithRange:NSMakeRange( 0,MinValueIn(LineSpace - self.dropCounts , points.count))];
        
        [self dropPoints:left.count];
        
        //丢弃的点已经足够，剩余的点进行形变
        if (points.count - left.count)
        {
            //进行形变的点
            NSArray *right = [points subarrayWithRange:NSMakeRange(left.count, points.count - left.count)];
            [self makeShape2:right];
        }
        return;
    }
    //不用画满也不用丢弃点的时候，一直做形变
    else
    {
        //形变的点
        NSArray *left = [points subarrayWithRange:NSMakeRange( 0,MinValueIn((int)self.bounds.size.width - LineSpace - self.circleCount , points.count))];
        [self makeShape2:left];
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
        return;
    }

}

- (void)setLeadOff:(BOOL)leadOff
{
    _leadOffLayer.hidden = !leadOff;
}
//根据点的个数，丢弃对应个数的点
- (void)dropPoints:(NSInteger)pointsCount
{
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    for (int i = 0; i < pointsCount; i++)
    {
        [self.totalPoints removeObjectAtIndex:0];
    }
    [self.path removeAllPoints];
    self.dropCounts += pointsCount;
    [self.path moveToPoint:CGPointMake(self.dropCounts, self.totalPoints[0].y * WaveSreenScale)];
    for (int i = 1; i < self.totalPoints.count; i++)
    {
        [self.path addLineToPoint:CGPointMake(self.dropCounts + i, self.totalPoints[i].y * WaveSreenScale)];
    }
    layer.path = self.path.CGPath;

}


//形变，左右同时绘制。
- (void)makeShape2:(NSArray <CRPoint *>*)points
{
//    //用新的点置换旧点
    [self.totalPoints addObjectsFromArray:points];
    for (int i = 0; i < points.count; i++)
    {
        [self.totalPoints removeObjectAtIndex:0];
    }
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    //绘制左右两边
    [self.path removeAllPoints];
    self.circleCount += points.count;
    //绘制右边
    [self.path moveToPoint:CGPointMake(self.circleCount + LineSpace, self.totalPoints[0].y * WaveSreenScale)];
    for (int i = 1; i < self.totalPoints.count - self.circleCount; i++)
    {
        [self.path addLineToPoint:CGPointMake(i + self.circleCount + LineSpace, self.totalPoints[i].y* WaveSreenScale)];
    }
    //绘制左边
    [self.path moveToPoint:CGPointMake(0, self.totalPoints[self.totalPoints.count - self.circleCount].y * WaveSreenScale)];
    for (int i = 1; i < self.circleCount; i ++)
    {
        [self.path addLineToPoint:CGPointMake(i, self.totalPoints[self.totalPoints.count - self.circleCount + i].y* WaveSreenScale)];
    }
    layer.path = self.path.CGPath;
}

//画满一屏
- (void)drawLineWithPoints:(NSArray <CRPoint *>*)points
{

    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    if (self.totalCount == 0)
    {
        [self.path removeAllPoints];
         [self.path moveToPoint:CGPointMake(0, points[0].y * WaveSreenScale)];
    }
   
    for (int i = 0; i < points.count ; i++)
    {
        [self.path addLineToPoint:CGPointMake(self.totalPoints.count + i, points[i].y * WaveSreenScale)];
    }
    [self.totalPoints addObjectsFromArray:points];
    layer.path = self.path.CGPath;
    self.totalCount += points.count;

}


//清屏，各数据恢复到原始值
- (void)clearPath
{
    self.totalPoints = [NSMutableArray array];
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    [self.path removeAllPoints];
    layer.path = self.path.CGPath;
//    self.blankLayer.frame = CGRectMake(0, -1, LineSpace, self.bounds.size.height + 2);
     self.circleCount = 0;
    self.totalCount = 0;
    self.dropCounts = 0;
//    self.blankLayerX = -LineSpace;
}
@end
