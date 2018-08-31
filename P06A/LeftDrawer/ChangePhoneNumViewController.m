//
//  ChangePhoneNumViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/17.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ChangePhoneNumViewController.h"
#import "EnterVerificationCodeViewController.h"
@interface ChangePhoneNumViewController ()
@property (weak, nonatomic) IBOutlet UIButton *changePhoneNumberButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@end

@implementation ChangePhoneNumViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
//    [self.phoneNumberTextField becomeFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"更换手机号";
    self.navigationItem.backBarButtonItem =[ [UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.changePhoneNumberButton.layer.cornerRadius = 5.0f;
}

- (IBAction)changePhoneNumber:(id)sender {
    if ([self isPhoneNumberValid:self.phoneNumberTextField.text]) {
//        if([self.phoneNumberTextField.text isEqualToString:self.phoneNumber]){
//            [SVProgressHUD showErrorWithStatus:@"新手机号不能与旧手机号一致"];
//        }else{
            [self performSegueWithIdentifier:@"EnterVerificationCode" sender:nil];
//        }

    }else{
        [SVProgressHUD showErrorWithStatus:@"请输入有效手机号"];
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"EnterVerificationCode"]) {
        EnterVerificationCodeViewController *vc = (EnterVerificationCodeViewController* )segue.destinationViewController;
        vc.phoneNumber = self.phoneNumberTextField.text;
    }
}
#pragma mark - CheckPhoneNum
-(BOOL)isPhoneNumberValid:(NSString *)mobileNum{

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
