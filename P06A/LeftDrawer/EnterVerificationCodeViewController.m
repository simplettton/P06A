//
//  EnterVerificationCodeViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/17.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "EnterVerificationCodeViewController.h"

@interface EnterVerificationCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;

@end

@implementation EnterVerificationCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneNumberLabel.text = self.phoneNumber;
}

@end
