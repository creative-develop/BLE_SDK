//
//  CRPC80BSDK.h
//  PC300SDKDemo
//
//  Created by Creative on 2018/3/8.
//  Copyright © 2018年 creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRBleDevice.h"
@class CRPC80BSDK;

/* 当前测量模式 */
typedef NS_ENUM(Byte, CRPC80BSDKMessureMode)
{
    /* 正在检测测量模式 */
    CRPC80BSDKMessureModeCheckingMode = 0,
    /* 快速(普通)测量模式 */
    CRPC80BSDKMessureModeNormalMode = 1,
    /* 连续测量模式 */
    CRPC80BSDKMessureModeContinuousMode = 2,
};

/* 当前测量模式 */
typedef NS_ENUM(Byte, CRPC80BSDKMessureStage)
{
    /* 正在准备测量 */
    CRPC80BSDKMessureStagePreparing = 1,
    /*  测量进行中 */
    CRPC80BSDKMessureStageProcessing,
    /*  开始分析 */
    CRPC80BSDKMessureStageAnalyzing,
};

@protocol CRPC80BSDKDelegate <NSObject>

/** 接收到PC80B的时间同步请求 */
- (void)getTimeSynRequestFromDevice:(CRBleDevice *)device;
/** 获取到设备版本号 */
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetDeviceHardWareVersion:(NSString *)hardWareV SoftWareVersion:(NSString *)softWareV FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获取到心电跟踪波形数据
 *  @param data     波形值数组
 *  @param length     波形值数组长度
 *  @param gain     增益值（0 表示 ½）
 *  @param mode     当前波形为哪种测量模式
 *  @param stage     当前波形为哪种测量阶段
 *  @param leadOff     导联脱落情况
 *  @param device     设备
 */
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetTrackingWaveData:(int *)data Length:(int)length Gain:(int)gain MessureMode:(CRPC80BSDKMessureMode)mode MessureStage:(CRPC80BSDKMessureStage)stage LeadOff:(BOOL)leadOff ForDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获取到心电实时波形数据
 *  @param data     波形值数组
 *  @param length     波形值数组长度 (等于0时代表最后一个包，表示实时波形结束)
 *  @param leadOff     导联脱落情况
 *  @param heartRate     实时心率
 *  @param device     设备
 */
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetRealTimeWaveData:(int *)data Length:(int)length HeartRate:(int)heartRate LeadOff:(BOOL)leadOff ForDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获取到心电测量结果
 *  @param result     心电结果
 *  @param heartRate     心率
 *  @param date     测量日期(开始时间)
 *  @param device     设备
 */
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetMessureResult:(int)result HeartRate:(int)heartRate Date:(NSString *)date ForDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获取到设备电量等级 (0~4)，等级高代表电量多
 *  @param battaryLevel     电量等级
 *  @param device     设备
 *
 */
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetBattayLevel:(int)battaryLevel ForDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取到连续测量的滤波模式
 *  @param smoothMode     滤波模式
 */
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetSmoothMode:(int)smoothMode ForDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 接收到文件传输请求
 *
 */
- (void)getFileTransmissionRequestForDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取传输文件的数据
 *  @param data     文件数据
 *  @param isCompleted     传输是否完成
 *  @param length     数据长度
 *
 */
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetTransmissionFileData:(Byte *)data DataLength:(int)length Completed:(BOOL)isCompleted ForDevice:(CRBleDevice *)device;


@end

@interface CRPC80BSDK : NSObject
/** 代理  */
@property (nonatomic, weak) id <CRPC80BSDKDelegate>delegate;
+(instancetype)shareInstance;
/** 用于处理连接后的任务 */
- (void)didConnectDevice:(CRBleDevice *)device;
/** 用于处理断开连接后续任务 */
- (void)willDisconnectWithDevice:(CRBleDevice *)device;
/** 获取到新的数据 */
- (void)appendingNewData:(NSData *)data FromDevice:(CRBleDevice *)device;

#pragma mark - 向设备发送命令
/** 同步时间 */
- (void)setTime:(NSString *)time ForDevice:(CRBleDevice *)device;
/** 查询2位设备版本号 */
- (void)queryTwoBitDeviceVersionForDevice:(CRBleDevice *)device;
/** 查询4位设备版本号 */
- (void)queryFourBitDeviceVersionForDevice:(CRBleDevice *)device;
@end
