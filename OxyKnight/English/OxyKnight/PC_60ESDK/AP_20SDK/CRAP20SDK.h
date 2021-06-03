//
//  CRAP20SDK.h
//  CRAP20Demo
//
//  Created by Creative on 2017/7/18.
//  Copyright © 2017年 creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRBleDevice.h"



/** Spo2 alarm query type */
typedef NS_ENUM(Byte, CRAP_20Spo2AlertConfigType)
{
    /** The off/on status of the alarm function */
    CRAP_20Spo2AlertConfigTypeAlertState = 1,
    /** Low blood oxygen threshold for alarm function */
    CRAP_20Spo2AlertConfigTypeSpo2LowThreshold,
    /** The pulse rate of the alarm function is too low threshold */
    CRAP_20Spo2AlertConfigTypePrLowThreshold,
    /** High pulse rate threshold for alarm function */
    CRAP_20Spo2AlertConfigTypePrHighThreshold,
    /** Pulsating sound off/on status */
    CRAP_20Spo2AlertConfigTypePulseBeepState,
    
};
/** Spo2 State */
typedef NS_OPTIONS(Byte, CRAP_20Spo2State)
{
    /** normal */
    CRAP_20Spo2StateNormal = 0,
    /**  (Keep) */
    CRAP_20Spo2StateProbeDisconnected = 1,
    /** The probe falls off */
    CRAP_20Spo2StateProbeOff = CRAP_20Spo2StateProbeDisconnected << 1,
    /** (Keep) */
    CRAP_20Spo2StatePulseSearching = CRAP_20Spo2StateProbeDisconnected << 2,
    /** Probe failure or improper use */
    CRAP_20Spo2StateCheckProbe = CRAP_20Spo2StateProbeDisconnected << 3,
    /** (Keep) */
    CRAP_20Spo2StateMotionDetected = CRAP_20Spo2StateProbeDisconnected << 4,
    /** (Keep) */
    CRAP_20Spo2StateLowPerfusion = CRAP_20Spo2StateProbeDisconnected << 5
};

/** Spo2 Mode */
typedef NS_ENUM(Byte, CRAP_20Spo2Mode)
{
    /** Adult Mode */
    CRAP_20Spo2ModeAdultMode = 0,
    /** Newborn Mode */
    CRAP_20Spo2ModeNewbornMode = 1,
    /** Animal Mode (Keep) */
    CRAP_20Spo2ModeAnimalMode = 2
};

/** Nasal flow waveform data */
struct nasalFlowWaveData
{
    int nasalFlowValue;
    int snoreValue;
};
/** Three-axis acceleration waveform data */
struct three_AxesWaveData
{
    int acc_X;
    int acc_Y;
    int acc_Z;
};

/** Body temperature measurement result */
typedef NS_ENUM(Byte, CRAP_20TemparatureResult)
{
    /** normal */
    CRAP_20TemparatureResultNormal = 0,
    /** Too low */
    CRAP_20TemparatureResultLow = 1,
    /** Too high */
    CRAP_20TemparatureResultHigh = 2
};

/** Body temperature unit */
typedef NS_ENUM(Byte, CRAP_20TemparatureUnit)
{
    /** Celsius */
    CRAP_20TemparatureUnitCelsius = 0,
    /** Fahrenheit */
    CRAP_20TemparatureUnitFahrenheit = 1,
};

/** PC-60F Work Status Mode */
typedef NS_ENUM(Byte, CRPC_60FWorkStatusMode)
{
    /** Common Mode */
    CRPC_60FWorkStatusModeCommon = 1,
    /** Continious Mode */
    CRPC_60FWorkStatusModeContinious,
    /** Menu Mode */
    CRPC_60FWorkStatusModeMenu,
};

/** PC-60F Common Stage */
typedef NS_ENUM(Byte, CRPC_60FCommanMessureStage)
{
    /** None */
    CRPC_60FCommanMessureStageNone = 0,
    /** Prepare */
    CRPC_60FCommanMessureStagePrepare,
    /** Messuring */
    CRPC_60FCommanMessureStageMessuring,
    /** Broadcasting*/
    CRPC_60FCommanMessureStageBroadcasting,
    /** Analyzing */
    CRPC_60FCommanMessureStageAnalyzing,
    /** Complete */
    CRPC_60FCommanMessureStageComplete,
};


