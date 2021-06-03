//
//  CRHttpRequest.m
//  PC-200Demo
//
//  Created by Creative on 2020/12/31.
//

#import "CRHttpRequest.h"

@interface CRHttpRequest ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation CRHttpRequest

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static CRHttpRequest *instance;
    dispatch_once(&onceToken, ^{
        instance = [[CRHttpRequest alloc] init];
        instance.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:instance delegateQueue:[[NSOperationQueue alloc] init]];
    });
    return instance;
}

/** 从服务器获取PC-200版本信息*/
- (void)getPC200IAPInfoWithCompleteHandle:(void (^)(BOOL, NSError *, NSDictionary *))completeHandle {
    NSString *urlString = @"http://health.creative-sz.com/PC200Servlet";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [@"token=FF7D6A42736B7488951E63A826420E04" dataUsingEncoding:NSUTF8StringEncoding];
    [[_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *error1;
        if (data && !error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error1];
            if (error1) {
                if (completeHandle)
                    completeHandle(NO,error1,nil);
                return;
            }
            if (completeHandle)
                completeHandle(YES,nil,dict);
            return;
        }
        if (completeHandle)
            completeHandle(NO,error,nil);
    }] resume];
}

/** 根据URL下载固件升级包*/
- (void)getPC200IAPDataPackageWithUrl:(NSString *)urlString CompleteHandle:(void (^)(BOOL, NSError *, NSData *))completeHandle {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [[_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (completeHandle)
                completeHandle(YES,nil,data);
            return;
        }
        if (completeHandle)
            completeHandle(NO,error,nil);
    }] resume];
}


@end
