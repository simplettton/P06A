//
//  PasswordLoginViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/7/31.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

//md5加密头文件
#import<CommonCrypto/CommonDigest.h>
#import "PasswordLoginViewController.h"
#import "AppDelegate.h"

@interface PasswordLoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UILabel *loginTitle;
@property (weak, nonatomic) IBOutlet UIButton *switchIdentityButton;

@end

@implementation PasswordLoginViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}
-(void)initUI{
    //界面标题
    self.loginTitle.text = BEGetStringWithKeyFromTable(@"密码登录", @"P06A");
    [self.loginButton setTitle:BEGetStringWithKeyFromTable(@"登录", @"P06A") forState:UIControlStateNormal];
    [self.switchIdentityButton setTitle:BEGetStringWithKeyFromTable(@"切换身份？", @"P06A") forState:UIControlStateNormal];
    self.userNameTextField.placeholder = BEGetStringWithKeyFromTable(@"请输入账号", @"P06A");
    self.passwordTextField.placeholder = BEGetStringWithKeyFromTable(@"请输入密码", @"P06A");
    
    [self setBorderWithView:self.nameView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0xeeeeee) borderWidth:1];
    [self setBorderWithView:self.passwordView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0xeeeeee) borderWidth:1];
    self.loginButton.layer.cornerRadius = 5;
}
//关闭键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self hideKeyBoard];
}
-(void)hideKeyBoard{

    [self.view endEditing:YES];
}

#pragma mark - login
-(void)showLoginingIndicator{
    
    [SVProgressHUD showWithStatus:BEGetStringWithKeyFromTable(@"正在登录中...", @"P06A")];
}
- (IBAction)login:(id)sender {
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    NSString *username = self.userNameTextField.text;
    NSString *pwd = [self md5:self.passwordTextField.text];
    
    if (username.length == 0 || pwd.length == 0) {
        [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"用户名或密码不能为空", @"P06A")];
        return;
    }else if(self.passwordTextField.text.length <6){
        [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"密码不小于6位", @"P06A")];
        return;
    }else if(self.passwordTextField.text.length >20){
        [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"密码不多于20位", @"P06A")];
        return;
    }
    
    [self showLoginingIndicator];
    
    NSDictionary *param = @{@"username":username,
                            @"pwd":pwd};
    
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Users/Login"]
                                  params:param
                                hasToken:NO
                                 success:^(HttpResponse *responseObject) {
                                    if ([responseObject.result intValue] == 1){

                                        NSString *role = [responseObject.content objectForKey:@"role"];
                                        
                                        if ([role isEqual:@1]) {
                                            
                                            NSString *token = [responseObject.content objectForKey:@"token"];
                                            NSString *nickName = [responseObject.content objectForKey:@"nickname"];
                                            [UserDefault setObject:nickName forKey:@"USER_NAME"];
                                            [UserDefault setObject:@"admin" forKey:@"Identity"];
                                            //用服默认中文
                                            [[BELanguageTool sharedInstance]setNewLanguage:@"zh-Hans"];
                                            
                                            [UserDefault setObject:token forKey:@"Token"];
                                            [UserDefault setBool:YES forKey:@"IsLogined"];
                                            [UserDefault synchronize];
                                            
                                            //跳转主界面
                                            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                            UINavigationController *centerNavi = [mainStoryboard instantiateViewControllerWithIdentifier:@"admin"];
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self initDrawerWithCenterViewController:centerNavi];
                                            });
                                        }
                                    }else{
                                        NSString *error = responseObject.errorString;
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [SVProgressHUD showErrorWithStatus:error];
                                        });
                                    }
                                }
                                 failure:^(NSError *error) {
                                     NSLog(@"error :%@",error);
                                }];

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
    [SVProgressHUD dismiss];
    
}
#pragma mark - PrivateMethod

- (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width
{
    
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height - width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width - width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}

- (NSString *) md5:(NSString *) input {
    
    const char *cStr = [input UTF8String];
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        
    [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}
@end
