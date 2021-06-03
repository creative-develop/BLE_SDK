//
//  CRHttpRequest.h
//  PC-200Demo
//
//  Created by Creative on 2020/12/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRHttpRequest : NSObject

+ (instancetype)shareInstance;

/** 从服务器获取PC-200版本信息*/
- (void)getPC200IAPInfoWithCompleteHandle:(void (^)(BOOL success, NSError *error, NSDictionary *dict))completeHandle;

/** 根据URL下载固件升级包*/
- (void)getPC200IAPDataPackageWithUrl:(NSString *)urlString CompleteHandle:(void (^)(BOOL success, NSError *error, NSData *data))completeHandle;

@end

NS_ASSUME_NONNULL_END
