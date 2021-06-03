//
//  CRBlueToothManager.h
//  PC300SDKDemo
//
//  Created by Creative on 2018/2/1.
//  Copyright © 2018年 creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRBleDevice.h"

@class CRBlueToothManager;
/** SDK Work Mode */
typedef NS_ENUM(NSUInteger, CRBLESDKWorkMode)
{
    CRBLESDKWorkModeForeground = 0,
    CRBLESDKWorkModeBackground,
};

/** Failed to connect to the device error code */
typedef NS_ENUM(int, CRBLESDKConnectError)
{
    /* Device is empty */
    CRBLESDKConnectErrorDeviceIsNil = 90000,
    /*  Device is not bleName */
    CRBLESDKConnectErrorDeviceNotFit = 90001,
    /* In connected device state */
    CRBLESDKConnectErrorDeviceConnected = 90002,
};


@protocol CRBlueToothManagerDelegate <NSObject>
#pragma mark - --------------------------- Device scanning and connection

/** BLE state */
- (void)bleManager:(CRBlueToothManager *)manager didUpdateState:(CBManagerState)state;

/** Scan complete */
- (void)bleManager:(CRBlueToothManager *)manager didSearchCompleteWithResult:(NSArray <CRBleDevice *>*)deviceList;

/** The device has been successfully connected */
- (void)bleManager:(CRBlueToothManager *)manager didConnectDevice:(CRBleDevice *)device;
/** Successfully disconnected */
- (void)bleManager:(CRBlueToothManager *)manager didDisconnectDevice:(CRBleDevice *)device;
/** Failed to connect to device */
- (void)bleManager:(CRBlueToothManager *)manager didFailToConnectDevice:(CRBleDevice *)device Error:(NSError *)error;
/** Find device */
- (void)bleManager:(CRBlueToothManager *)manager didFindDevice:(NSArray <CRBleDevice *>*)deviceList;

@end
@interface CRBlueToothManager : NSObject
/** delegate  */
@property (nonatomic, weak) id <CRBlueToothManagerDelegate>delegate;
/** The current working mode of the SDK  */
@property (nonatomic, assign,readonly) CRBLESDKWorkMode modeState;
/** Bluetooth working status  */
@property (nonatomic, assign,readonly) CBManagerState state;
/** Connected device */
@property (nonatomic, strong) NSMutableDictionary *connectedDevices;

+(instancetype)shareInstance;

#pragma mark - --------------------------- Device management
/** Scanning device */
- (void)startSearchDevicesForSeconds:(NSUInteger)seconds;
/** Stop searching */
- (void)stopSearch;
/** Connect the device */
- (void)connectDevice:(CRBleDevice *)device;
/** Disconnect */
- (void)disconnectDevice:(CRBleDevice *)device;

/** Set the working mode settings of the SDK */
- (void)setWorkMode:(CRBLESDKWorkMode)mode;

@end
