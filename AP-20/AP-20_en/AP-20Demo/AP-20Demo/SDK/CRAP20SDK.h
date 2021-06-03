//
//  CRAP20SDK.h
//  CRAP20Demo
//
//  Created by Creative on 2017/7/18.
//  Copyright © 2017年 creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRBleDevice.h"

/** Blood oxygen alarm query type */
typedef NS_ENUM(Byte, CRAP_20Spo2AlertConfigType)
{
    /** The off/on status of the alarm function */
    CRAP_20Spo2AlertConfigTypeAlertState = 1,
    /** The low blood oxygen threshold of the alarm function */
    CRAP_20Spo2AlertConfigTypeSpo2LowThreshold,
    /** The pulse rate of the alarm function is too low threshold */
    CRAP_20Spo2AlertConfigTypePrLowThreshold,
    /** The high pulse rate threshold of the alarm function */
    CRAP_20Spo2AlertConfigTypePrHighThreshold,
    /** The off/on state of the beating sound */
    CRAP_20Spo2AlertConfigTypePulseBeepState,
    
};
/** Blood oxygen status */
typedef NS_OPTIONS(Byte, CRAP_20Spo2State)
{
    /** Normal */
    CRAP_20Spo2StateNormal = 0,
    /**  (reserved) */
    CRAP_20Spo2StateProbeDisconnected = 1,
    /** Probe falls off */
    CRAP_20Spo2StateProbeOff = CRAP_20Spo2StateProbeDisconnected << 1,
    /** (reserved) */
    CRAP_20Spo2StatePulseSearching = CRAP_20Spo2StateProbeDisconnected << 2,
    /** Probe failure or improper us */
    CRAP_20Spo2StateCheckProbe = CRAP_20Spo2StateProbeDisconnected << 3,
    /** (reserved) */
    CRAP_20Spo2StateMotionDetected = CRAP_20Spo2StateProbeDisconnected << 4,
    /** (reserved) */
    CRAP_20Spo2StateLowPerfusion = CRAP_20Spo2StateProbeDisconnected << 5
};

