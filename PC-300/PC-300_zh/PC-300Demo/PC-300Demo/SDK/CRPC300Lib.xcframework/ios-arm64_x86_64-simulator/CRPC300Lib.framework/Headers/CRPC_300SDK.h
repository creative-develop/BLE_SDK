//
//  CRPC_300SDK.h
//  PC300SDKDemo
//
//  Created by Creative on 2017/8/8.
//  Copyright © 2017年 creative. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CRBleDevice;


/* Battery state */
typedef NS_ENUM(NSUInteger, CRPC_300SDKBattaryChargingState)
{
    /* Normal */
    CRPC_300SDKBattaryChargingStateNotInCharging = 0,
    /* Charge */
    CRPC_300SDKBattaryChargingStateInCharging,
    /* full charge */
    CRPC_300SDKBattaryChargingStateChargingComplete,
};
/** Module state */
typedef NS_ENUM(NSUInteger,  CRPC_300SDKModuleState)
{
    /* Measurement completed */
    CRPC_300SDKModuleStateMessurementComplete = 1,
    /* 模块忙活测量正在进行中 */
    CRPC_300SDKModuleStateBusy,
    /* Error */
    CRPC_300SDKModuleStateFail,
};

/** BP mode */
typedef NS_ENUM(NSUInteger, CRPC_300SDKNIBPWorkMode)
{
    /* adult mode */
    CRPC_300SDKNIBPWorkModeAdult = 0,
    /* baby mode */
    CRPC_300SDKNIBPWorkModeNewborns,
    /* kid mode */
    CRPC_300SDKNIBPWorkModeChild,
};

/** temp   mode */
typedef NS_ENUM(NSUInteger, CRPC_300SDKBodyTemperatureMode)
{
    /* 耳温模式 */
    CRPC_300SDKBodyTemperatureModeEar = 1,
    /* 成人额温模式 */
    CRPC_300SDKBodyTemperatureModeAdultForehead,
    /* 儿童额温模式 */
    CRPC_300SDKBodyTemperatureModeChildForehead,
    /* 物温模式 */
    CRPC_300SDKBodyTemperatureModeThings,
};

@class CRPC_300SDK;
@protocol CRPC_300SDKDelegate <NSObject>
#pragma mark - --------------------------- response
/** product name */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getProductName:(NSString *)name FromDevice:(CRBleDevice *)device;

/*!
 *   @brief product information
 *   @param softWareV software version
 *   @param hardWareV hardware version
 *   @param battaryLevle battery level
 *   @param chargingState battery state
 
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getDeviceInfoWithSoftWareVersion:(NSString *)softWareV HardWareVersion:(NSString *)hardWareV BattaryLevel:(int)battaryLevle BattaryChargingState:(CRPC_300SDKBattaryChargingState)chargingState  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief request for sync device time
 *
 */
- (void)getRequestForSetDeviceTimeFromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief get client id
 *  @param clientID client id
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getClientID:(int)clientID FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip get temp mode
 *  @param mode mode
 *  @param unit 1  ℃，2  °F
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getBodyTemperatureMode:(CRPC_300SDKBodyTemperatureMode)mode Unit:(int)unit FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip set temp mode
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK setBodyTemperatureModeSuccessFromDevice:(CRBleDevice *)device;


