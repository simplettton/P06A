//
//  EnterVerificationCodeViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/17.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "EnterVerificationCodeViewController.h"
#import "CheckCodeViewController.h"
#import "MQVerCodeInputView.h"
@interface EnterVerificationCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *verCodeView;
@property (weak, nonatomic) IBOutlet UIButton *regainButton;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;


@property (weak, nonatomic) IBOutlet UILabel *sendMessageTitle;
@property (weak, nonatomic) IBOutlet UILabel *cannotGetCodeTitle;

@property (strong,nonatomic)NSString *codeId;
@property (strong,nonatomic)NSString *ackCode;
@end

@implementation EnterVerificationCodeViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

}
- (IBAction)regainCode:(id)sender {
    [self getVerifyCode];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = BEGetStringWithKeyFromTable(@"更换手机号", @"P06A");
    self.sendMessageTitle.text = BEGetStringWithKeyFromTable(@"我们已发送 验证码 短信到您的手机： ", @"P06A");
    [self.regainButton setTitle:BEGetStringWithKeyFromTable(@"重新获取", @"P06A")forState:UIControlStateNormal];
    self.cannotGetCodeTitle.text = BEGetStringWithKeyFromTable(@"收不到验证码短信？", @"P06A");
    
    self.navigationItem.backBarButtonItem =[ [UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.phoneNumberLabel.text = self.phoneNumber;

    [self getVerifyCode];
    
    /**
     * 验证码框
     */
    MQVerCodeInputView *verView = [[MQVerCodeInputView alloc]initWithFrame:CGRectMake(25, 25, kScreenW - 50, 50)];
    verView.maxLenght = 6;//最大长度
    verView.keyBoardType = UIKeyboardTypeNumberPad;
    [verView mq_verCodeViewWithMaxLenght];
    verView.block = ^(NSString *text){
        NSLog(@"text = %@",text);
        if ([text length] == 6) {
            if (self.codeId) {
                self.ackCode = text;
                [self performSegueWithIdentifier:@"CheckCode" sender:nil];
            }else{
                [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"请获取验证码 ", @"P06A")];
                
            }

        }
    };
//    verView.center = self.verCodeView.center;
    [self.verCodeView addSubview:verView];
}

-(void)getVerifyCode{
    [self openCountdown];
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Users/BindingPhone_GetAckCode"]
                                  params:@{
                                           @"phone":self.phoneNumber
                                           }
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result integerValue] == 1) {
                                         self.codeId = [responseObject.content objectForKey:@"id"];
                                     }else{
                                         [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                     }
                                 }
                                 failure:nil];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CheckCode"]) {
        CheckCodeViewController *vc = (CheckCodeViewController *)segue.destinationViewController;
        if (self.codeId) {
            vc.codeId = self.codeId;
        }
        vc.ackCode = self.ackCode;
        vc.phoneNumber = self.phoneNumber;
    }
}
-(void)openCountdown {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);     //每秒执行
    
    NSTimeInterval seconds = 30.0f;
    NSDate *endTime = [NSDate dateWithTimeIntervalSinceNow:seconds];
    
    dispatch_source_set_event_handler(_timer, ^{
        int interval = [endTime timeIntervalSinceNow];
        if (interval > 0) {     //更新倒计时
            NSString *timeStr = [NSString stringWithFormat:BEGetStringWithKeyFromTable(@"收短信大概需要%ds", @"P06A"), interval];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.countDownLabel.hidden = NO;
                self.countDownLabel.text = timeStr;
                self.regainButton.userInteractionEnabled = NO;
                [self.regainButton setTitleColor:UIColorFromHex(0x979797) forState:UIControlStateNormal];
            });
        }else{      //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮的样式
                [self.regainButton setTitleColor:UIColorFromHex(0x1296DB) forState:UIControlStateNormal];
                self.regainButton.userInteractionEnabled = YES;
                self.countDownLabel.hidden = YES;
            });
        }
    });
    dispatch_resume(_timer);
    
}

@end
