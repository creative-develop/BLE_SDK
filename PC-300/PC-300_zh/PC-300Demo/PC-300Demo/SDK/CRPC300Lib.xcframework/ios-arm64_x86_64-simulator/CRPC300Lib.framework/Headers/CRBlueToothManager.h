//
//  CRBlueToothManager.h
//  PC300SDKDemo
//
//  Created by Creative on 2018/2/1.
//  Copyright © 2018年 creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class CRBleDevice;
@class CRBlueToothManager;
/** SDK work Mode */
typedef NS_ENUM(NSUInteger, CRBLESDKWorkMode)
{
    CRBLESDKWorkModeForeground = 0,
    CRBLESDKWorkModeBackground,
};

/** error code of connect peripheral*/
typedef NS_ENUM(int, CRBLESDKConnectError)
{
    /* the peripheral is nil */
    CRBLESDKConnectErrorDeviceIsNil = 90000,
    /* the peripheral not supported */
    CRBLESDKConnectErrorDeviceNotFit = 90001,
    /* the peripheral connected */
    CRBLESDKConnectErrorDeviceConnected = 90002,
};


@protocol CRBlueToothManagerDelegate <NSObject>
#pragma mark - --------------------------- scan and connect

/** centralManager state  */
- (void)bleManager:(CRBlueToothManager *)manager didUpdateState:(CBManagerState)state;

/** End scan and return results  */
- (void)bleManager:(CRBlueToothManager *)manager didSearchCompleteWithResult:(NSArray <CRBleDevice *>*)deviceList;

/** Successfully connected peripheral  */
- (void)bleManager:(CRBlueToothManager *)manager didConnectDevice:(CRBleDevice *)device;
/** Successfully disconnected  peripheral */
- (void)bleManager:(CRBlueToothManager *)manager didDisconnectDevice:(CRBleDevice *)device;
/** connect failed */
- (void)bleManager:(CRBlueToothManager *)manager didFailToConnectDevice:(CRBleDevice *)device Error:(NSError *)error;
/** find peripheral and return results */
- (void)bleManager:(CRBlueToothManager *)manager didFindDevice:(NSArray <CRBleDevice *>*)deviceList;

@end
@interface CRBlueToothManager : NSObject
/** delegate  */
@property (nonatomic, weak) id <CRBlueToothManagerDelegate>delegate;
/** SDK current work mode  */
@property (nonatomic, assign,readonly) CRBLESDKWorkMode modeState;

@property (nonatomic, assign,readonly) CBManagerState state;
/** all connected peripherals */
@property (nonatomic, strong) NSMutableDictionary *connectedDevices;

+(instancetype)shareInstance;

#pragma mark - --------------------------- motheds

/// scan devices
/// - Parameter seconds: scan duration
- (void)startSearchDevicesForSeconds:(NSUInteger)seconds;

/// stop scan
- (void)stopSearch;

/// connect to the device
/// - Parameter device: device in search list.
- (void)connectDevice:(CRBleDevice *)device;

/// disconnect to the device
/// - Parameter device: device in connected devices.
- (void)disconnectDevice:(CRBleDevice *)device;


/// set sdk work mode
/// - Parameter mode: mode
- (void)setWorkMode:(CRBLESDKWorkMode)mode;

@end
