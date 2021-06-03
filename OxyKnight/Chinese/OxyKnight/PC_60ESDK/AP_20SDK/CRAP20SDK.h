//
//  CRAP20SDK.h
//  CRAP20Demo
//
//  Created by Creative on 2017/7/18.
//  Copyright © 2017年 creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRBleDevice.h"



/** 血氧报警查询类型 */
typedef NS_ENUM(Byte, CRAP_20Spo2AlertConfigType)
{
    /** 报警功能的关闭/开启 状态 */
    CRAP_20Spo2AlertConfigTypeAlertState = 1,
    /** 报警功能的血氧过低阈值 */
    CRAP_20Spo2AlertConfigTypeSpo2LowThreshold,
    /** 报警功能的脉率过低阈值 */
    CRAP_20Spo2AlertConfigTypePrLowThreshold,
    /** 报警功能的脉率过高阈值 */
    CRAP_20Spo2AlertConfigTypePrHighThreshold,
    /** 搏动音的关闭/开启状态 */
    CRAP_20Spo2AlertConfigTypePulseBeepState,
    
};
/** 血氧状态 */
typedef NS_OPTIONS(Byte, CRAP_20Spo2State)
{
    /** 正常 */
    CRAP_20Spo2StateNormal = 0,
    /**  (保留) */
    CRAP_20Spo2StateProbeDisconnected = 1,
    /** 探头脱落 */
    CRAP_20Spo2StateProbeOff = CRAP_20Spo2StateProbeDisconnected << 1,
    /** (保留) */
    CRAP_20Spo2StatePulseSearching = CRAP_20Spo2StateProbeDisconnected << 2,
    /** 探头故障或使用不当 */
    CRAP_20Spo2StateCheckProbe = CRAP_20Spo2StateProbeDisconnected << 3,
    /** (保留) */
    CRAP_20Spo2StateMotionDetected = CRAP_20Spo2StateProbeDisconnected << 4,
    /** (保留) */
    CRAP_20Spo2StateLowPerfusion = CRAP_20Spo2StateProbeDisconnected << 5
};

/** 血氧状态 */
typedef NS_ENUM(Byte, CRAP_20Spo2Mode)
{
    /** 成人模式 */
    CRAP_20Spo2ModeAdultMode = 0,
    /** 新生儿模式 */
    CRAP_20Spo2ModeNewbornMode = 1,
    /** 动物模式 (保留) */
    CRAP_20Spo2ModeAnimalMode = 2
};

/** 鼻息流波形数据 */
struct nasalFlowWaveData
{
    int nasalFlowValue;
    int snoreValue;
};
/** 三轴加速度波形数据 */
struct three_AxesWaveData
{
    int acc_X;
    int acc_Y;
    int acc_Z;
};

/** 体温测量结果 */
typedef NS_ENUM(Byte, CRAP_20TemparatureResult)
{
    /** 测量结果正常 */
    CRAP_20TemparatureResultNormal = 0,
    /** 测量结果正常过低 */
    CRAP_20TemparatureResultLow = 1,
    /** 测量结果正常过高 */
    CRAP_20TemparatureResultHigh = 2
};

/** 体温单位 */
typedef NS_ENUM(Byte, CRAP_20TemparatureUnit)
{
    /** 摄氏度 */
    CRAP_20TemparatureUnitCelsius = 0,
    /** 华氏度 */
    CRAP_20TemparatureUnitFahrenheit = 1,
};

/** PC-60F 工作状态模式 */
typedef NS_ENUM(Byte, CRPC_60FWorkStatusMode)
{
    /** 点测模式 */
    CRPC_60FWorkStatusModeCommon = 1,
    /** 连测模式 */
    CRPC_60FWorkStatusModeContinious,
    /** 菜单模式 */
    CRPC_60FWorkStatusModeMenu,
};

