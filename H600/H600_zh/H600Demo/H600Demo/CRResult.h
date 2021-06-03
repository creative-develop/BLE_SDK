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

@end

NS_ASSUME_NONNULL_END
