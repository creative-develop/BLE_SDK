//
//  CRResult.m
//  PC-300Demo
//
//  Created by Creative on 2020/12/30.
//

#import "CRResult.h"

@implementation CRResult

/** 心电诊断结论*/
+ (NSString *)getEcgMeasureResult:(int)result {
    NSString *ecgResult = @"";
    switch (result) {
        case 0:
            ecgResult = @"波形未见异常";
            break;
        case 1:
            ecgResult = @"波形疑似心跳稍快,请注意休息";
            break;
        case 2:
            ecgResult = @"波形疑似心跳过快,请注意休息";
            break;
        case 3:
            ecgResult = @"波形疑似阵发性心跳过快,请咨询医生";
            break;
        case 4:
            ecgResult = @"波形疑似心跳稍缓,请注意休息";
            break;
        case 5:
            ecgResult = @"波形疑似心跳过缓,请注意休息";
            break;
        case 6:
            ecgResult = @"波形疑似心跳间期缩短,请咨询医生";
            break;
        case 7:
            ecgResult = @"波形疑似心跳间期不规则,请咨询医生";
            break;
        case 8:
            ecgResult = @"波形疑似心跳稍快伴有心跳间期缩短,请咨询医生";
            break;
        case 9:
            ecgResult = @"波形疑似心跳稍缓伴有心跳间期缩短,请咨询医生";
            break;
        case 10:
            ecgResult = @"波形疑似心跳稍缓伴有心跳间期不规则,请咨询医生";
            break;
        case 11:
            ecgResult = @"波形有漂移";
            break;
        case 12:
            ecgResult = @"波形疑似心跳过快伴有波形漂移,请咨询医生";
            break;
        case 13:
            ecgResult = @"波形疑似心跳过缓伴有波形漂移,请咨询医生";
            break;
        case 14:
            ecgResult = @"波形疑似心跳间期缩短伴有波形漂移,请咨询医生";
            break;
        case 15:
            ecgResult = @"波形疑似心跳间期不规则伴有波形漂移,请咨询医生";
            break;
        case 16:
            ecgResult = @"信号较差，请重新测量";
            break;
            
        default:
            break;
    }
    return ecgResult;
}

@end
