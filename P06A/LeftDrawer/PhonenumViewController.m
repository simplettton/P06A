//
//  PhonenumViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/14.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PhonenumViewController.h"
#import "ChangePhoneNumViewController.h"
@interface PhonenumViewController ()
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *changePhoneNumberButton;

@property (weak, nonatomic) IBOutlet UILabel *phoneNumTitle;
@end

@implementation PhonenumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = BEGetStringWithKeyFromTable(@"手机号", @"P06A");
    self.phoneNumTitle.text = BEGetStringWithKeyFromTable(@"手机号", @"P06A");
    [self.changePhoneNumberButton setTitle:BEGetStringWithKeyFromTable(@"更换手机号", @"P06A") forState:UIControlStateNormal];
    
    self.phoneNumberLabel.text = self.phoneNumber;
    self.changePhoneNumberButton.layer.cornerRadius = 5.0f;
    self.navigationItem.backBarButtonItem =[ [UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ChangePhoneNum"]) {
        ChangePhoneNumViewController *vc = (ChangePhoneNumViewController *)segue.destinationViewController;
        vc.phoneNumber = self.phoneNumber;
        
    }
}
@end
