//
//  BELoadingView.h
//  loadingAnimation
//
//  Created by Binger Zeng on 2018/10/25.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BELoadingView : UIView
/**
 *  网络加载指示控件view
 */

+(void)showLoadingViewInView:(UIView *)view;

+(void)hideLoadingView:(UIView *)view;

+(void)beginAnimation;

+(void)stopAnimation;

@end
