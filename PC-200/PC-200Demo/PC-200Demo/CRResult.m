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
            ecgResult = NSLocalizedString(@"波形未见异常", @"波形未见异常");
            break;
        case 1:
            ecgResult = NSLocalizedString(@"波形疑似心跳稍快,请注意休息", @"波形疑似心跳稍快,请注意休息");
            break;
        case 2:
            ecgResult = NSLocalizedString(@"波形疑似心跳过快,请注意休息", @"波形疑似心跳过快,请注意休息");
            break;
        case 3:
            ecgResult = NSLocalizedString(@"波形疑似阵发性心跳过快,请咨询医生", @"波形疑似阵发性心跳过快,请咨询医生");
            break;
        case 4:
            ecgResult = NSLocalizedString(@"波形疑似心跳稍缓,请注意休息", @"波形疑似心跳稍缓,请注意休息");
            break;
        case 5:
            ecgResult = NSLocalizedString(@"波形疑似心跳过缓,请注意休息", @"波形疑似心跳过缓,请注意休息");
            break;
        case 6:
            ecgResult = NSLocalizedString(@"波形疑似心跳间期缩短,请咨询医生", @"波形疑似心跳间期缩短,请咨询医生");
            break;
        case 7:
            ecgResult = NSLocalizedString(@"波形疑似心跳间期不规则,请咨询医生", @"波形疑似心跳间期不规则,请咨询医生");
            break;
        case 8:
            ecgResult = NSLocalizedString(@"波形疑似心跳稍快伴有心跳间期缩短,请咨询医生", @"波形疑似心跳稍快伴有心跳间期缩短,请咨询医生");
            break;
        case 9:
            ecgResult = NSLocalizedString(@"波形疑似心跳稍缓伴有心跳间期缩短,请咨询医生", @"波形疑似心跳稍缓伴有心跳间期缩短,请咨询医生");
            break;
        case 10:
            ecgResult = NSLocalizedString(@"波形疑似心跳稍缓伴有心跳间期不规则,请咨询医生", @"波形疑似心跳稍缓伴有心跳间期不规则,请咨询医生");
            break;
        case 11:
            ecgResult = NSLocalizedString(@"波形有漂移", @"波形有漂移");
            break;
        case 12:
            ecgResult = NSLocalizedString(@"波形疑似心跳过快伴有波形漂移,请咨询医生", @"波形疑似心跳过快伴有波形漂移,请咨询医生");
            break;
        case 13:
            ecgResult = NSLocalizedString(@"波形疑似心跳过缓伴有波形漂移,请咨询医生", @"波形疑似心跳过缓伴有波形漂移,请咨询医生");
            break;
        case 14:
            ecgResult = NSLocalizedString(@"波形疑似心跳间期缩短伴有波形漂移,请咨询医生", @"波形疑似心跳间期缩短伴有波形漂移,请咨询医生");
            break;
        case 15:
            ecgResult = NSLocalizedString(@"波形疑似心跳间期不规则伴有波形漂移,请咨询医生", @"波形疑似心跳间期不规则伴有波形漂移,请咨询医生");
            break;
        case 16:
            ecgResult = NSLocalizedString(@"信号较差，请重新测量", @"信号较差，请重新测量");
            break;
            
        default:
            ecgResult = NSLocalizedString(@"信号较差，请重新测量", @"信号较差，请重新测量");
            break;
    }
    return ecgResult;
}

/** 血压测量异常错误描述*/
+ (NSString *)getNibpMeasureErrorResultWithErrorType:(int)errorType errorCode:(int)errorCode {
    NSString *nibpResult = @"";
    if (errorCode == 0) {//景新浩
        switch (errorCode) {
            case 1:
                nibpResult = @"7S内打气不上30mmHg(气袋没绑好)";
                break;
            case 2:
                nibpResult = @"气袋压力超过295mmHg,进入超压保护";
                break;
            case 3:
                nibpResult = @"测量不到有效的脉搏";
                break;
            case 4:
                nibpResult = @"表示干预过多(测量中移动、说话等)";
                break;
            case 5:
                nibpResult = @"测量结果数值有误";
                break;
            case 6:
                nibpResult = @"漏气";
                break;
            case 14:
                nibpResult = @"电量过低，暂停使用";
                break;
                
            default:
                break;
        }
    } else {//KRK血压
        switch (errorCode) {
            case 1:
                nibpResult = @"7S内打气不上30mmHg(气袋没绑好)";
                break;
            case 2:
                nibpResult = @"气袋压力超过295mmHg,进入超压保护";
                break;
            case 3:
                nibpResult = @"测量不到有效的脉搏";
                break;
            case 4:
                nibpResult = @"表示干预过多(测量中移动、说话等)";
                break;
            case 5:
                nibpResult = @"测量结果数值有误";
                break;
            case 6:
                nibpResult = @"漏气";
                break;
            case 7:
                nibpResult = @"自检失败,可能是传感器或A/D采样出错";
                break;
            case 8:
                nibpResult = @"气压错误,可能是阀门无法正常打开";
                break;
            case 9:
                nibpResult = @"信号饱和,由于运动或其他原因使信号幅度太大";
                break;
            case 10:
                nibpResult = @"在漏气检测中，发现系统气路漏气";
                break;
            case 11:
                nibpResult = @"开机后，充气泵、A/D采样、压力传感器出错，或者软件运行中指针出错";
                break;
            case 12:
                nibpResult = @"某次测量超过规定时间，成人袖带压超过200mmHg时为120秒，未超过时为90秒，新生儿为90秒";
                break;
            case 14:
                nibpResult = @"电量过低，暂停使用";
                break;
                
            default:
                break;
        }
    }
    return nibpResult;
}

@end