@class CRAP20SDK;

@interface CRAP20RecordModel : NSObject

/** Time */
@property (nonatomic, strong) NSString *time;
/** recordNum */
@property (nonatomic, assign) int recordNum;
/** length  */
@property (nonatomic, assign) int length;
/** spo2 Array */
@property (nonatomic, strong) NSMutableArray <NSNumber *>*spo2Array;
/** pr Array */
@property (nonatomic, strong) NSMutableArray <NSNumber *>*prArray;
@end

@protocol CRAP20SDKDelegate <NSObject>
#pragma mark -  General callback
/** Blood oxygen waveform data */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Wave:(struct waveData*)wave FromDevice:(CRBleDevice *)device;
/** Blood oxygen parameters */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Value:(int)spo2 PulseRate:(int)pr PI:(int)pi State:(CRAP_20Spo2State)state Mode:(CRAP_20Spo2Mode)mode BattaryLevel:(int)battaryLevel FromDevice:(CRBleDevice *)device;
/** Device information (software version number, hardware version number, product name) */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceInfoForSoftWareVersion:(NSString *)softWareV HardWaveVersion:(NSString *)hardWareV ProductName:(NSString *)productName FromDevice:(CRBleDevice *)device;
#pragma mark -  AP-20,SP-20 General callback (Note: Some customized versions of PC-68B also have some of the following functions)
/** Get device serial number */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSerialNumber:(NSString *)serialNumber FromDevice:(CRBleDevice *)device;
/** Get device time */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceTime:(NSString *)deviceTime FromDevice:(CRBleDevice *)device;
/** Get device backlight level */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceBackLightLevel:(int)lightLevel FromDevice:(CRBleDevice *)device;
/** Get battery level */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetBartteryLevel:(int)batteryLevel FromDevice:(CRBleDevice *)device;
/** Get blood oxygen alarm parameter information (Note: Some customized versions of PC-68B also have this function) */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2AlertInfoWithType:(CRAP_20Spo2AlertConfigType)type Value:(int)value FromDevice:(CRBleDevice *)device;
/** Get user ID */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetUserID:(NSString *)userID FromDevice:(CRBleDevice *)device;
/** Whether the setting of the backlight level is successful */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK DeviceBackLightLevelSettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** Whether setting the device time is successful */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK DeviceTimeSettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** Whether the setting of blood oxygen alarm parameters is successful (Note: Some customized versions of PC-68B also have this function) */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK Spo2AlertParamInfoType:(CRAP_20Spo2AlertConfigType)type SettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** Successfully set the blood oxygen parameter enable */
- (void)successdToSetSpo2ParamEnableFromDevice:(CRBleDevice *)device;
/** Successfully set the blood oxygen waveform enable */
- (void)successdToSetSpo2WaveEnableFromDevice:(CRBleDevice *)device;
#pragma mark - AP-20 callback
/** The data frequency is 50Hz, one data at a time */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetNasalFlowWave:(struct nasalFlowWaveData)nasalFlowWave FromDevice:(CRBleDevice *)device;
/** Get the breath rate of nasal flow */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetNasalFlowRespirationRate:(int)rate FromDevice:(CRBleDevice *)device;
/** Successfully set nasal flow parameter enable */
- (void)successdToSetNasalFlowParamEnableFromDevice:(CRBleDevice *)device;
/** Successfully set the sniff wave waveform enable */
- (void)successdToSetNasalFlowWaveEnableFromDevice:(CRBleDevice *)device;

/** Obtain three-axis acceleration waveform data */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetThree_AxesWaveData:(struct three_AxesWaveData)waveData FromDevice:(CRBleDevice *)device;
/** Successfully set the three-axis acceleration waveform enable */
- (void)successdToSetThree_AxesWaveEnableFromDevice:(CRBleDevice *)device;

