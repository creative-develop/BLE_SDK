//
//  CRProgress.h
//  PC-200Demo
//
//  Created by Creative on 2021/1/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRProgress : UIView

+ (void)showProgressWithTitle:(NSString *)title InView:(UIView *)superView;

+ (void)hiddenProgress;

@end

NS_ASSUME_NONNULL_END
