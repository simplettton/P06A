//
//  AppDelegate.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/4.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import <UMSocialCore/UMSocialCore.h>
#import "UserHomeViewController.h"

//为MMDrawerController框架中
#import "MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"
#import <UserNotifications/UserNotifications.h>


static NSString * const USHARE_APPKEY           = @"5a2a0fdeb27b0a4989000164";
static NSString * const KOpenFileNotification   = @"KOpenFileNotification";
static NSString * const KFileName               = @"KFileName";
static NSString * const KFilePath               = @"KFilePath";


@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([self isUserLogin]) {
        [self initDrawer];
        //  初始化窗口、设置根控制器、显示窗口
        self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [UIView transitionWithView:self.window
                          duration:0.25
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.window.rootViewController = self.drawerController;
                        }
                        completion:nil];

        [self.window makeKeyAndVisible];
    }
//
//    //iOS 10 before
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
//    [application registerUserNotificationSettings:settings];
    
    //iOS 10
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"request authorization succeeded!");
        }
    }];
    
    
    [[UMSocialManager defaultManager] openLog:YES];
    
    [[UMSocialManager defaultManager] setUmSocialAppkey:USHARE_APPKEY];
    
    [self configUSharePlatforms];

    return YES;
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
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession
                                          appKey:@"wx0d00393a5eb1f3a9"
                                       appSecret:@"dab1983865bec320e78e92dfd36e80fd"
                                     redirectURL:@"http://mobile.umeng.com/social"];
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


-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
    
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
    if (![[UMSocialManager defaultManager] handleOpenURL:url]) {
        BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
        return result;
    }
    return YES;
}


-(void)initDrawer {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *centerNavi;
    NSString *centerIndentifierString = [[NSUserDefaults standardUserDefaults]objectForKey:@"Identity"];

    centerNavi = [mainStoryboard instantiateViewControllerWithIdentifier:centerIndentifierString];
    UIViewController *leftViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"menu"];
    //使用MMDrawerController
    self.drawerController = [[MMDrawerController alloc]initWithCenterViewController:centerNavi leftDrawerViewController:leftViewController];

    //设置打开/关闭抽屉的手势
    self.drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;
    self.drawerController.closeDrawerGestureModeMask =MMCloseDrawerGestureModeAll;
    
    //设置抽屉显示的多少
    self.drawerController.maximumLeftDrawerWidth = 260.0;
    
}


#pragma mark -- 是否登录
-(BOOL)isUserLogin
{
    NSString *userId =  [[NSUserDefaults standardUserDefaults]objectForKey:@"USER_NAME"];
    
    if (userId != nil)
    {
        //已经登录
        return YES;
    }
    return NO;
}
@end
