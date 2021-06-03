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
/** SDK工作模式 */
typedef NS_ENUM(NSUInteger, CRBLESDKWorkMode)
{
    CRBLESDKWorkModeForeground = 0,
    CRBLESDKWorkModeBackground,
};

/** 连接设备失败错误码 */
typedef NS_ENUM(int, CRBLESDKConnectError)
{
    /* 设备为空 */
    CRBLESDKConnectErrorDeviceIsNil = 90000,
    /*  设备不是PC100 */
    CRBLESDKConnectErrorDeviceNotFit = 90001,
    /* 处于已连接设备状态 */
    CRBLESDKConnectErrorDeviceConnected = 90002,
};


@protocol CRBlueToothManagerDelegate <NSObject>
#pragma mark - --------------------------- 设备扫描和连接

/** 找到设备 */
- (void)bleManager:(CRBlueToothManager *)manager didUpdateState:(CBManagerState)state;

/** 扫描完成 */
- (void)bleManager:(CRBlueToothManager *)manager didSearchCompleteWithResult:(NSArray <CRBleDevice *>*)deviceList;

/** 已经成功连接设备 */
- (void)bleManager:(CRBlueToothManager *)manager didConnectDevice:(CRBleDevice *)device;
/** 已经成功断开连接 */
- (void)bleManager:(CRBlueToothManager *)manager didDisconnectDevice:(CRBleDevice *)device;
/** 连接设备失败 */
- (void)bleManager:(CRBlueToothManager *)manager didFailToConnectDevice:(CRBleDevice *)device Error:(NSError *)error;
/** 找到设备 */
- (void)bleManager:(CRBlueToothManager *)manager didFindDevice:(NSArray <CRBleDevice *>*)deviceList;

@end
@interface CRBlueToothManager : NSObject
/** 代理  */
@property (nonatomic, weak) id <CRBlueToothManagerDelegate>delegate;
/** SDK当前处于的工作模式  */
@property (nonatomic, assign,readonly) CRBLESDKWorkMode modeState;
/** 蓝牙的工作状态  */
@property (nonatomic, assign,readonly) CBManagerState state;
/** 已连接的设备 */
@property (nonatomic, strong) NSMutableDictionary *connectedDevices;

+(instancetype)shareInstance;

#pragma mark - --------------------------- 设备管理
/** 扫描设备 */
- (void)startSearchDevicesForSeconds:(NSUInteger)seconds;
/** 停止搜索 */
- (void)stopSearch;
/** 连接设备 */
- (void)connectDevice:(CRBleDevice *)device;
/** 断开连接 */
- (void)disconnectDevice:(CRBleDevice *)device;

/** 设置SDK的工作模式设置 */
- (void)setWorkMode:(CRBLESDKWorkMode)mode;

@end
