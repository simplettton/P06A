//
//  CheckCodeResultViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/28.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "CheckCodeResultViewController.h"

@interface CheckCodeResultViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation CheckCodeResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = BEGetStringWithKeyFromTable(@"更换手机号", @"P06A");
    [self.okButton setTitle:BEGetStringWithKeyFromTable(@"确认", @"P06A") forState:UIControlStateNormal];
    if (_isSuccess) {
        self.resultImageView.image = [UIImage imageNamed:@"checkCodeSuccess"];
        self.resultLabel.text = BEGetStringWithKeyFromTable(@"已经过安全检测，更换成功", @"P06A");
    }else{

        self.resultImageView.image = [UIImage imageNamed:@"checkCodeFail"];
        self.resultLabel.text = self.resultLabel.text = BEGetStringWithKeyFromTable(@"未通过安全检测，请稍后重试", @"P06A");
        
    }
    // Do any additional setup after loading the view.
}
- (IBAction)confirm:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
