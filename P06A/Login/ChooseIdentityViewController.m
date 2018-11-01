//
//  ChooseIdentityViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/30.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ChooseIdentityViewController.h"
#define HilightedColor [UIColor colorWithRed:25.0/255.0 green:192.0/255.0 blue:190.0/255.0 alpha:1]
#define NormalColor [UIColor colorWithRed:18.0/255.0 green:184.0/255.0 blue:182.0/255.0 alpha:1]

@interface ChooseIdentityViewController ()
{
    NSString *userIdentity;
}
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;

- (IBAction)chooseRight:(id)sender;
- (IBAction)chooseLeft:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *doctorButton;
@property (weak, nonatomic) IBOutlet UIButton *patientButton;
@property (weak, nonatomic) IBOutlet UIButton *nextStepButton;
@property (weak, nonatomic) IBOutlet UIButton *leftChooseButton;
@property (weak, nonatomic) IBOutlet UIButton *rightChooseButton;

@end

@implementation ChooseIdentityViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initAll];
    
}

-(void)initAll {
    //界面标题
    [self.doctorButton setTitle:BEGetStringWithKeyFromTable(@"用服/助理", @"P06A") forState:UIControlStateNormal];
    [self.patientButton setTitle:BEGetStringWithKeyFromTable(@"患者/家属", @"P06A") forState:UIControlStateNormal];
    [self.leftChooseButton setTitle:BEGetStringWithKeyFromTable(@"点击选择>", @"P06A") forState:UIControlStateNormal];
    [self.rightChooseButton setTitle:BEGetStringWithKeyFromTable(@"点击选择>", @"P06A") forState:UIControlStateNormal];
    [self.nextStepButton setTitle:BEGetStringWithKeyFromTable(@"下一步>", @"P06A") forState:UIControlStateNormal];
    self.doctorButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.patientButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.leftChooseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.rightChooseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.nextStepButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    
    userIdentity = [UserDefault objectForKey:@"Identity"];
    if ([userIdentity isEqualToString:@"patient"]) {
        self.rightView.backgroundColor = HilightedColor;
        self.rightImageView.highlighted = YES;
    }else{
        self.leftView.backgroundColor = HilightedColor;
        self.leftImageView.highlighted = YES;
    }

    
    self.leftView.userInteractionEnabled = YES;
    self.rightView.userInteractionEnabled = YES;
    
    [self.leftView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                               action:@selector(chooseLeft:)]];
    [self.rightView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                action:@selector(chooseRight:)]];
    
    self.doctorButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.doctorButton.layer.cornerRadius = 5.0f;
    self.doctorButton.layer.borderWidth = 1.0f;
    
    self.patientButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.patientButton.layer.cornerRadius =5.0f;
    self.patientButton.layer.borderWidth = 1.0f;
    
    //默认选择患者身份
    NSString *identity = [UserDefault objectForKey:@"Identity"];
    if (!identity) {
        [self chooseRight:nil];
    }else{
        if ([identity isEqualToString:@"patient"]) {
            [self chooseRight:nil];
        }else{
            [self chooseLeft:nil];
        }
    }
}

- (IBAction)chooseRight:(id)sender {
    
    self.rightView.backgroundColor = HilightedColor;
    self.rightImageView.highlighted = YES;
    
    self.leftView.backgroundColor = NormalColor;
    self.leftImageView.highlighted = NO;
    
    //身份选择
    userIdentity = @"patient";
    [self enterNextPage];
}

- (IBAction)chooseLeft:(id)sender {
    
    self.leftView.backgroundColor = HilightedColor;
    self.leftImageView.highlighted = YES;
    
    self.rightView.backgroundColor = NormalColor;
    self.rightImageView.highlighted = NO;
    
    //身份选择
    userIdentity = @"admin";
    [self enterNextPage];
}
- (IBAction)next:(id)sender {
    [self enterNextPage];
}

- (void)enterNextPage{
    
     //保存选择的身份
    if(!userIdentity){
        userIdentity = @"patient";
    }
    [UserDefault setObject:userIdentity forKey:@"Identity"];
    [UserDefault synchronize];
    
    //根据不同身份进入不同的登录界面
    if ([userIdentity isEqualToString:@"patient"]) {
        [self performSegueWithIdentifier:@"ShowPatientLoginVC" sender:nil];
    }else{
        [self performSegueWithIdentifier:@"ShowAdminLoginVC" sender:nil];
    }
}
@end
