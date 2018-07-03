//
//  LoginViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/14.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "AppDelegate.h"

#import <SVProgressHUD.h>

#import <UMSocialCore/UMSocialCore.h>
#import "SVProgressHUD.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *thirdPartyView;
@property (weak, nonatomic) IBOutlet UIImageView *identityImageView;
@property (weak, nonatomic) IBOutlet UIView *loginBackgroundView;



- (IBAction)login:(id)sender;
- (IBAction)loginWithSina:(id)sender;
- (IBAction)loginWithWeChat:(id)sender;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initAll];
    NSLog(@"loginViewController-> viewDidLoad");

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];

}

-(void)initAll {
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeSelf:)];
    self.navigationItem.leftBarButtonItem = barButton;
    self.loginView.layer.borderWidth = 1;
    self.loginView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.loginView.layer.cornerRadius = 5;
    self.loginButton.layer.cornerRadius = 5;
    
    self.loginBackgroundView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.loginBackgroundView.layer.borderWidth = 1;
    self.loginBackgroundView.layer.cornerRadius = 5;
    self.identityImageView.layer.cornerRadius = 5;
    
    //保存的身份选择
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *indentity = [userDefaults objectForKey:@"Identity"];
    if ([indentity isEqualToString:@"doctor"]) {
        
        NSLog(@"doctor");
        self.thirdPartyView.hidden = YES;
        self.identityImageView.highlighted = YES;
        
    }else if ([indentity isEqualToString:@"patient"]){
        self.thirdPartyView.hidden = NO;
        self.identityImageView.highlighted = NO;
    }else{
        
    }
}

- (void)closeSelf:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)login:(id)sender
{
    [self.userNameTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *centerNavi;
    if ([self.userNameTextField.text isEqualToString:@"admin"]) {

        [userDefault setObject:self.userNameTextField.text forKey:@"USER_NAME"];
        [userDefault setObject:@"admin" forKey:@"ROLE"];
        [userDefault setBool:YES forKey:@"IsLogined"];
        [userDefault synchronize];
        centerNavi = [mainStoryboard instantiateViewControllerWithIdentifier:@"doctor"];
        
    }else if([self.userNameTextField.text isEqualToString:@"user"]){

        [userDefault setObject:self.userNameTextField.text forKey:@"USER_NAME"];
        [userDefault setObject:@"user" forKey:@"ROLE"];
        [userDefault setBool:YES forKey:@"IsLogined"];
        [userDefault synchronize];
        centerNavi = [mainStoryboard instantiateViewControllerWithIdentifier:@"patient"];

    }

    //切换到另一个账户
    if (centerNavi) {
        [self initDrawerWithCenterViewController:centerNavi];
    }
}

-(void)initDrawerWithCenterViewController:(UINavigationController *)centerNavi {
    
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //初始化drawercontroller
    UIViewController *leftViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"menu"];
    
    myDelegate.drawerController = [[MMDrawerController alloc]initWithCenterViewController:centerNavi leftDrawerViewController:leftViewController];
    
    myDelegate.drawerController.maximumLeftDrawerWidth = 260.0;
    myDelegate.drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;
    myDelegate.drawerController.closeDrawerGestureModeMask =MMCloseDrawerGestureModeAll;
    
    
    myDelegate.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //        [myDelegate.window setRootViewController:myDelegate.drawerController];
    [UIView transitionWithView:myDelegate.window
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        myDelegate.window.rootViewController = myDelegate.drawerController;
                    }
                    completion:nil];
    [myDelegate.window makeKeyAndVisible];
    
}

- (IBAction)loginWithSina:(id)sender
{

}
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
    
}

- (IBAction)loginWithWeChat:(id)sender
{
    [self getAuthWithUserInfoFromWechat];
    [SVProgressHUD showWithStatus:@"正在登录中..."];

}
- (void)getAuthWithUserInfoFromWechat
{

    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            
        } else {

            UMSocialUserInfoResponse *resp = result;
            
            // 授权信息
            NSLog(@"Wechat uid: %@", resp.uid);
            NSLog(@"Wechat openid: %@", resp.openid);
            NSLog(@"Wechat unionid: %@", resp.unionId);
            NSLog(@"Wechat accessToken: %@", resp.accessToken);
            NSLog(@"Wechat refreshToken: %@", resp.refreshToken);
            NSLog(@"Wechat expiration: %@", resp.expiration);
            NSDictionary *originaldic = resp.originalResponse;
            NSString *country = originaldic[@"country"];
            NSString *province = originaldic[@"province"];
            NSString *city = originaldic[@"city"];
            
            // 用户信息
            NSLog(@"Wechat name: %@", resp.name);
            NSLog(@"Wechat iconurl: %@", resp.iconurl);
            NSLog(@"Wechat gender: %@", resp.unionGender);
            
            // 第三方平台SDK源数据
            NSString *string = [NSString stringWithFormat:@"%@,%@,%@,%@,%@",resp.name,resp.unionGender,country,province,city];
            [SVProgressHUD showSuccessWithStatus:string];
            
            
            //保存第三方信息
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

            NSString *imageURL = resp.iconurl;
            UIImage *userIcon=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
            NSData *imageData = UIImagePNGRepresentation(userIcon);
            

            [userDefaults setObject:imageData forKey:@"USER_ICON"];
            [userDefaults setObject:resp.name forKey:@"USER_NAME"];
            [userDefaults setObject:resp.unionGender forKey:@"USER_SEX"];
            [userDefaults setObject:@"user" forKey:@"ROLE"];
            [userDefaults synchronize];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *centerNavi = [mainStoryboard instantiateViewControllerWithIdentifier:@"patient"];
            [userDefaults setBool:YES forKey:@"IsLogined"];
            //初始化drawercontroller


            [SVProgressHUD showSuccessWithStatus:@"登录成功"];
//                        [self initDrawerWithCenterViewController:centerNavi];
            [self performSelector:@selector(initDrawerWithCenterViewController:) withObject:centerNavi afterDelay:0.25];

        }
    }];
}
@end