/*!
 * @brief response of start or stop to meassure
 * @param start BP state.   YES: start  ,NO: stop
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK bloodPressureActionStart:(BOOL)start  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief BP work mode
 *  @param workMode     the device current BP work mode
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getNIBPWorkMode:(CRPC_300SDKNIBPWorkMode)workMode  FromDevice:(CRBleDevice *)device;

/*!
 *   @brief BP results
 *   @param sys SYS
 *   @param dia DIA
 *   @param map mean pressure
 *   @param pr Pulse rate
 *   @param hrState HR result. YES: ，NO:心率不齐
 
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getNIBPMessurementResultWithSys:(int)sys Dia:(int)dia Map:(int)map Pr:(int)pr HeartRateState:(BOOL)hrState Rank:(int)rank  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief BP measurement error occurred
 *  @param errorType    error type
 *  @param errorCode    error code
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getNIBPMessurementErrorWithErrorType:(int)errorType ErrorCode:(int)errorCode  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief real-time pressure
 *  @param pressure    current pressure
 *  @param heartBeat    heartbeat. YES: , NO:
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getNIBPRealTimeDataWithPressure:(int)pressure HeartBeat:(BOOL)heartBeat  FromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @brief Oxygen waveform data
 *  @param waveData    waveform data
 *  @param dataLength    Length
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getSpo2WaveDatas:(struct waveData *)waveData DataLength:(int)dataLength  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief Oxygen parameters
 *  @param spo2    SpO2  Unit: %
 *  @param pr        PR     Unit: bpm or  /min
 *  @param pi       PI Unit:‰
 *  @param leadOff     lead state: YES: lead off NO: lead on
 *  @param mode    meassurement mode. 0:adult, 1:baby, 2:animal
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getSpo2ParamDatasWithSpo2Value:(int)spo2 PR:(int)pr PI:(int)pi LeadOff:(BOOL)leadOff Mode:(int)mode  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief temperature
 *  @param tempValue     temperature value
 *  @param result     result，if result > 0, invalid
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getBodyTemparature:(float)tempValue Result:(int)result  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief Glucose
 *  @param result     0: normal. 1:low，invalid and value is 0.  2: high，invalid and value is 0   (百捷invalid)
 *  @param gluValue    value * 10，e.g.: the gluValue is 108， really glucose value = 108 * 0.1 mmol/L
 *  @param unitType    unit 0：mmol/L    1:mg/dL
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getBloodGlucoseResult:(int)result GluValue:(int)gluValue UnitType:(int)unitType FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief the data from Which Glucose meter (some PC200 is supported)
 *  @param type    type，1:爱奥乐，2：百捷
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getGlucoseDeviceType:(int)type FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief the glucose meter type setting success (some PC200 and some PC300 is supported)
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK setGlucoseDeviceTypeSuccessFromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @brief uric acid
 *  @param uaValue   value * 10，e.g.: uaValue is 108,  the really uric acid value is 10.8mmol/L
 *  @param unitType    unit 0：mmol/L    1:mg/dL
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getUricAcidValue:(int)uaValue UnitType:(int)unitType FromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @brief cholesterol
 *  @param cholValue   value * 10，例如:cholValue is 108，the really cholesterol value is 10.8mmol/L
 *  @param unitType    unit 0：mmol/L    1:mg/dL
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getCHOLValue:(int)cholValue UnitType:(int)unitType FromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @brief ECG version
 *  @param softwareV   software
 *  @param hardwareV     hardware
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getECGSoftwareVersion:(NSString *)softwareV HardwareVersion:(NSString *)hardwareV  FromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @brief response of start or stop to meassure
 *  @param isStart     start or stop
 *
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getECGAction:(BOOL)isStart  FromDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @descrip ECG waveform
 *  @param data     waveform data
 *  @param length     length
 *  @param leadoff     0: lead on  1: lead off
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getECGWave:(struct waveData*)data DataLength:(int)length Leadoff:(BOOL)leadoff  FromDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @brief ECG measurement result
 *  @param result     result
 *  @param heartRate     HR
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetECGMessureResult:(int)result HeartRate:(int)heartRate ForDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @brief gain of ECG
 *  @param gain     gain
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetECGGain:(int)gain ForDevice:(CRBleDevice *)device;


/*!
 *  @method
 *  @brief 获得此次测量的心电位数（8位0~255和12位0~4095）
 *  @param bit     心电波形位数
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetECGWaveBit:(int)bit ForDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief 获得固件版本 hardware version
 *  @param state     状态(为0时，下位机先复位，可能会断开连接，需要重新连接;为1时，下位机准备就绪;为2时，代表只回应版本号;为0x0F时，无法升级指定MCU)
 *  @param hwVersion     硬件版本（为Nil代表设备为PC-100）
 *  @param swVersion     软件版本（为Nil代表设备为PC-100;为0.0.0.0时，代表没有固件）
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetIAPState:(int)state HardWareVersion:(NSString *)hwVersion SoftWareVersion:(NSString *)swVersion ForDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief  下位机响应启动固件更新命令
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetUpdateIAPResponceForDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief  获取固件更新进度
 *  @param progress     进度(0~1)
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetIAPUpdateProgress:(float)progress ForDevice:(CRBleDevice *)device;

/*!
 *  @method
 *  @brief  固件更新结束
 */
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK IAPUpdateCompleteWithState:(int)state ForDevice:(CRBleDevice *)device;