/** PC-60F 点测阶段 */
typedef NS_ENUM(Byte, CRPC_60FCommanMessureStage)
{
    /** 无 */
    CRPC_60FCommanMessureStageNone = 0,
    /** 准备阶段 */
    CRPC_60FCommanMessureStagePrepare,
    /** 正在测量 */
    CRPC_60FCommanMessureStageMessuring,
    /** 播报结果*/
    CRPC_60FCommanMessureStageBroadcasting,
    /** 脉率分析结果 */
    CRPC_60FCommanMessureStageAnalyzing,
    /** 测量完成 */
    CRPC_60FCommanMessureStageComplete,
};


@class CRAP20SDK;

@interface CRAP20RecordModel : NSObject

/** 时间 */
@property (nonatomic, strong) NSString *time;
/** 序号 */
@property (nonatomic, assign) int recordNum;
/** 长度  */
@property (nonatomic, assign) int length;
/** 血氧数组 */
@property (nonatomic, strong) NSMutableArray <NSNumber *>*spo2Array;
/** 脉率数组 */
@property (nonatomic, strong) NSMutableArray <NSNumber *>*prArray;
@end

@protocol CRAP20SDKDelegate <NSObject>
#pragma mark -  通用回调
/** 血氧波形数据 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Wave:(struct waveData*)wave FromDevice:(CRBleDevice *)device;
/** 血氧参数 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Value:(int)spo2 PulseRate:(int)pr PI:(int)pi State:(CRAP_20Spo2State)state Mode:(CRAP_20Spo2Mode)mode BattaryLevel:(int)battaryLevel FromDevice:(CRBleDevice *)device;
/** 设备信息(软件版本号，硬件版本号，产品名称) */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceInfoForSoftWareVersion:(NSString *)softWareV HardWaveVersion:(NSString *)hardWareV ProductName:(NSString *)productName FromDevice:(CRBleDevice *)device;
#pragma mark -  AP-20,SP-20通用回调 (注：部分定制版PC-68B也具有以下部分功能)
/** 获取设备序列号 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSerialNumber:(NSString *)serialNumber FromDevice:(CRBleDevice *)device;
/** 获取设备时间 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceTime:(NSString *)deviceTime FromDevice:(CRBleDevice *)device;
/** 获取设备背光等级 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceBackLightLevel:(int)lightLevel FromDevice:(CRBleDevice *)device;
/** 获取电池电量等级 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetBartteryLevel:(int)batteryLevel FromDevice:(CRBleDevice *)device;
/** 获取血氧报警参数信息 （注：部分定制版PC-68B也具有该功能） */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2AlertInfoWithType:(CRAP_20Spo2AlertConfigType)type Value:(int)value FromDevice:(CRBleDevice *)device;
/** 获取用户ID */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetUserID:(NSString *)userID FromDevice:(CRBleDevice *)device;
/** 设置背光等级是否成功 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK DeviceBackLightLevelSettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** 设置设备时间是否成功 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK DeviceTimeSettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** 设置血氧报警参数是否成功 （注：部分定制版PC-68B也具有该功能） */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK Spo2AlertParamInfoType:(CRAP_20Spo2AlertConfigType)type SettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** 成功设置血氧参数使能 */
- (void)successdToSetSpo2ParamEnableFromDevice:(CRBleDevice *)device;
/** 成功设置血氧波形使能 */
- (void)successdToSetSpo2WaveEnableFromDevice:(CRBleDevice *)device;
#pragma mark - AP-20 使用回调
/** 数据频率为50Hz，每次一个数据 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetNasalFlowWave:(struct nasalFlowWaveData)nasalFlowWave FromDevice:(CRBleDevice *)device;
/** 获取鼻息流呼吸率 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetNasalFlowRespirationRate:(int)rate FromDevice:(CRBleDevice *)device;
/** 成功设置鼻息流参数使能 */
- (void)successdToSetNasalFlowParamEnableFromDevice:(CRBleDevice *)device;
/** 成功设置鼻息流波形使能 */
- (void)successdToSetNasalFlowWaveEnableFromDevice:(CRBleDevice *)device;

/** 获取三轴加速度波形数据 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetThree_AxesWaveData:(struct three_AxesWaveData)waveData FromDevice:(CRBleDevice *)device;
/** 成功设置三轴加速度波形使能 */
- (void)successdToSetThree_AxesWaveEnableFromDevice:(CRBleDevice *)device;

