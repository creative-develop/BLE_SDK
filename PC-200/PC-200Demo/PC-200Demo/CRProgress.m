//
//  CRProgress.m
//  PC-200Demo
//
//  Created by Creative on 2021/1/4.
//

#import "CRProgress.h"

@interface CRProgress ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *superView;

@end

@implementation CRProgress

+ (CRProgress *)shareInstance; {
    static dispatch_once_t once;
    static CRProgress *sharedView;
    dispatch_once(&once, ^{
        sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    });
    return sharedView;
}

BOOL isFirst = YES;
+ (void)showProgressWithTitle:(NSString *)title InView:(UIView *)superView {
    if (isFirst) {
        isFirst = NO;
        [superView addSubview:[self shareInstance]];
    }
    [[self shareInstance] showProgressWithTitle:title InView:(UIView *)superView];
}

- (void)showProgressWithTitle:(NSString *)title InView:(UIView *)superView {
    self.titleLabel.hidden = NO;
    self.titleLabel.text = title;
}

+ (void)hiddenProgress {
    [[self shareInstance] hiddenProgress];
}

- (void)hiddenProgress {
    self.titleLabel.text = @"";
    self.titleLabel.hidden = YES;
    [self removeFromSuperview];
    isFirst = YES;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        float width = self.bounds.size.width;
        float height = self.bounds.size.height;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, height / 2 - 100, width - 100, 100)];
        label.backgroundColor = [UIColor lightGrayColor];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 10.0;
        label.layer.masksToBounds = YES;
        label.hidden = YES;
        [self addSubview:label];
        _titleLabel = label;
    }
    return _titleLabel;
}

@end
