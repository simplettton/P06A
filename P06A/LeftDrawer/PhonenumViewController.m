//
//  PhonenumViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/14.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PhonenumViewController.h"

@interface PhonenumViewController ()
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *changePhoneNumberButton;

@end

@implementation PhonenumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"手机号";
    self.phoneNumberLabel.text = self.phoneNumber;
    self.changePhoneNumberButton.layer.cornerRadius = 5.0f;
}

@end