#pragma mark -  SP-20
/** Get temperature value */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetTemparatureResult:(CRAP_20TemparatureResult)result Value:(float)tempValue Unit:(CRAP_20TemparatureUnit)unitCode FromDevice:(CRBleDevice *)device;

#pragma mark -  PC-60F
/** Get MAC address */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetMACAddress:(NSString *)macAddress FromDevice:(CRBleDevice *)device;

- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetWorkStatusDataWithMode:(CRPC_60FWorkStatusMode)mode Stage:(CRPC_60FCommanMessureStage)stage Parameter:(int)para OtherParameter:(int)otherPara FromDevice:(CRBleDevice *)device;

#pragma mark -  PC-60E Use callback (new menu settings and query, September 07, 2020)
/**
 * The menu is set successfully
 * @param failOrSuccess  The setting of 00 failed, and the setting of 01 succeeded. Set result, press bit and, 1 means success (0~4 digits: low blood oxygen, high pulse rate, low pulse rate, measurement type, buzzer switch, rotary switch)
 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK setMenuSuccess:(BOOL)failOrSuccess FromDevice:(CRBleDevice *)device;

/**
 * Menu query results
 * @param success  Set the result, press bit and, 1 means success (0~5 digits: low blood oxygen, high pulse rate, low pulse rate, measurement type, buzzer switch, rotary switch)
 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK
  getMenuLowSpO2:(int)lowSpO2
          highPR:(int)highPr
           lowPR:(int)lowPr
            spot:(int)spot
          beepOn:(int)beepOn
        rotateOn:(int)rotateOn
      FromDevice:(CRBleDevice *)device;


#pragma mark -  PC-68B callback
/** Get a list of records */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetRecordsInfoArray:(NSArray *)infoArray FromDevice:(CRBleDevice *)device;
/** Get the specified record data */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetRecordsData:(CRAP20RecordModel *)model FromDevice:(CRBleDevice *)device;
/** Whether the deletion is successful */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK DidDeleteRecordsSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** Get the latest alarm parameters */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK getSpo2AlertState:(BOOL)alertOn Spo2LowValue:(int)spo2Low PrLowValue:(int)prLow PrHighValue:(int)prHigh PulseBeep:(BOOL)beepOn SensorAlert:(BOOL)sensorOn ForDevice:(CRBleDevice *)device;

@end

@interface CRAP20SDK : NSObject

/** delegate  */
@property (nonatomic, weak) id <CRAP20SDKDelegate>delegate;
///** Whether the device is oximetry waveform enabled successfully  */
//@property (nonatomic, assign,readonly) BOOL spo2WaveEnable;
///** Whether the device has successfully enabled the blood oxygen parameters  */
//@property (nonatomic, assign,readonly) BOOL spo2ParamEnable;

+ (instancetype)shareInstance;
/** Used to handle connected tasks */
- (void)didConnectDevice:(CRBleDevice *)device;
/** Used to handle the subsequent tasks of disconnection */
- (void)willDisconnectWithDevice:(CRBleDevice *)device;
/** Get new data */
- (void)appendingNewData:(NSData *)data FromDevice:(CRBleDevice *)device;

#pragma mark - Query Command
/** Query the 4-digit version information of the device */
- (void)queryForDeviceFourBitVersionForDevice:(CRBleDevice *)device;
/** Query the 2-digit version information of the device */
- (void)queryForDeviceTwoBitVersionForDevice:(CRBleDevice *)device;
/** Query device serial number */
- (void)queryForSerialNumberForDevice:(CRBleDevice *)device;
/** Query device time */
- (void)queryForDeviceTimeForDevice:(CRBleDevice *)device;
/** Query device battery level */
- (void)queryForBatteryLevelForDevice:(CRBleDevice *)device;
/** Query device backlight level */
- (void)queryForBackgroundLightLevelForDevice:(CRBleDevice *)device;
/** Query blood oxygen alarm parameter information */
- (void)queryForSpo2AlertParamInfomation:(CRAP_20Spo2AlertConfigType)configType ForDevice:(CRBleDevice *)device;
/** Query user ID */
- (void)queryForUserIDForDevice:(CRBleDevice *)device;


