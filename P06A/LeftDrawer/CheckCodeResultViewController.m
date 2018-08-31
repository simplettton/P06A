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

@end

@implementation CheckCodeResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"更换手机号";
    if (_isSuccess) {
        self.resultImageView.image = [UIImage imageNamed:@"checkCodeSuccess"];
        self.resultLabel.text = @"已经过安全检测，更换成功";
    }else{
        self.resultImageView.image = [UIImage imageNamed:@"checkCodeFail"];
        self.resultLabel.text = @"未通过安全检测，请稍后重试";
        
    }
    // Do any additional setup after loading the view.
}
- (IBAction)confirm:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
