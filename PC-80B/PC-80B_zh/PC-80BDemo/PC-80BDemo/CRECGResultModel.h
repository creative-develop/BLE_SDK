//
//  CRECGResultModel.h
//  Sta
//
//  Created by Creative on 16/12/22.
//  Copyright © 2016年 creative. All rights reserved.
//
#define LineSpace 35
#define MAXLength (int)(self.bounds.size.width - LineSpace)
#define MaxValueIn(a,b) ((a)>(b)?(a):(b))
#define MinValueIn(a,b) ((a)>(b)?(b):(a))
#define MaxWaveValue 4096
#define MaxPointsCount 4500

#define ECGModelDataLength 9796
#define ECGModelPointsCount 4500

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 
 代表一个ECG测量结果
 */
@interface CRECGPoint : NSObject
@property (nonatomic,assign) CGFloat x;
@property (nonatomic,assign) CGFloat y;

- (instancetype)initWithX:(CGFloat)x AndY:(CGFloat)y;
@end


@interface CRECGResultModel : NSObject
@property (nonatomic,assign) int companyDevice;
@property (nonatomic,strong) NSString *result;
@property (nonatomic,assign) int gain;
@property (nonatomic,assign) int smooth;
@property (nonatomic,assign) int hr;
@property (nonatomic,strong) NSArray <CRECGPoint *>*points;
@property (nonatomic,strong) NSString *time;
/** 是否是十二位  */
@property (nonatomic, assign) BOOL beTwelve;

/** 模型二进制数据 */
@property (nonatomic, strong) NSData *data;

@property (nonatomic,assign) int resultCode;
@end
