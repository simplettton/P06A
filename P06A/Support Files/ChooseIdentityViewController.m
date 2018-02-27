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
- (IBAction)enterNextPage:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *doctorButton;
@property (weak, nonatomic) IBOutlet UIButton *patientButton;

@end

@implementation ChooseIdentityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
}

-(void)initAll {
    self.rightView.backgroundColor = HilightedColor;
    self.rightImageView.highlighted = YES;
    
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
    
}

- (IBAction)chooseRight:(id)sender {
    
    self.rightView.backgroundColor = HilightedColor;
    self.rightImageView.highlighted = YES;
    
    self.leftView.backgroundColor = NormalColor;
    self.leftImageView.highlighted = NO;
    
    //身份选择
    userIdentity = @"patient";
}

- (IBAction)chooseLeft:(id)sender {
    
    self.leftView.backgroundColor = HilightedColor;
    self.leftImageView.highlighted = YES;
    
    self.rightView.backgroundColor = NormalColor;
    self.rightImageView.highlighted = NO;
    
    //身份选择
    userIdentity = @"doctor";
}

- (IBAction)enterNextPage:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(!userIdentity){
        userIdentity = @"patient";
    }
    [userDefaults setObject:userIdentity forKey:@"Identity"];
    [userDefaults synchronize];
    [self performSegueWithIdentifier:@"ShowLoginVc" sender:nil];
}
@end