/*!
 *  @method
 *  @brief  设备即将关机
 */
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

#pragma mark - --------------------------- 查询命令 / query command
/** 查询产品名称 / query product name */
- (void)queryForProductNameFromDevice:(CRBleDevice *)device;

/** 查询设备软硬件版本及电池电量 / query version and battery level */
- (void)queryForDeviceVerisionInfomationFromDevice:(CRBleDevice *)device;

/** 查询最近一次设备的血压测量结果  / query the latest BP result*/
- (void)queryForDeviceLastBloodPressureResultFromDevice:(CRBleDevice *)device;

/** 查询血糖仪类型 （仅部分PC-200可用）/ query type of glucose meter    1:爱奥乐，2：百捷*/
- (void)queryForGluDeviceTypeFromDevice:(CRBleDevice *)device;

/** 查询最近一次设备的血糖测量结果 / query the latest Glucose result */
- (void)queryForDeviceLastBloodGlucoseResultFromDevice:(CRBleDevice *)device;

/** 查询血压工作模式 /  query the work mode of BP measurement */
- (void)queryForNIBPWorkModeFromDevice:(CRBleDevice *)device;

/** 查询客户ID  / query client id*/
- (void)queryForClientIDFromDevice:(CRBleDevice *)device;

/** query temp  mode */
- (void)queryForBodyTemperatureModeFromDevice:(CRBleDevice *)device;

/** set temp mode（unit：1 ℃；2 ℉） */
- (void)setBodyTemperatureMode:(CRPC_300SDKBodyTemperatureMode)mode Unit:(int)unit ForDevice:(CRBleDevice *)device;

#pragma mark - --------------------------- 启动命令 / start command
/** 开始测量血压 / start  BP measurement*/
- (void)startBloodPressureMeasurementForDevice:(CRBleDevice *)device;

/** 开始测量体温 / start  temperature measurement*/
- (void)startBodyTemparatureMeasurementForDevice:(CRBleDevice *)device;

/** 开始血压静态压校准 /  Start blood pressure static pressure calibration*/
- (void)startStaticPressureCalibrationForDevice:(CRBleDevice *)device;

/** 设置血压工作模式 / set work mode of BP measurement */
- (void)setNIBPWorkMode:(CRPC_300SDKNIBPWorkMode)workMode ForDevice:(CRBleDevice *)device;

/** 设置设备时间  /  set time*/
- (void)setDeviceTime:(NSString *)time ForDevice:(CRBleDevice *)device;

/** 设置心电波形是否为十二位 / set bit */
- (void)setECGWaveTwelveBit:(BOOL)isTwelve ForDevice:(CRBleDevice *)device;

/** 设置血糖仪类型 （仅部分PC-200,PC-300可用）/ set the type of glucose meter  1:爱奥乐，2：百捷*/
- (void)setGluDeviceType:(int )type FromDevice:(CRBleDevice *)device;

#pragma mark - --------------------------- 停止命令
/** 停止测量血压 / stop BP measurement*/
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
