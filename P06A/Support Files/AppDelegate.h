//
//  AppDelegate.h
//  P06A
//
//  Created by Binger Zeng on 2018/1/4.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

//为MMDrawerController框架中
#import "MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (assign, nonatomic) BOOL isBLEPoweredOff;
@property (strong, nonatomic) UIWindow *window;
/**
 *  MMDrawerController属性
 */
@property(nonatomic,strong) MMDrawerController * drawerController;

@end

