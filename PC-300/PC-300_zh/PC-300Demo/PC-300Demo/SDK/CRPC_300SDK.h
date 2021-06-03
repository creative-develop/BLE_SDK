//
//  CRPC_300SDK.h
//  PC300SDKDemo
//
//  Created by Creative on 2017/8/8.
//  Copyright © 2017年 creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRBleDevice.h"
/* 设备电池充电状态 */
typedef NS_ENUM(NSUInteger, CRPC_300SDKBattaryChargingState)
{
    /* 不在充电 */  
    CRPC_300SDKBattaryChargingStateNotInCharging = 0,
    /* 正在充电 */
    CRPC_300SDKBattaryChargingStateInCharging,
    /* 充电完成 */
    CRPC_300SDKBattaryChargingStateChargingComplete,
};
/** 设备模块状态 */
typedef NS_ENUM(NSUInteger,  CRPC_300SDKModuleState)
{
    /* 模块测量结束 */
    CRPC_300SDKModuleStateMessurementComplete = 1,
    /* 模块忙活测量正在进行中 */
    CRPC_300SDKModuleStateBusy,
    /* 模块故障或未接入 */
    CRPC_300SDKModuleStateFail,
};

/** 血压模式 */
typedef NS_ENUM(NSUInteger, CRPC_300SDKNIBPWorkMode)
{
    /* 成人模式 */
    CRPC_300SDKNIBPWorkModeAdult = 0,
    /* 新生儿模式 */
    CRPC_300SDKNIBPWorkModeNewborns,
    /* 儿童模式 */
    CRPC_300SDKNIBPWorkModeChild,
};

@class CRPC_300SDK;
@protocol CRPC_300SDKDelegate <NSObject>
#pragma mark - --------------------------- 数据反馈
/** 获取产品名称 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getProductName:(NSString *)name FromDevice:(CRBleDevice *)device;

/*!
 *   @descrip 获取产品信息(软硬件版本,电池电量等级)
 *   @param softWareV 软件版本
 *   @param hardWareV 硬件版本
 *   @param battaryLevle 电池电量等级
 *   @param chargingState 电池充电状态
 
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getDeviceInfoWithSoftWareVersion:(NSString *)softWareV HardWareVersion:(NSString *)hardWareV BattaryLevel:(int)battaryLevle BattaryChargingState:(CRPC_300SDKBattaryChargingState)chargingState  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 收到设备查询时间的请求
 *
 */
- (void)getRequestForSetDeviceTimeFromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获取客户ID
 *  @param clientID 客户ID
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getClientID:(int)clientID FromDevice:(CRBleDevice *)device;

