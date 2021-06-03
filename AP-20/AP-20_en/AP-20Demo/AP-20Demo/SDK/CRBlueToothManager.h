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
/** SDK working mode. */
typedef NS_ENUM(NSUInteger, CRBLESDKWorkMode)
{
    CRBLESDKWorkModeForeground = 0,
    CRBLESDKWorkModeBackground,
};

/** Error code for connection failure. */
typedef NS_ENUM(int, CRBLESDKConnectError)
{
    /* The device is empty. */
    CRBLESDKConnectErrorDeviceIsNil = 90000,
    /*  The device is not PC100. */
    CRBLESDKConnectErrorDeviceNotFit = 90001,
    /* In the connected device state. */
    CRBLESDKConnectErrorDeviceConnected = 90002,
};


@protocol CRBlueToothManagerDelegate <NSObject>
#pragma mark - --------------------------- Device scanning and connection.
@optional
/** Monitor the Bluetooth on status. */
- (void)bleManager:(CRBlueToothManager *)manager didUpdateState:(CBManagerState)state;

/** The scan is complete. */
- (void)bleManager:(CRBlueToothManager *)manager didSearchCompleteWithResult:(NSArray <CRBleDevice *>*)deviceList;

/** The device has been successfully connected. */
- (void)bleManager:(CRBlueToothManager *)manager didConnectDevice:(CRBleDevice *)device;
/** The connection has been successfully disconnected. */
- (void)bleManager:(CRBlueToothManager *)manager didDisconnectDevice:(CRBleDevice *)device;
/** Failed to connect to the device. */
- (void)bleManager:(CRBlueToothManager *)manager didFailToConnectDevice:(CRBleDevice *)device Error:(NSError *)error;
/** Find the device. */
- (void)bleManager:(CRBlueToothManager *)manager didFindDevice:(NSArray <CRBleDevice *>*)deviceList;

@end
@interface CRBlueToothManager : NSObject
/** delegate  */
@property (nonatomic, weak) id <CRBlueToothManagerDelegate>delegate;
/** The current working mode of the SDK.  */
@property (nonatomic, assign,readonly) CRBLESDKWorkMode modeState;
/** The working status of Bluetooth.  */
@property (nonatomic, assign,readonly) CBManagerState state;
/** Connected devices. */
@property (nonatomic, strong) NSMutableDictionary *connectedDevices;

+(instancetype)shareInstance;

#pragma mark - --------------------------- Device connection
/** Start scanning for devices. */
- (void)startSearchDevicesForSeconds:(NSUInteger)seconds;
/** Stop scanning for devices. */
- (void)stopSearch;
/** Connect the device. */
- (void)connectDevice:(CRBleDevice *)device;
/** Disconnect. */
- (void)disconnectDevice:(CRBleDevice *)device;

/** Set the working mode settings of the SDK. */
- (void)setWorkMode:(CRBLESDKWorkMode)mode;

@end
