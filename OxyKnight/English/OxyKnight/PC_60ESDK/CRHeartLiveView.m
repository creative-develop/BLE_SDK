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

/** Record the length of the waveform deformation*/
@property (nonatomic,assign) NSInteger circleCount;
/** Record the number of lost points*/
@property (nonatomic,assign) NSInteger dropCounts;
/** Record whether the full screen has been drawn*/
@property (nonatomic,assign) NSInteger totalCount;
/** Prompt text  */
@property (nonatomic, weak) CATextLayer *leadOffLayer;
@end

@implementation CRHeartLiveView
//Replace the layer type of View
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
        
        
        //Bad contact prompt layer
        CATextLayer *leadOffL = [CATextLayer layer];
        leadOffL.string = @"Finger falling off";
        leadOffL.contentsScale = [UIScreen mainScreen].scale;
        self.leadOffLayer = leadOffL;
        leadOffL.hidden = YES;
        leadOffL.fontSize = 20.f;
        leadOffL.alignmentMode = kCAAlignmentCenter;
        //    resultLayer.backgroundColor = [UIColor orangeColor].CGColor;
        leadOffL.foregroundColor = [UIColor lightGrayColor].CGColor;
        leadOffL.frame = CGRectMake( self.bounds.size.width * 0.3, self.bounds.size.height * 0.6, self.bounds.size.width *0.4, 50);
        [self.layer addSublayer:leadOffL];
    }
    return self;
}


//Add point
- (void)addPoints:(NSArray <CRPoint *>*)points
{
    //Do you need to draw a full screen
    if (self.totalCount < (int)self.bounds.size.width)
    {
        //Point used to draw a line
        NSArray *left = [points subarrayWithRange:NSMakeRange( 0,MinValueIn((int)self.bounds.size.width - self.totalCount, points.count))];
        [self drawLineWithPoints:left];
        //If it is full, the remaining points will be discarded
        if (points.count - left.count)
        {
            //Remaining discarded points
            NSArray *right = [points subarrayWithRange:NSMakeRange(left.count, points.count - left.count)];
            [self dropPoints:right.count];
        }
        return;
    }
    //Do you still need to discard points
    else if(self.dropCounts < LineSpace)
    {
        //Continue to discard points
        NSArray *left = [points subarrayWithRange:NSMakeRange( 0,MinValueIn(LineSpace - self.dropCounts , points.count))];
        
        [self dropPoints:left.count];
        
        //The discarded points are enough, and the remaining points are deformed
        if (points.count - left.count)
        {
            NSArray *right = [points subarrayWithRange:NSMakeRange(left.count, points.count - left.count)];
            [self makeShape2:right];
        }
        return;
    }
    //When you don’t need to paint full or discard points, always make deformations
    else
    {
        NSArray *left = [points subarrayWithRange:NSMakeRange( 0,MinValueIn((int)self.bounds.size.width - LineSpace - self.circleCount , points.count))];
        [self makeShape2:left];
        //Whether the deformation is over, after the end, the remaining points are used to draw full
        if (points.count - left.count)
        {
            self.dropCounts = 0;
            self.circleCount = 0;
            self.totalCount = self.bounds.size.width - LineSpace;
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
//According to the number of points, discard the corresponding number of points
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


//Deform, draw left and right at the same time.
- (void)makeShape2:(NSArray <CRPoint *>*)points
{
//    //Replace old points with new ones
    [self.totalPoints addObjectsFromArray:points];
    for (int i = 0; i < points.count; i++)
    {
        [self.totalPoints removeObjectAtIndex:0];
    }
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    //Draw left and right sides
    [self.path removeAllPoints];
    self.circleCount += points.count;
    [self.path moveToPoint:CGPointMake(self.circleCount + LineSpace, self.totalPoints[0].y * WaveSreenScale)];
    for (int i = 1; i < self.totalPoints.count - self.circleCount; i++)
    {
        [self.path addLineToPoint:CGPointMake(i + self.circleCount + LineSpace, self.totalPoints[i].y* WaveSreenScale)];
    }
    [self.path moveToPoint:CGPointMake(0, self.totalPoints[self.totalPoints.count - self.circleCount].y * WaveSreenScale)];
    for (int i = 1; i < self.circleCount; i ++)
    {
        [self.path addLineToPoint:CGPointMake(i, self.totalPoints[self.totalPoints.count - self.circleCount + i].y* WaveSreenScale)];
    }
    layer.path = self.path.CGPath;
}

//Draw a full screen
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


//clear
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