#pragma mark -  SP-20 使用回调
/** 获取温度值 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetTemparatureResult:(CRAP_20TemparatureResult)result Value:(float)tempValue Unit:(CRAP_20TemparatureUnit)unitCode FromDevice:(CRBleDevice *)device;

#pragma mark -  PC-60F 使用回调
/** 获取MAC地址 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetMACAddress:(NSString *)macAddress FromDevice:(CRBleDevice *)device;

- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetWorkStatusDataWithMode:(CRPC_60FWorkStatusMode)mode Stage:(CRPC_60FCommanMessureStage)stage Parameter:(int)para OtherParameter:(int)otherPara FromDevice:(CRBleDevice *)device;

#pragma mark -  PC-60E 使用回调 （新增菜单设置与查询，2020年09月07日）
/**
 * 菜单设置成功
 * @param failOrSuccess  00设置失败，01设置成功。 设置结果，按位与, 1为成功 (0~4位：血氧低，脉率高，脉率低，测量类型，蜂鸣器开关，旋转开关)
 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK setMenuSuccess:(BOOL)failOrSuccess FromDevice:(CRBleDevice *)device;

/**
 * 菜单查询结果
 * @param success  设置结果，按位与, 1为成功 (0~5位：血氧低，脉率高，脉率低，测量类型，蜂鸣器开关，旋转开关)
 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK
  getMenuLowSpO2:(int)lowSpO2
          highPR:(int)highPr
           lowPR:(int)lowPr
            spot:(int)spot
          beepOn:(int)beepOn
        rotateOn:(int)rotateOn
      FromDevice:(CRBleDevice *)device;


#pragma mark -  PC-68B 回调
/** 获取记录列表 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetRecordsInfoArray:(NSArray *)infoArray FromDevice:(CRBleDevice *)device;
/** 获取指定记录数据 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetRecordsData:(CRAP20RecordModel *)model FromDevice:(CRBleDevice *)device;
/** 是否删除成功 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK DidDeleteRecordsSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** 获取最新的报警参数 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK getSpo2AlertState:(BOOL)alertOn Spo2LowValue:(int)spo2Low PrLowValue:(int)prLow PrHighValue:(int)prHigh PulseBeep:(BOOL)beepOn SensorAlert:(BOOL)sensorOn ForDevice:(CRBleDevice *)device;

@end

@interface CRAP20SDK : NSObject

/** 代理  */
@property (nonatomic, weak) id <CRAP20SDKDelegate>delegate;
///** 设备是血氧否波形使能成功  */
//@property (nonatomic, assign,readonly) BOOL spo2WaveEnable;
///** 设备是否血氧参数使能成功  */
//@property (nonatomic, assign,readonly) BOOL spo2ParamEnable;

+ (instancetype)shareInstance;
/** 用于处理连接后的任务 */
- (void)didConnectDevice:(CRBleDevice *)device;
/** 用于处理断开连接后续任务 */
- (void)willDisconnectWithDevice:(CRBleDevice *)device;
/** 获取到新的数据 */
- (void)appendingNewData:(NSData *)data FromDevice:(CRBleDevice *)device;

#pragma mark - Query Command
/** 查询设备4位版本信息 */
- (void)queryForDeviceFourBitVersionForDevice:(CRBleDevice *)device;
/** 查询设备2位版本信息 */
- (void)queryForDeviceTwoBitVersionForDevice:(CRBleDevice *)device;
/** 查询设备序列号 */
- (void)queryForSerialNumberForDevice:(CRBleDevice *)device;
/** 查询设备时间 */
- (void)queryForDeviceTimeForDevice:(CRBleDevice *)device;
/** 查询设备电池电量等级 */
- (void)queryForBatteryLevelForDevice:(CRBleDevice *)device;
/** 查询设备背光等级 */
- (void)queryForBackgroundLightLevelForDevice:(CRBleDevice *)device;
/** 查询血氧警报参数信息 */
- (void)queryForSpo2AlertParamInfomation:(CRAP_20Spo2AlertConfigType)configType ForDevice:(CRBleDevice *)device;
/** 查询用户ID */
- (void)queryForUserIDForDevice:(CRBleDevice *)device;


