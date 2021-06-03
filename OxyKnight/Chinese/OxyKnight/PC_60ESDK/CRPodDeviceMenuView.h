//
//  CRPodDeviceMenuView.h
//  health
//
//  Created by Creative on 2020/11/17.
//  Copyright © 2020 creative. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRPodDeviceMenuView : UIView

/**
 封装出一个用于展示Pod设备菜单项（Spo2L，PrH，PrL， ContinuousOrSpot，Deep，Rotate）的视图
 */

/** Spo2L：血氧下限设置菜单项 */
@property (nonatomic, assign) int lowSpO2;
/** PrH：脉率上限设备菜单项 */
@property (nonatomic, assign) int highPr;
/** PrL：脉率下限设备菜单项 */
@property (nonatomic, assign) int lowPr;
/** ContinuousOrSpot： 01，点测模式；02长测模式 */
@property (nonatomic, assign) int spot;
/** Deep：蜂鸣器设置菜单项。01，设置开；02，设置关；00，不设置 */
@property (nonatomic, assign) int beepOn;
/** Rotate：旋转开关。01，设置开；02，设置关；00，不设置 */
@property (nonatomic, assign) int rotateOn;

- (instancetype)initWithDeviceName:(NSString *)deviceName Update:(void(^)(int lowSpO2, int highPr, int lowPr, int spot, int beepOn, int rotateOn))update Cancel:(void(^)(void))cancel;

@end

NS_ASSUME_NONNULL_END