/** Blood oxygen status */
typedef NS_ENUM(Byte, CRAP_20Spo2Mode)
{
    /** Adult mode */
    CRAP_20Spo2ModeAdultMode = 0,
    /** Neonatal mode  */
    CRAP_20Spo2ModeNewbornMode = 1,
    /** Animal mode (reserved) */
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
    /** The measurement result is normal. */
    CRAP_20TemparatureResultNormal = 0,
    /** The measurement result is normally too low. */
    CRAP_20TemparatureResultLow = 1,
    /** The measurement result is normally too high. */
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

/** PC-60F working status mode. */
typedef NS_ENUM(Byte, CRPC_60FWorkStatusMode)
{
    /** Spot measurement mode. */
    CRPC_60FWorkStatusModeCommon = 1,
    /** Continuous measurement mode. */
    CRPC_60FWorkStatusModeContinious,
    /** Menu mode. */
    CRPC_60FWorkStatusModeMenu,
};

/** PC-60F spot measurement stage. */
typedef NS_ENUM(Byte, CRPC_60FCommanMessureStage)
{
    /** None */
    CRPC_60FCommanMessureStageNone = 0,
    /** Preparation stage. */
    CRPC_60FCommanMessureStagePrepare,
    /** Measuring. */
    CRPC_60FCommanMessureStageMessuring,
    /** Broadcast the results. */
    CRPC_60FCommanMessureStageBroadcasting,
    /** Pulse rate analysis result. */
    CRPC_60FCommanMessureStageAnalyzing,
    /** The measurement is complete. */
    CRPC_60FCommanMessureStageComplete,
};


@class CRAP20SDK;

@interface CRAP20RecordModel : NSObject

/** time. */
@property (nonatomic, strong) NSString *time;
/** Serial number. */
@property (nonatomic, assign) int recordNum;
/** length.  */
@property (nonatomic, assign) int length;
/** Blood oxygen array. */
@property (nonatomic, strong) NSMutableArray <NSNumber *>*spo2Array;
/** Pulse rate array. */
@property (nonatomic, strong) NSMutableArray <NSNumber *>*prArray;
@end

@protocol CRAP20SDKDelegate <NSObject>

@optional
#pragma mark - General callback.
/** Blood oxygen waveform data. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Wave:(struct waveData*)wave FromDevice:(CRBleDevice *)device;
/** Blood oxygen parameters. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Value:(int)spo2 PulseRate:(int)pr PI:(int)pi State:(CRAP_20Spo2State)state Mode:(CRAP_20Spo2Mode)mode BattaryLevel:(int)battaryLevel FromDevice:(CRBleDevice *)device;
/** Device information (software version number, hardware version number, product name). */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceInfoForSoftWareVersion:(NSString *)softWareV HardWaveVersion:(NSString *)hardWareV ProductName:(NSString *)productName FromDevice:(CRBleDevice *)device;
#pragma mark -  AP-20,SP-20 General callback. (Note: Part of the customized version of PC-68B also has some of the following functions.)
/** Get the device serial number. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSerialNumber:(NSString *)serialNumber FromDevice:(CRBleDevice *)device;
/** Get the device time. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceTime:(NSString *)deviceTime FromDevice:(CRBleDevice *)device;
/** Get the device backlight level. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceBackLightLevel:(int)lightLevel FromDevice:(CRBleDevice *)device;
/** Get the battery level. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetBartteryLevel:(int)batteryLevel FromDevice:(CRBleDevice *)device;
/** Get blood oxygen alarm parameter information (Note: Some customized versions of PC-68B also have this function). */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2AlertInfoWithType:(CRAP_20Spo2AlertConfigType)type Value:(int)value FromDevice:(CRBleDevice *)device;
/** Get the user ID. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetUserID:(NSString *)userID FromDevice:(CRBleDevice *)device;
/** Is the user ID set successfully? */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK UserIDSettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** Is the backlight level setting successful? */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK DeviceBackLightLevelSettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** Is the device time setting successful? */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK DeviceTimeSettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** Is the setting of blood oxygen alarm parameters successful? (Note: Some customized versions of PC-68B also have this function)*/
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK Spo2AlertParamInfoType:(CRAP_20Spo2AlertConfigType)type SettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** Successfully set the blood oxygen parameter enable. */
- (void)successdToSetSpo2ParamEnableFromDevice:(CRBleDevice *)device;
/** Successfully set the blood oxygen waveform enable. */
- (void)successdToSetSpo2WaveEnableFromDevice:(CRBleDevice *)device;
#pragma mark - AP-20 Private callback
/** The data frequency is 50 Hz, one data at a time.*/
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetNasalFlowWave:(struct nasalFlowWaveData)nasalFlowWave FromDevice:(CRBleDevice *)device;
/** Get the breath rate of nasal flow. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetNasalFlowRespirationRate:(int)rate FromDevice:(CRBleDevice *)device;
/** Successfully set the sniff flow parameter enable. */
- (void)successdToSetNasalFlowParamEnableFromDevice:(CRBleDevice *)device;
/** Successfully set the sniff flow waveform enable. */
- (void)successdToSetNasalFlowWaveEnableFromDevice:(CRBleDevice *)device;

/** Acquire three-axis acceleration waveform data. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetThree_AxesWaveData:(struct three_AxesWaveData)waveData FromDevice:(CRBleDevice *)device;
/** Successfully set the three-axis acceleration waveform enable. */
- (void)successdToSetThree_AxesWaveEnableFromDevice:(CRBleDevice *)device;

#pragma mark -  SP-20 Private callback
/** Get the temperature value. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetTemparatureResult:(CRAP_20TemparatureResult)result Value:(float)tempValue Unit:(CRAP_20TemparatureUnit)unitCode FromDevice:(CRBleDevice *)device;

#pragma mark -  PC-60F Private callback
/** Obtain the MAC address. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetMACAddress:(NSString *)macAddress FromDevice:(CRBleDevice *)device;
/** Get measurement status and mode. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetWorkStatusDataWithMode:(CRPC_60FWorkStatusMode)mode Stage:(CRPC_60FCommanMessureStage)stage Parameter:(int)para OtherParameter:(int)otherPara FromDevice:(CRBleDevice *)device;

#pragma mark -  PC-60E Private callback
/**
 * The menu is set successfully.
 * @param failOrSuccess  00:Setting failure.，01:Setting success.
 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK setMenuSuccess:(BOOL)failOrSuccess FromDevice:(CRBleDevice *)device;

/**
 * Menu query results.
 * Low blood oxygen(lowSpO2), high pulse rate(highPr), low pulse rate(lowPr), measurement type(spot), buzzer switch(beepOn), rotary switch(rotateOn).
 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK
  getMenuLowSpO2:(int)lowSpO2
          highPR:(int)highPr
           lowPR:(int)lowPr
            spot:(int)spot
          beepOn:(int)beepOn
        rotateOn:(int)rotateOn
      FromDevice:(CRBleDevice *)device;


#pragma mark -  PC-68B Private callback
/** Get a list of records. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetRecordsInfoArray:(NSArray *)infoArray FromDevice:(CRBleDevice *)device;
/** Get the specified record data. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetRecordsData:(CRAP20RecordModel *)model FromDevice:(CRBleDevice *)device;
/** Was the deletion successful? */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK DidDeleteRecordsSuccess:(BOOL)success FromDevice:(CRBleDevice *)device;
/** Get the latest alarm parameters. */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK getSpo2AlertState:(BOOL)alertOn Spo2LowValue:(int)spo2Low PrLowValue:(int)prLow PrHighValue:(int)prHigh PulseBeep:(BOOL)beepOn SensorAlert:(BOOL)sensorOn ForDevice:(CRBleDevice *)device;

@end

@interface CRAP20SDK : NSObject

/** delegate  */
@property (nonatomic, weak) id <CRAP20SDKDelegate>delegate;

+ (instancetype)shareInstance;
/** Used to handle tasks after connection. */
- (void)didConnectDevice:(CRBleDevice *)device;
/** Used to handle the subsequent tasks of disconnection. */
- (void)willDisconnectWithDevice:(CRBleDevice *)device;
/** Get new data. */
- (void)appendingNewData:(NSData *)data FromDevice:(CRBleDevice *)device;

#pragma mark - Query Command
/** Query the 4-digit version information of the device. */
- (void)queryForDeviceFourBitVersionForDevice:(CRBleDevice *)device;
/** Query the 2-digit version information of the device. */
- (void)queryForDeviceTwoBitVersionForDevice:(CRBleDevice *)device;
/** Query the device serial number. */
- (void)queryForSerialNumberForDevice:(CRBleDevice *)device;
/** Query device time. */
- (void)queryForDeviceTimeForDevice:(CRBleDevice *)device;
/** Query the battery level of the device. */
- (void)queryForBatteryLevelForDevice:(CRBleDevice *)device;
/** Query the backlight level of the device. */
- (void)queryForBackgroundLightLevelForDevice:(CRBleDevice *)device;
/** Query blood oxygen alarm parameter information. */
- (void)queryForSpo2AlertParamInfomation:(CRAP_20Spo2AlertConfigType)configType ForDevice:(CRBleDevice *)device;
/** Query the user ID. */
- (void)queryForUserIDForDevice:(CRBleDevice *)device;


#pragma mark - Enable Command
/** Send the blood oxygen waveform enable command. */
- (void)sendCommandForSpo2WaveEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;
/** Send the blood oxygen parameter enable command. */
- (void)sendCommandForSpo2ParamEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;
/** Send the sniff wave waveform enable command. */
- (void)sendCommandForNasalFlowWaveEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;
/** Send the sniff flow parameter enable command. */
- (void)sendCommandForNasalFlowParamEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;
/** Send the three-axis acceleration waveform enable command. */
- (void)sendCommandForThree_AxesWaveEnable:(BOOL)beEnable ForDevice:(CRBleDevice *)device;

#pragma mark - Setting Command

#pragma mark - AP-20 Private method
/** Set the backlight level. (0~5 ,0 is the darkest.,5 is the brightest. )*/
- (void)setBackgroundLightLevel:(int)lightLevel  ForDevice:(CRBleDevice *)device;
/** Set the user ID. */
- (void)setUserID:(NSString *)userID ForDevice:(CRBleDevice *)device;

#pragma mark - AP-20 ，SP-20 Shared method

/** Set the device time. */
- (void)setDeviceTime:(NSString *)deviceTime ForDevice:(CRBleDevice *)device;
/** Set blood oxygen alarm parameter information. */
- (void)setSpo2AlertParamInfomation:(CRAP_20Spo2AlertConfigType)configType Value:(int)value ForDevice:(CRBleDevice *)device;

#pragma mark - PC_60F Private method
/** Query the Bluetooth address. */
- (void)queryForMACAddressForDevice:(CRBleDevice *)device;

#pragma mark - PC_60E Private method
/** Query menu. */
- (void)queryForMenuOptionsForDevice:(CRBleDevice *)device;
/**
 @description Setting menu.
 (lowSpO2), (highPr),(lowPr), measurement type(spot), (beepOn), rotary switch(rotateOn).
 @param lowSpO2   Low blood oxygen threshold.   (80~99)
 @param highPr   High pulse rate  threshold.         (100~240)
 @param lowPr    Low pulse rate  threshold.            (30~60)
 @param spot   Measurement type.         1:Spot measurement mode, 2:Continuous measurement mode.
 @param beepOn   Buzzer switch.             1:on, 2:off.
 @param rotateOn   Rotary switch.          1:on, 2:off.
 */
- (void)setMenuOptions:(int)lowSpO2
                highPR:(int)highPr
                 lowPR:(int)lowPr
                  spot:(int)spot
                beepOn:(int)beepOn
              rotateOn:(int)rotateOn
             forDevice:(CRBleDevice *)device;

#pragma mark - PC_68B Private method
/** Get a list of records. */
- (void)queryForRecordsListForDevice:(CRBleDevice *)device;
/** Obtain records according to the specified serial number. */
- (void)getRecordsDataWithModel:(CRAP20RecordModel *)model ForDevice:(CRBleDevice *)device;
/** Delete Record. */
- (void)deleteAllRecordsForDevice:(CRBleDevice *)device;

/** Query blood oxygen alarm parameters. */
- (void)queryForSpo2AlertParamInfomationForDevice:(CRBleDevice *)device;
/*!
 *  @method
 *  @descrip Set blood oxygen alarm parameter information.
 *  @param alertOn   The alarm function is turned on/off.  YES : On;
 *  @param spo2Low   Low blood oxygen threshold. （85 ~ 100）
 *  @param prLow    Low pulse rate  threshold.         （25 ~ 99）
 *  @param prHigh    High pulse rate  threshold.      （100 ~ 250）
 *  @param beepOn    Pulsating sound switch.                YES : On;
 *  @param sensorOn    Falling off warning switch.        YES : On;
 *
 */
- (void)setSpo2AlertState:(BOOL)alertOn Spo2LowValue:(int)spo2Low PrLowValue:(int)prLow PrHighValue:(int)prHigh PulseBeep:(BOOL)beepOn SensorAlert:(BOOL)sensorOn ForDevice:(CRBleDevice *)device;

@end


