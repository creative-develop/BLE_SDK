//
//  CRWavesView.h
//  AP-20Demo
//
//  Created by Creative on 2020/12/25.
//

#import <UIKit/UIKit.h>
#import "CRHeartLiveView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRWavesView : UIView

/** 一个points参数代表一条线*/
- (void)addPoints1:(NSArray <CRPoint *>*)points1 points2:(nullable NSArray <CRPoint *>*)points2 points3:(nullable NSArray <CRPoint *>*)points3;
- (void)clearPath;
- (void)setLeadOff:(BOOL)leadOff;

@end

NS_ASSUME_NONNULL_END