#pragma mark - Enable Command
/** Send the blood oxygen waveform enable command */
- (void)sendCommandForSpo2WaveEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;
/** Send blood oxygen parameter enable command */
- (void)sendCommandForSpo2ParamEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;
/** Send sniff wave waveform enable command */
- (void)sendCommandForNasalFlowWaveEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;
/** Send snuff parameter enable command */
- (void)sendCommandForNasalFlowParamEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;
/** Send three-axis acceleration waveform enable command */
- (void)sendCommandForThree_AxesWaveEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;

#pragma mark - Setting Command

#pragma mark - AP-20 Dedicated method
/** Set the backlight level (0~5, 0 is the darkest, 5 is the brightest)*/
- (void)setBackgroundLightLevel:(int)lightLevel  ForDevice:(CRBleDevice *)device;
/** Set user ID */
- (void)setUserID:(NSString *)userID ForDevice:(CRBleDevice *)device;

#pragma mark - SP-20 Dedicated method

#pragma mark - AP-20 ，SP-20 method

/** Set device time */
- (void)setDeviceTime:(NSString *)deviceTime ForDevice:(CRBleDevice *)device;
/** Set blood oxygen alarm parameter information */
- (void)setSpo2AlertParamInfomation:(CRAP_20Spo2AlertConfigType)configType Value:(int)value ForDevice:(CRBleDevice *)device;

#pragma mark - PC_60F Dedicated method
/** Query Bluetooth address */
- (void)queryForMACAddressForDevice:(CRBleDevice *)device;

#pragma mark - PC_60E Dedicated method September 2020
/** Query menu */
- (void)queryForMenuOptionsForDevice:(CRBleDevice *)device;
/**
 @description setting menu

 @param lowSpO2 Low blood oxygen threshold (60~100) 0 means not set
 @param highPr High pulse rate threshold (0~255) 0 means not set
 @param lowPr Low pulse rate threshold (0~255) 0 means not set
 @param spot Spot measurement or continuous measurement, 1 spot measurement, 2 continuous measurement                           0 means no setting
 @param beepOn Buzzer switch, 1 on, 2 off, 0 means not set
 @param rotateOn Rotary switch, 1 open, 2 close 0 means not set
 */
- (void)setMenuOptions:(int)lowSpO2
                highPR:(int)highPr
                 lowPR:(int)lowPr
                  spot:(int)spot
                beepOn:(int)beepOn
              rotateOn:(int)rotateOn
             forDevice:(CRBleDevice *)device;

#pragma mark - PC_68B Dedicated method
/** Get a list of records */
- (void)queryForRecordsListForDevice:(CRBleDevice *)device;
/** Obtain records according to the specified serial number */
- (void)getRecordsDataWithModel:(CRAP20RecordModel *)model ForDevice:(CRBleDevice *)device;
/** Delete Record */
- (void)deleteAllRecordsForDevice:(CRBleDevice *)device;

/** Query blood oxygen alarm parameters */
- (void)queryForSpo2AlertParamInfomationForDevice:(CRBleDevice *)device;
/*!
 * @method
 * @descrip Set blood oxygen alarm parameter information
 * @param alertOn The alarm function is turned on/off YES is turned on
 * @param spo2Low Threshold for hypoxemia (85 ~ 100)
 * @param prLow pulse rate too low threshold (25 ~ 99)
 * @param prHigh Pulse rate is too high threshold (100 ~ 250)
 * @param beepOn Pulsating sound on/off YES is on
 * @param sensorOn Falling off warning on/off YES is on
 *
 */
- (void)setSpo2AlertState:(BOOL)alertOn Spo2LowValue:(int)spo2Low PrLowValue:(int)prLow PrHighValue:(int)prHigh PulseBeep:(BOOL)beepOn SensorAlert:(BOOL)sensorOn ForDevice:(CRBleDevice *)device;

@end


