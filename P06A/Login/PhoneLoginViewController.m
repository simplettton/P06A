     //
//  PhoneLoginViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/7/31.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PhoneLoginViewController.h"
#import "AppDelegate.h"
@interface PhoneLoginViewController ()
@property (weak, nonatomic) IBOutlet UIView *phoneNumberView;
@property (weak, nonatomic) IBOutlet UIView *verificationCodeView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;

@property (weak, nonatomic) IBOutlet UILabel *loginTitle;
@property (weak, nonatomic) IBOutlet UIButton *switchIdentityButton;
@property (strong ,nonatomic)NSString *codeId;


@end

@implementation PhoneLoginViewController
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
    [self hideKeyBoard];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI {

    //界面标题
    self.phoneTextField.placeholder = BEGetStringWithKeyFromTable(@"请输入手机号", @"P06A");
    self.verificationCodeTextField.placeholder = BEGetStringWithKeyFromTable(@"请输入验证码", @"P06A");
    self.loginTitle.text = BEGetStringWithKeyFromTable(@"手机号登录", @"P06A");
    [self.loginButton setTitle:BEGetStringWithKeyFromTable(@"登录", @"P06A") forState:UIControlStateNormal];
    [self.switchIdentityButton setTitle:BEGetStringWithKeyFromTable(@"切换身份？", @"P06A") forState:UIControlStateNormal];
    [self.verifyButton setTitle:BEGetStringWithKeyFromTable(@"发送验证码", @"P06A") forState:UIControlStateNormal];
    self.verifyButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [self setBorderWithView:self.phoneNumberView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0xeeeeee) borderWidth:1];
    [self setBorderWithView:self.verificationCodeView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0xeeeeee) borderWidth:1];
    self.loginButton.layer.cornerRadius = 5;
}
//关闭键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self hideKeyBoard];
}
-(void)hideKeyBoard{
    [self.view endEditing:YES];
}

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
#pragma mark - againButton

-(void)openCountdown {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);     //每秒执行
    
    NSTimeInterval seconds = 60.0f;
    NSDate *endTime = [NSDate dateWithTimeIntervalSinceNow:seconds];
    
    dispatch_source_set_event_handler(_timer, ^{
        int interval = [endTime timeIntervalSinceNow];
        if (interval > 0) {     //更新倒计时
            NSString *timeStr = [NSString stringWithFormat:BEGetStringWithKeyFromTable(@"%d秒后重发", @"P06A"), interval];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.verifyButton setTitle:timeStr forState:UIControlStateNormal];
                [self.verifyButton setTitleColor:UIColorFromHex(0X979797) forState:UIControlStateNormal];
                self.verifyButton.userInteractionEnabled = NO;
            });
        }else{      //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮的样式
                [self.verifyButton setTitle:BEGetStringWithKeyFromTable(@"发送验证码", @"P06A") forState:UIControlStateNormal];
                [self.verifyButton setTitleColor:UIColorFromHex(0XFB8557) forState:UIControlStateNormal];
                self.verifyButton.userInteractionEnabled = YES;
            });
        }
    });
    dispatch_resume(_timer);
    
}
- (IBAction)getVerifyCode:(id)sender {
    [self.verificationCodeTextField becomeFirstResponder];
    NSString *phone = self.phoneTextField.text;
    if([self isPhoneNumberValid:phone]){
        [self openCountdown];
        [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Users/Login_GetAckCode"]
                                      params:@{@"phone":phone}
                                    hasToken:NO
                                     success:^(HttpResponse *responseObject) {
                                         if ([responseObject.result integerValue]== 1) {
                                             self.codeId = [responseObject.content objectForKey:@"id"];
                                         }else{
                                             [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                         }
                                     }
                                     failure:nil];
    }else{
        [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"请输入正确的手机号", @"P06A")];
    }

}
-(void)showLoginingIndicator{
    
    [SVProgressHUD showWithStatus:BEGetStringWithKeyFromTable(@"正在登录中...", @"P06A")];
}
- (IBAction)login:(id)sender {
    [self.phoneTextField resignFirstResponder];
    [self.verificationCodeTextField resignFirstResponder];
    
    NSString *code = self.verificationCodeTextField.text;

    if(self.phoneTextField.text.length == 0){
        [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"手机号不能为空", @"P06A")];
        return;
    }else if(self.codeId == nil){
        [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"请获取验证码", @"P06A")];
        return;
    }else if(code.length != 6){
        [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"验证码为6位", @"P06A")];
        return;
    }
    [self showLoginingIndicator];

    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Users/LoginByPhoneCode"]
                                  params:@{
                                            @"id":self.codeId,
                                            @"ackcode":self.verificationCodeTextField.text
                                           }
                                hasToken:NO
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result integerValue]==1) {

//                                         NSDictionary *content = responseObject.content;
//                                         NSLog(@"receive content = %@",content);

                                         NSString *token = [responseObject.content objectForKey:@"token"];

                                         NSString *phone = [responseObject.content objectForKey:@"phone"];
                                         
                                         NSDictionary *patientInfoDic = [responseObject.content objectForKey:@"patientinfo"];
                                         
                                         NSString *name = [patientInfoDic objectForKey:@"name"];
//                                         NSString *idCart = [patientInfoDic objectForKey:@"idcard"];
                                         NSString *address = [patientInfoDic objectForKey:@"address"];
                                         NSNumber *age = [patientInfoDic objectForKey:@"age"];
                                         NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                                         NSString* ageString = [numberFormatter stringFromNumber:age];
                                         
                                         NSString *gender = [patientInfoDic objectForKey:@"gender"];

                                         [UserDefault setObject:phone forKey:@"PHONE_NUMBER"];
                                         [UserDefault setObject:name forKey:@"USER_NAME"];
                                         [UserDefault setObject:gender forKey:@"USER_GENDER"];
                                         [UserDefault setObject:ageString forKey:@"AGE"];
                                         [UserDefault setObject:address forKey:@"ADDRESS"];
                                         
                                         [UserDefault setObject:token forKey:@"Token"];
                                         [UserDefault setObject:@"patient" forKey:@"Identity"];
                                         
                                         [UserDefault setBool:YES forKey:@"IsLogined"];
                                         
                                         UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                         UINavigationController *centerNavi = [mainStoryboard instantiateViewControllerWithIdentifier:@"patient"];

                                         //初始化drawercontroller
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                              [self initDrawerWithCenterViewController:centerNavi];
//                                             [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                                         });
                                     }else{
                                         [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                     }
                                 }
                                 failure:nil];


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

-(BOOL)isPhoneNumberValid:(NSString *)mobileNum {
    
    if (mobileNum.length != 11)
    {
        return NO;
    }
    /**
     * 手机号码:
     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[6, 7, 8], 18[0-9], 170[0-9]
     * 移动号段: 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     * 联通号段: 130,131,132,155,156,185,186,145,176,1709
     * 电信号段: 133,153,180,181,189,177,1700
     */
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[0678])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     */
    NSString *CM = @"(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)";
    /**
     * 中国联通：China Unicom
     * 130,131,132,155,156,185,186,145,176,1709
     */
    NSString *CU = @"(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)";
    /**
     * 中国电信：China Telecom
     * 133,153,180,181,189,177,1700
     */
    NSString *CT = @"(^1(33|53|77|8[019])\\d{8}$)|(^1700\\d{7}$)";
    
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    //   NSString * PHS = @"^(0[0-9]{2})\\d{8}$|^(0[0-9]{3}(\\d{7,8}))$";
    
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
@end
