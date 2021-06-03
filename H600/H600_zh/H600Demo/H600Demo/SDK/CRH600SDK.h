//
//  CRH600SDK.h
//  PC300SDKDemo
//
//  Created by Creative on 2018/3/23.
//  Copyright © 2018年 creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRBleDevice.h"


@class CRH600SDK;

/* 当前测量模式 */
typedef NS_ENUM(Byte, CRH600SDKMessureStage)
{
    /* 正在准备测量 */
    CRH600SDKMessureStagePreparing = 1,
    /*  测量进行中 */
    CRH600SDKMessureStageProcessing,
//    /* 开始分析 */
//    CRH600SDKMessureStageAnalyzing,
//    /* 报告测量结果 */
//    CRH600SDKMessureStageReporting,
//    /* 跟踪停止 */
//    CRH600SDKMessureStageComplete,
};

@protocol CRH600SDKDelegate <NSObject>
/** 获取到设备版本号 */
- (void)h600SDK:(CRH600SDK *)h600SDK GetDeviceHardWareVersion:(NSString *)hardWareV SoftWareVersion:(NSString *)softWareV FromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取到设备电量等级 (0~4)，等级高代表电量多
 *  @param battaryLevel     电量等级
 *  @param device     设备
 *
 */
- (void)h600SDK:(CRH600SDK *)h600SDK GetBattayLevel:(int)battaryLevel ForDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取设备心电开始/停止测量
 *  @param isStart     开始/停止
 *  @param device     设备
 *
 */
- (void)h600SDK:(CRH600SDK *)h600SDK GetECGAction:(BOOL)isStart ForDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取设备实时心率
 *  @param heartRate     实时心率
 *  @param device     设备
 *
 */
- (void)h600SDK:(CRH600SDK *)h600SDK GetRealTimeHeartRate:(int)heartRate ForDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取到心电跟踪波形数据
 *  @param data     波形值数组
 *  @param length     波形值数组长度
 *  @param gain     增益值（0 表示 ½）
 *  @param stage     当前为哪种测量阶段
 *  @param leadOff     导联脱落情况
 *  @param device     设备
 */
- (void)h600SDK:(CRH600SDK *)pc80bSDK GetTrackingWaveData:(struct waveData *)data Length:(int)length Gain:(int)gain MessureStage:(CRH600SDKMessureStage)stage LeadOff:(BOOL)leadOff ForDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取到心电测量结果
 *  @param result     心电结果
 *  @param heartRate     心率
 *  @param date     测量日期(开始时间)
 *  @param device     设备
 */
- (void)h600bSDK:(CRH600SDK *)h600bSDK GetMessureResult:(int)result HeartRate:(int)heartRate Date:(NSString *)date ForDevice:(CRBleDevice *)device;


@end

@interface CRH600SDK : NSObject
/** 代理  */
@property (nonatomic, weak) id <CRH600SDKDelegate>delegate;
+(instancetype)shareInstance;
/** 用于处理连接后的任务 */
- (void)didConnectDevice:(CRBleDevice *)device;
/** 用于处理断开连接后续任务 */
- (void)willDisconnectWithDevice:(CRBleDevice *)device;
/** 获取到新的数据 */
- (void)appendingNewData:(NSData *)data FromDevice:(CRBleDevice *)device;

/** 查询2位设备版本号 */
- (void)queryTwoBitDeviceVersionForDevice:(CRBleDevice *)device;

@end