/*!
 * @descrip 获取血压测量的 启动/停止
 * @param start 血压测量控制.YES:表示血压测量开始 ,NO:表示血压测量停止
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK bloodPressureActionStart:(BOOL)start  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获取血压工作模式
 *  @param workMode     设备当前血压工作模式
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getNIBPWorkMode:(CRPC_300SDKNIBPWorkMode)workMode  FromDevice:(CRBleDevice *)device;

/*!
 *   @descrip 获取血压测量结果
 *   @param sys 收缩压
 *   @param dia 舒张压
 *   @param map 平均压
 *   @param pr 脉率
 *   @param hrState 心率结果.YES:心率正常，NO:心率不齐
 
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getNIBPMessurementResultWithSys:(int)sys Dia:(int)dia Map:(int)map Pr:(int)pr HeartRateState:(BOOL)hrState Rank:(int)rank  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获取到血压测量错误结果
 *  @param errorType    错误类型
 *  @param errorCode    错误编码
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getNIBPMessurementErrorWithErrorType:(int)errorType ErrorCode:(int)errorCode  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获取血压测量实时数据
 *  @param pressure    当前压力值
 *  @param heartBeat    心跳标记. YES:表示有心跳, NO:表示无心跳.
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getNIBPRealTimeDataWithPressure:(int)pressure HeartBeat:(BOOL)heartBeat  FromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取血氧波形包数据
 *  @param waveData    波形数据
 *  @param dataLength    波形数据个数
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getSpo2WaveDatas:(struct waveData *)waveData DataLength:(int)dataLength  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 血氧参数数据包
 *  @param spo2    血氧值 单位:%
 *  @param pr    脉率值 单位:bpm
 *  @param pi    灌注指数 单位:‰
 *  @param leadOff     探头是否脱落.
 *  @param mode     测量模式.0:成人模式, 1:新生儿模式, 2:动物模式
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getSpo2ParamDatasWithSpo2Value:(int)spo2 PR:(int)pr PI:(int)pi LeadOff:(BOOL)leadOff Mode:(int)mode  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获取到体温值
 *  @param tempValue     温度值
 *  @param result     温度结果，不为0时，温度值无效
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getBodyTemparature:(float)tempValue Result:(int)result  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获取到血糖值
 *  @param result    测量结果，0:正常血糖值有效. 1:偏低，血糖值无效且为0. 2:偏高，血糖值无效且为0(此参数对百捷无效)
 *  @param gluValue    血糖值 该值为实际值的10倍，例如:gluValue 为108，则实际血糖值为10.8mmol/L
 *  @param unitType    血糖值单位 0：mmol/L    1:mg/dL
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getBloodGlucoseResult:(int)result GluValue:(int)gluValue UnitType:(int)unitType FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获取到血糖仪类型 (部分PC-200可用)
 *  @param type    类型，1:爱奥乐，2：百捷
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getGlucoseDeviceType:(int)type FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 成功设置血糖仪类型 (部分PC-200/PC300可用)
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK setGlucoseDeviceTypeSuccessFromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取到尿酸
 *  @param uaValue   尿酸 该值为实际值的10倍，例如:uaValue 为108，则实际血糖值为10.8mmol/L
 *  @param unitType    尿酸值单位 0：mmol/L    1:mg/dL
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getUricAcidValue:(int)uaValue UnitType:(int)unitType FromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取到总胆固醇
 *  @param cholValue   总胆固醇 该值为实际值的10倍，例如:cholValue 为108，则实际血糖值为10.8mmol/L
 *  @param unitType    总胆固醇值单位 0：mmol/L    1:mg/dL
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getCHOLValue:(int)cholValue UnitType:(int)unitType FromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取到心电版本
 *  @param softwareV     软件版本
 *  @param hardwareV     硬件版本
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getECGSoftwareVersion:(NSString *)softwareV HardwareVersion:(NSString *)hardwareV  FromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取到心电开始和停止
 *  @param isStart     开始/停止
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getECGAction:(BOOL)isStart  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获取到心电测量波形
 *  @param data     波形数据
 *  @param length     波形数据的个数
 *  @param leadoff     脱落标志
 *  @param device     设备
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getECGWave:(struct waveData*)data DataLength:(int)length Leadoff:(BOOL)leadoff  FromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取到心电测量结果
 *  @param result     心电结果
 *  @param heartRate     心率
 *  @param device     设备
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetECGMessureResult:(int)result HeartRate:(int)heartRate ForDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获取到心电增益
 *  @param gain     心电增益
 *  @param device     设备
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetECGGain:(int)gain ForDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @descrip 获得此次测量的心电位数（8位0~255和12位0~4095）
 *  @param bit     心电波形位数
 *  @param device     设备
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetECGWaveBit:(int)bit ForDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip 获得固件版本
 *  @param state     状态(为0时，下位机先复位，可能会断开连接，需要重新连接;为1时，下位机准备就绪;为2时，代表只回应版本号;为0x0F时，无法升级指定MCU)
 *  @param hwVersion     硬件版本（为Nil代表设备为PC-100）
 *  @param swVersion     软件版本（为Nil代表设备为PC-100;为0.0.0.0时，代表没有固件）
 *  @param device     设备
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetIAPState:(int)state HardWareVersion:(NSString *)hwVersion SoftWareVersion:(NSString *)swVersion ForDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip  下位机响应启动固件更新命令
 *  @param device     设备
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetUpdateIAPResponceForDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip  获取固件更新进度
 *  @param progress     进度(0~1)
 *  @param device     设备
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetIAPUpdateProgress:(float)progress ForDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip  固件更新结束
 *  @param progress     进度(0~1)
 *  @param device     设备
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK IAPUpdateCompleteWithState:(int)state ForDevice:(CRBleDevice *)device;


/** 设备即将关机 */
- (void)aboutToShutDownDevice:(CRBleDevice *)device;

