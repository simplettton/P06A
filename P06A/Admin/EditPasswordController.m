//
//  EditPasswordController.m
//  P06A
//
//  Created by Binger Zeng on 2018/9/11.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//
//md5加密头文件
#import<CommonCrypto/CommonDigest.h>
#import "EditPasswordController.h"

@interface EditPasswordController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassWordTextField;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishButton;

@end

@implementation EditPasswordController
- (IBAction)cancel:(id)sender {
    [self hideKeyBoard];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)done:(id)sender {
    [self hideKeyBoard];
    NSString *newPwd = self.passwordTextField.text;
    NSString *oldPwd = self.oldPasswordTextField.text;
    [SVProgressHUD show];
    if (![self.confirmPassWordTextField.text isEqualToString:newPwd]) {
        [SVProgressHUD showErrorWithStatus:@"请输入相同的密码"];
    }else{
        [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Users/ReSetSelfPwd"]
                                      params:@{
                                                   @"newpwd":[self md5:newPwd],
                                                   @"oldpwd":[self md5:oldPwd]
                                               }
                                    hasToken:YES
                                     success:^(HttpResponse *responseObject) {
                                         if ([responseObject.result intValue] == 1) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                                                 [self.navigationController popViewControllerAnimated:YES];
                                             });

                                         }else{
                                             NSLog(@"error = %@",responseObject.errorString);
                                             [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                         }
                                         
                                     } failure:nil];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置密码";
    
    [self initAll];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
}
-(void)hideKeyBoard{
    [self.view endEditing:YES];
    [self.tableView endEditing:YES];
    
}
-(void)initAll{
    
    for (UITextField *textField in self.textFields) {
        textField.layer.borderWidth = 0.5f;
        textField.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
        textField.leftView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 51)];
        textField.leftViewMode=UITextFieldViewModeAlways;
        textField.layer.cornerRadius = 5.0f;
    }
    self.finishButton.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
#pragma mark - UITextField Delegate
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [UIColor whiteColor];
}
-(void)tableView:(UITableView *)tableView willDisplayFooterView:(nonnull UIView *)view forSection:(NSInteger)section{
    
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    footer.contentView.backgroundColor= [UIColor whiteColor];
    [footer.textLabel setTextColor:UIColorFromHex(0x5e5e5e)];
    [footer.textLabel setFont:[UIFont systemFontOfSize:14]];
}


-(void)textFieldDidChange {
    if (self.oldPasswordTextField.text.length == 0 || self.passwordTextField.text.length == 0 || self.confirmPassWordTextField.text.length == 0 || self.oldPasswordTextField.text.length < 6 ||
        self.confirmPassWordTextField.text.length < 6 ||self.passwordTextField.text.length < 6) {
        self.finishButton.enabled = NO;
    } else {
        self.finishButton.enabled = YES;
    }
    for (UITextField *textField in self.textFields) {
        if (textField.text.length > 20) {
            textField.text = [textField.text substringToIndex:20];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 44;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
#pragma mark - private method
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
