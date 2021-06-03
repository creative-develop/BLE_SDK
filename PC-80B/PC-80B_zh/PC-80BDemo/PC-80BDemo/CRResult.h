//
//  CRResult.h
//  PC-300Demo
//
//  Created by Creative on 2020/12/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRResult : NSObject

/** 心电诊断结论*/
+ (NSString *)getEcgMeasureResult:(int)result;

/** 血压测量异常错误描述*/
+ (NSString *)getNibpMeasureErrorResultWithErrorType:(int)errorType errorCode:(int)errorCode;

@end

NS_ASSUME_NONNULL_END
