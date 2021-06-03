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
#define pc_60b @"PC-60B"


#define pc_60f @"PC-60F"
#define OxySmart @"OxySmart "  //PC-60F(Custom)
#define BabyOximeter @"BabyOximeter"
#define OxyKnight @"OxyKnight"//BabyOximeter(Renamed)

#define eBody_Scale @"eBody-Scale"
#define AM300 @"AM300"


/** Connected device status code. */
typedef NS_ENUM(NSUInteger, CRBLESDKConnectionState)
{
    /* Not connected to the device. */
    CRBLESDKConnectionStateNotInConnect = 0,
    /* Connecting to device. */
    CRBLESDKConnectionStateConnecting,
    /* Already connected to the device. */
    CRBLESDKConnectionStateInConnect,
};

/** Blood oxygen waveform data */
struct waveData
{
    int waveValue;
    BOOL pulse;
};

#define CRBLEMANAGERWILLDISCONNECT @"CRBLEMANAGERWILLDISCONNECT"

@interface CRBleDevice : NSObject
/** Device properties. */
@property (nonatomic, strong,readonly) CBPeripheral *peripheral;
/** Write characteristics. */
@property (nonatomic, strong) CBCharacteristic *writeCharact;
/** The connection status of the device. */
@property (nonatomic, assign) CRBLESDKConnectionState connectionState;

@property (nonatomic, copy)NSString *bleName;

- (instancetype)initDeviceWithPeripheral:(CBPeripheral *)peripheral;
- (instancetype)initDeviceWithPeripheral:(CBPeripheral *)peripheral BLEName:(NSString *)bleName;
@end
