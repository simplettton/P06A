//
//  LoginWithPhoneViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/7/4.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "LoginWithPhoneViewController.h"

@interface LoginWithPhoneViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak, nonatomic) IBOutlet UIButton *vertifyButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginWithPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"手机号快捷登录";
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self setBorderWithView:self.borderView top:YES left:NO bottom:NO right:NO borderColor:[UIColor groupTableViewBackgroundColor] borderWidth:0.5f];
    [self setBorderWithView:self.vertifyButton top:NO left:YES bottom:NO right:NO borderColor:[UIColor groupTableViewBackgroundColor] borderWidth:0.5f];
    
    [self.phoneTextField becomeFirstResponder];
    self.phoneTextField.delegate = self;
    self.verifyCodeTextField.delegate = self;
    
    //实时监听uitextfield值变化的方法
    [self.verifyCodeTextField addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.phoneTextField addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else if(section == 1){
        return 1;
    }
    return 1;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        cell.backgroundColor = [UIColor clearColor];
       
    }
}
#pragma mark - textField delegate

-(void)changedTextField:(id)sender{
        if (![self.phoneTextField.text isEqualToString:@""] ) {
            if (![self.verifyCodeTextField.text isEqualToString:@""]) {
                [self.loginButton setBackgroundColor:UIColorFromHex(0x1296d8)];
            }else{
                [self.loginButton setBackgroundColor:UIColorFromHex(0x8ABFF3)];
            }
        }else{
            [self.loginButton setBackgroundColor:UIColorFromHex(0x8ABFF3)];
        }
}

#pragma mark - private method

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
            NSString *timeStr = [NSString stringWithFormat:@"%d秒后重发", interval];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.vertifyButton setTitle:timeStr forState:UIControlStateNormal];
                [self.vertifyButton setTitleColor:UIColorFromHex(0X979797) forState:UIControlStateNormal];
                self.vertifyButton.userInteractionEnabled = NO;
            });

            
        }else{      //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
            //设置按钮的样式
            [self.vertifyButton setTitle:@"发送验证码" forState:UIControlStateNormal];
            [self.vertifyButton setTitleColor:UIColorFromHex(0XFB8557) forState:UIControlStateNormal];
            self.vertifyButton.userInteractionEnabled = YES;
            });
            
        }
    });
    dispatch_resume(_timer);

}
- (IBAction)getVerifyCode:(id)sender {
    [self openCountdown];
}

@end
