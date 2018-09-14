//
//  AddAccountViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/9/12.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

//md5加密头文件
#import<CommonCrypto/CommonDigest.h>
#import "AddAccountViewController.h"
#import "MJRefresh.h"
typedef NS_ENUM(NSInteger,KRole)
{
    Admin            = 0,
    CustomerService  = 1,
    Agent            = 2,
    Hospital         = 3,
    Doctor           = 4,
    Patient          = 5
};
@interface AddAccountViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *accountButtons;
@property (weak, nonatomic) IBOutlet UIView *accountTypeView;
@property (weak, nonatomic) IBOutlet UIView *infomationView;
@property (strong, nonatomic)NSString *selectedRole;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFileld;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *institutionTextField;
@end

@implementation AddAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新增账号";
    [self changeSelection:self.accountButtons[0]];
    [self setBorderWithView:self.accountTypeView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0xf4f4f4) borderWidth:2.0f];
    [self setBorderWithView:self.infomationView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0xf4f4f4) borderWidth:2.0f];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hideKeyBoard];
}

-(void)hideKeyBoard{
    [self.view endEditing:YES];
}
- (IBAction)changeSelection:(id)sender {
    for (UIButton *btn in self.accountButtons) {
        if ([btn tag] == [(UIButton *)sender tag]) {
            btn.backgroundColor = UIColorFromHex(0x5da9e9);

            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            btn.backgroundColor = UIColorFromHex(0xf8f8f8);
            
            [btn setTitleColor:UIColorFromHex(0x212121) forState:UIControlStateNormal];
        }
    }
    self.selectedRole = [NSString stringWithFormat:@"%ld",([sender tag]-1000)];

}
- (IBAction)save:(id)sender {
    NSString *username = self.userNameTextFileld.text;
    NSString *password = self.passwordTextField.text;
    NSString *institution = self.institutionTextField.text;

    if (username.length == 0 || password.length == 0 || institution.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"账号信息不能为空"];
        return;
    }else if(password.length <6){
        [SVProgressHUD showErrorWithStatus:@"密码不小于6位"];
        return;
    }else if(password.length >20){
        [SVProgressHUD showErrorWithStatus:@"密码不多于20位"];
        return;
    }
    NSString *md5Password = [self md5:password];
    [SVProgressHUD show];
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Users/CreateUserFast"]
                                  params:@{
                                         @"username":username,
                                         @"pwd":md5Password,
                                         @"institutionsname":institution,
                                         @"role":self.selectedRole
                                        }
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result integerValue] == 1) {
                                         [SVProgressHUD showSuccessWithStatus:@"新增成功"];
                                         [self.navigationController popViewControllerAnimated:YES];
                                     }else{
                                         [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                     }

                                 }
                                 failure:nil];
}
#pragma mark - Private method
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
