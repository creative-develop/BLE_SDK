//
//  CRPC80BDisplayView.h
//  PC80B
//
//  Created by Creative on 17/1/22.
//  Copyright © 2017年 creative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRECGResultModel.h"

/**
 根据接收的点数组，更新视图的曲线
 根据增益值设置，设置增益线段
 清空视图的曲线
 */
@interface CRPC80BDisplayView : UIView
/** 是否需要网格  */
@property (nonatomic, assign) BOOL needGrade;
/** 底部缩略图高度比  */
@property (nonatomic, assign) float heightScale;

/** 接触不良提示颜色 */
@property (nonatomic, strong) UIColor *leadOffColor;

- (void)addPoints:(NSArray <CRECGPoint *>*)points InModel:(int )model Formal:(BOOL)formal;

/** 设置增益线 */
- (void)drawGainLineWithGain:(int)gain;

/** 清空路径,还原参数 */
- (void)clearPath;

/** 判断导联脱落，接触不良  */
- (void)setLeadOff:(BOOL)leadOff;

- (void)setLineColor:(UIColor *)lineColor;

- (void)setPrepareState:(BOOL)bePrepare;

@end
