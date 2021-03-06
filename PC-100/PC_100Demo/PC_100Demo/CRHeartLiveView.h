//
//  CRHeartLiveView.h
//  creativeExample
//
//  Created by Creative on 16/12/26.
//  Copyright © 2016年 creative. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRPoint : NSObject
@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@end

@interface CRHeartLiveView : UIView

- (void)addPoints:(NSArray <CRPoint *>*)points;
- (void)clearPath;
/** 判断导联脱落，接触不良  */
- (void)setLeadOff:(BOOL)leadOff;

@end
