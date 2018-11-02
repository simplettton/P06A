//
//  BEProgressHUD.h
//  WIFIParameter
//
//  Created by Binger Zeng on 2018/10/25.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MBProgressHUD.h"
 typedef NS_ENUM(NSInteger, BEProgressHUDStatus) {

     /** 成功 */
     BEProgressHUDStatusSuccess,
     
     /** 失败 */
     BEProgressHUDStatusError,
     
     /** 警告 */
     BEProgressHUDStatusWaitting,
     
     /** 提示 */
     BEProgressHUDStatusInfo,
     
     /** 等待 */
     BEProgressHUDStatusLoading

 };

@interface BEProgressHUD : MBProgressHUD

/** 是否正在显示 */
@property(nonatomic,assign,getter=isShowNow) BOOL showNow;

/** 返回一个HUD的单例 */
+(instancetype)sharedHUD;

/** 在window上添加一个HUD实例 */
+ (void)showStatus:(BEProgressHUDStatus)status text:(NSString *)text;

+ (void)showMessage:(NSString *)text;

+ (void)showWaiting:(NSString *)text;

+ (void)showError:(NSString *)text;

+ (void)showSuccess:(NSString *)text;

+ (void)showLoading:(NSString *)text;

/** 手动隐藏 HUD */
+ (void)hideHUD;
@end