#pragma mark - Enable Command
/** 发送血氧波形使能命令 */
- (void)sendCommandForSpo2WaveEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;
/** 发送血氧参数使能命令 */
- (void)sendCommandForSpo2ParamEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;
/** 发送鼻息流波形使能命令 */
- (void)sendCommandForNasalFlowWaveEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;
/** 发送鼻息流参数使能命令 */
- (void)sendCommandForNasalFlowParamEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;
/** 发送三轴加速度波形使能命令 */
- (void)sendCommandForThree_AxesWaveEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;

#pragma mark - Setting Command

#pragma mark - AP-20 专用方法
/** 设置背光等级 (0~5 ,0为最暗,5为最亮 )*/
- (void)setBackgroundLightLevel:(int)lightLevel  ForDevice:(CRBleDevice *)device;
/** 设置用户ID */
- (void)setUserID:(NSString *)userID ForDevice:(CRBleDevice *)device;

#pragma mark - SP-20 专用方法

#pragma mark - AP-20 ，SP-20 通用方法

/** 设置设备时间 */
- (void)setDeviceTime:(NSString *)deviceTime ForDevice:(CRBleDevice *)device;
/** 设置血氧警报参数信息 */
- (void)setSpo2AlertParamInfomation:(CRAP_20Spo2AlertConfigType)configType Value:(int)value ForDevice:(CRBleDevice *)device;

#pragma mark - PC_60F 专用方法
/** 查询蓝牙地址 */
- (void)queryForMACAddressForDevice:(CRBleDevice *)device;

#pragma mark - PC_60E 专用方法 2020年09月
/** 查询菜单 */
- (void)queryForMenuOptionsForDevice:(CRBleDevice *)device;
/**
 @description 设置菜单

 @param lowSpO2   低血氧阈值 （60~100）  0表示不设置
 @param highPr   高脉率阈值       (0~255)     0表示不设置
 @param lowPr   低脉率阈值          (0~255)    0表示不设置
 @param spot   点测或连测，1点测，2连测   0表示不设置
 @param beepOn   蜂鸣器开关,1开  ,2关         0表示不设置
 @param rotateOn   旋转开关,1开  ,2关         0表示不设置
 */
- (void)setMenuOptions:(int)lowSpO2
                highPR:(int)highPr
                 lowPR:(int)lowPr
                  spot:(int)spot
                beepOn:(int)beepOn
              rotateOn:(int)rotateOn
             forDevice:(CRBleDevice *)device;

#pragma mark - PC_68B 专用方法
/** 获取记录列表 */
- (void)queryForRecordsListForDevice:(CRBleDevice *)device;
/** 根据指定序号获取记录 */
- (void)getRecordsDataWithModel:(CRAP20RecordModel *)model ForDevice:(CRBleDevice *)device;
/** 删除记录 */
- (void)deleteAllRecordsForDevice:(CRBleDevice *)device;

/** 查询血氧报警参数 */
- (void)queryForSpo2AlertParamInfomationForDevice:(CRBleDevice *)device;
/*!
 *  @method
 *  @descrip 设置血氧警报参数信息
 *  @param alertOn   报警功能开启/关闭  YES 为开启
 *  @param spo2Low    血氧过低阈值 （85 ~ 100）
 *  @param prLow    脉率过低阈值  （25 ~ 99）
 *  @param prHigh    脉率过高阈值  （100 ~ 250）
 *  @param beepOn    搏动音开启/关闭  YES 为开启
 *  @param sensorOn    脱落警示开启/关闭  YES 为开启
 *
 */
- (void)setSpo2AlertState:(BOOL)alertOn Spo2LowValue:(int)spo2Low PrLowValue:(int)prLow PrHighValue:(int)prHigh PulseBeep:(BOOL)beepOn SensorAlert:(BOOL)sensorOn ForDevice:(CRBleDevice *)device;

@end