@end


@interface CRPC_300SDK : NSObject
/** 代理  */
@property (nonatomic, weak) id <CRPC_300SDKDelegate>delegate;
+(instancetype)shareInstance;
/** 用于处理连接后的任务 */
- (void)didConnectDevice:(CRBleDevice *)device;
/** 用于处理断开连接后续任务 */
- (void)willDisconnectWithDevice:(CRBleDevice *)device;
/** 获取到新的数据 */
- (void)appendingNewData:(NSData *)data FromDevice:(CRBleDevice *)device;
#pragma mark - --------------------------- 查询命令
/** 查询产品名称 */
- (void)queryForProductNameFromDevice:(CRBleDevice *)device;

/** 查询设备软硬件版本及电池电量 */
- (void)queryForDeviceVerisionInfomationFromDevice:(CRBleDevice *)device;

/** 查询最近一次设备的血压测量结果 */
- (void)queryForDeviceLastBloodPressureResultFromDevice:(CRBleDevice *)device;

/** 查询血糖仪类型 （仅部分PC-200可用）1:爱奥乐，2：百捷*/
- (void)queryForGluDeviceTypeFromDevice:(CRBleDevice *)device;


/** 查询最近一次设备的血糖测量结果 */
- (void)queryForDeviceLastBloodGlucoseResultFromDevice:(CRBleDevice *)device;

/** 查询血压工作模式 */
- (void)queryForNIBPWorkModeFromDevice:(CRBleDevice *)device;

/** 查询客户ID */
- (void)queryForClientIDFromDevice:(CRBleDevice *)device;

#pragma mark - --------------------------- 启动命令
/** 开始测量血压 */
- (void)startBloodPressureMeasurementForDevice:(CRBleDevice *)device;
/** 开始测量体温 */
- (void)startBodyTemparatureMeasurementForDevice:(CRBleDevice *)device;
/** 开始血压静态压校准 */
- (void)startStaticPressureCalibrationForDevice:(CRBleDevice *)device;

/** 设置血压工作模式 */
- (void)setNIBPWorkMode:(CRPC_300SDKNIBPWorkMode)workMode ForDevice:(CRBleDevice *)device;
/** 设置设备时间 */
- (void)setDeviceTime:(NSString *)time ForDevice:(CRBleDevice *)device;
/** 设置心电波形是否为十二位 */
- (void)setECGWaveTwelveBit:(BOOL)isTwelve ForDevice:(CRBleDevice *)device;
/** 设置血糖仪类型 （仅部分PC-200,PC-300可用）1:爱奥乐，2：百捷*/
- (void)setGluDeviceType:(int )type FromDevice:(CRBleDevice *)device;

#pragma mark - --------------------------- 停止命令
/** 停止测量血压 */
- (void)stopBloodPressureMeasurementForDevice:(CRBleDevice *)device;

#pragma mark - --------------------------- 固件升级
/*!
 *  @method
 *  @descrip 查询固件版本信息
 *  @param mode     模式.(1:准备升级固件. 2:只回应版本信息)
 *  @param device     s设备
 *
 */
- (void)queryDeviceIAPVersionWithMode:(int)mode ForDevice:(CRBleDevice *)device;
/** 开启固件更新 */
- (void)startIAPUpdateForDevice:(CRBleDevice *)device;
/** 开始发送数据 */
- (void)startTransmistIAPData:(NSData *)ipaData ForDevice:(CRBleDevice *)device;
/** 完成固件更新 */
- (void)completeIAPUpdateForDevice:(CRBleDevice *)device;

/** 停止更新 */
- (void)stopTransmistIAPDataForDevice:(CRBleDevice *)device;

@end
