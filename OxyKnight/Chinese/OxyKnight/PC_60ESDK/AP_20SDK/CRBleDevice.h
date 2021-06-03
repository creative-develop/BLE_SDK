//
//  CRBleDevice.h
//  PC300SDKDemo
//
//  Created by Creative on 2018/2/1.
//  Copyright © 2018年 creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#define pc100 @"PC-100"
#define pc200 @"PC-200"
#define pc300 @"PC_300"
#define pc80b @"PC80B"
#define h600 @"H600"
#define pod @"POD"
#define ap_10 @"AP-10"
#define ap_20 @"AP-20"
#define sp_20 @"SP-20"
#define pc_60nw @"PC-60NW"
#define pc_60nw_1 @"PC-60NW-1"

#define pc_68b @"PC-68B"
#define pc_66b @"PC-66B"

#define pc_60e @"PC-60E"


#define pc_60f @"PC-60F"
#define OxySmart @"OxySmart "  //定制版PC-60F
#define BabyOximeter @"BabyOximeter"
#define OxyKnight @"OxyKnight"//BabyOximeter改名

#define eBody_Scale @"eBody-Scale"
#define AM300 @"AM300"


/** 连接设备状态码 */
typedef NS_ENUM(NSUInteger, CRBLESDKConnectionState)
{
    /* 未连接到设备 */
    CRBLESDKConnectionStateNotInConnect = 0,
    /* 正在连接设备 */
    CRBLESDKConnectionStateConnecting,
    /* 已经连接到设备 */
    CRBLESDKConnectionStateInConnect,
};

/** 血氧波形数据 */
struct waveData
{
    int waveValue;
    BOOL pulse;
};

#define CRBLEMANAGERWILLDISCONNECT @"CRBLEMANAGERWILLDISCONNECT"

@interface CRBleDevice : NSObject
/** 设备属性 */
@property (nonatomic, strong,readonly) CBPeripheral *peripheral;
/** 写特征 */
@property (nonatomic, strong) CBCharacteristic *writeCharact;
/** 设备的连接状态 */
@property (nonatomic, assign) CRBLESDKConnectionState connectionState;

@property (nonatomic, copy)NSString *bleName;

- (instancetype)initDeviceWithPeripheral:(CBPeripheral *)peripheral;
- (instancetype)initDeviceWithPeripheral:(CBPeripheral *)peripheral BLEName:(NSString *)bleName;
@end
