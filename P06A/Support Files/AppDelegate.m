//
//  AppDelegate.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/4.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "UserHomeViewController.h"
#import "BabyBluetooth.h"
#import <SVProgressHUD.h>
//为MMDrawerController框架中
#import "MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"
#import <UserNotifications/UserNotifications.h>
//地图框架
#import <AMapFoundationKit/AMapFoundationKit.h>

#import "PhoneLoginViewController.h"
#import "PasswordLoginViewController.h"

static NSString * const USHARE_APPKEY           = @"5a2a0fdeb27b0a4989000164";
static NSString * const KOpenFileNotification   = @"KOpenFileNotification";
static NSString * const KFileName               = @"KFileName";
static NSString * const KFilePath               = @"KFilePath";

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end
@implementation AppDelegate{
    BabyBluetooth *baby;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self initRootViewController];
    
    if (@available(iOS 10.0, *)) {
        //通知中心单例
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //iOS 10 使用以下方法注册本地通知，才能得到授权
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
    } else {
        //iOS 10 before
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
      //注册友盟APPkey
//    [[UMSocialManager defaultManager] openLog:YES];
//    [[UMSocialManager defaultManager] setUmSocialAppkey:USHARE_APPKEY];
//    [self configUSharePlatforms];
    
    [self configureSVProgress];

    //蓝牙开关代理
    baby = [BabyBluetooth shareBabyBluetooth];
    [self babyDelegate];
    
    //接收到推送消息后,消除右上角数字角标
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //map
    [AMapServices sharedServices].apiKey = @"d2f6c6fcd2af91698e24eaa8079396a9";
    return YES;
}
-(void)configureSVProgress {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setCornerRadius:5];
    [SVProgressHUD setRingRadius:14.0];
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 40)];
    [SVProgressHUD setImageViewSize:CGSizeMake(0, 0)];
    [SVProgressHUD setMaximumDismissTimeInterval:1];
    [SVProgressHUD setBackgroundColor:UIColorFromRGBAndAlpha(0XF9F9F9, 1)];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
}
-(void)babyDelegate {
    __weak typeof(self) weakSelf = self;
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOff){
            //蓝牙关闭发送通知
            [[NSNotificationCenter defaultCenter]postNotificationName:@"BLEPoweredOffNotification" object:nil];
            NSLog(@"蓝牙关了");
            weakSelf.isBLEPoweredOff = YES;
        }else if(central.state == CBCentralManagerStatePoweredOn) {
            weakSelf.isBLEPoweredOff = NO;
            NSLog(@"蓝牙开了");
        }
    }];
}
-(void)configUSharePlatforms {
    /*
     设置新浪的appKey和appSecret
     [新浪微博集成说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_2
     */
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina
//                                          appKey:@"3302431209"
//                                       appSecret:@"3eb44f6ec3446dd815100753e70decfb"
//                                     redirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    //设置微信的appKey和appSecret
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession
//                                          appKey:@"wx0d00393a5eb1f3a9"
//                                       appSecret:@"dab1983865bec320e78e92dfd36e80fd"
//                                     redirectURL:@"http://mobile.umeng.com/social"];
}


- (void)applicationWillResignActive:(UIApplication *)application {

}


- (void)applicationDidEnterBackground:(UIApplication *)application {

}


- (void)applicationWillEnterForeground:(UIApplication *)application {

}


- (void)applicationDidBecomeActive:(UIApplication *)application {

}


- (void)applicationWillTerminate:(UIApplication *)application {

}


-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    //文件url
    if (url) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fileNameStr = [url lastPathComponent];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        //document路径
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]enumeratorAtPath:documents];
        if (enumerator != nil) {
            for (NSString *fileName in enumerator) {
                BOOL isDirectory = NO;
                [[NSFileManager defaultManager]fileExistsAtPath:[documents stringByAppendingPathComponent:fileName] isDirectory:&isDirectory];
                if (!isDirectory) {
                    [fileManager removeItemAtPath:[documents stringByAppendingPathComponent:fileName] error:nil];
                }
            }
        }
        NSString *documentPath = [documents stringByAppendingPathComponent:fileNameStr];
        BOOL success = [data writeToFile:documentPath atomically:YES];
        if (success) {
            NSDictionary *dict = @{KFilePath:documentPath,KFileName:fileNameStr};
            [[NSNotificationCenter defaultCenter]postNotificationName:KOpenFileNotification object:nil userInfo:dict];
        }
    }


    return YES;
}

-(void)initRootViewController{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if ([UserDefault objectForKey:@"Identity"]) {
        //登录了之后跳转到主界面
        if ([self isUserLogin]) {
            [self initDrawer];
            //  初始化窗口、设置根控制器、显示窗口
            self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
            [UIView transitionWithView:self.window
                              duration:0.25
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{

                                self.window.rootViewController = self.drawerController;
                            }
                            completion:nil];

            [self.window makeKeyAndVisible];
        }else{
            NSString *userIdentity = [UserDefault objectForKey:@"Identity"];
            UIViewController *loginVC;
            if([userIdentity isEqualToString:@"patient"]){
                loginVC = (PhoneLoginViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"PhoneLoginViewController"];
            }else{
                loginVC = (PasswordLoginViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"PasswordLoginViewController"];
            }
            
            
            UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:loginVC];
            self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
            [UIView transitionWithView:self.window
                              duration:0.25
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.window.rootViewController = navigationController;
                            }
                            completion:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = navigationController;
            [self.window makeKeyAndVisible];
        }
    }
}
-(void)initDrawer {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *centerNavi = [[UINavigationController alloc]init];
   NSString *role = [UserDefault objectForKey:@"Identity"];
    if ([role isEqualToString:@"admin"]) {
        centerNavi = [mainStoryboard instantiateViewControllerWithIdentifier:@"admin"];
    }else if([role isEqualToString:@"patient"]){
        centerNavi = [mainStoryboard instantiateViewControllerWithIdentifier:@"patient"];
    }
    UIViewController *leftViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"menu"];
    //使用MMDrawerController
    self.drawerController = [[MMDrawerController alloc]initWithCenterViewController:centerNavi leftDrawerViewController:leftViewController];

    //设置打开/关闭抽屉的手势
    self.drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;
    self.drawerController.closeDrawerGestureModeMask =MMCloseDrawerGestureModeAll;
    
    //设置抽屉显示的多少
    self.drawerController.maximumLeftDrawerWidth = 260.0;
    
}

#pragma mark - LoginCheck
-(BOOL)isUserLogin
{
    BOOL isLogined=  [UserDefault boolForKey:@"IsLogined"];
    
    if (isLogined)
    {
        //已经登录
        return YES;
    }
    return NO;
}
@end
