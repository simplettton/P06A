//
//  UserHomeViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/4.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "UserHomeViewController.h"
#import "SVProgressHUD.h"
#import "UIViewController+MMDrawerController.h"
#import "UIView+Tap.h"
#import "LeftDrawerViewController.h"

@interface UserHomeViewController ()
@property (weak, nonatomic) IBOutlet UIView *BLEView;
@property (weak, nonatomic) IBOutlet UIView *bindDeviceView;
@property (weak, nonatomic) IBOutlet UIView *MQTTView;
@property (weak, nonatomic) IBOutlet UIView *treatmentRecordView;
@property (weak, nonatomic) IBOutlet UIView *moreView;
- (IBAction)showMenu:(id)sender;


@end


@implementation UserHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTapToViews];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    //检测有没有绑定蓝牙设备
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"MacString"]) {
        [self performSegueWithIdentifier:@"GuideBindDevice" sender:nil];
    }
    
    
    NSArray *keys = [NSArray arrayWithObjects:@"USER_NAME",@"USER_SEX",@"age",@"phoneNumber",@"address", nil];
    NSArray *values = [NSArray arrayWithObjects:
                       @"游客",@"--",@"0",@"--",@"--", nil];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    

    for (int i = 0;i<[keys count];i++)
    {
        if (![userDefault objectForKey:keys[i]])
        {
            [userDefault setObject:values[i] forKey:keys[i]];
            [userDefault synchronize];
        }
    }

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:51/255.0f green:157/255.0f blue:231/255.0f alpha:1];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

    //蓝牙连接断开
    BabyBluetooth *baby = [BabyBluetooth shareBabyBluetooth];
    [baby cancelAllPeripheralsConnection];
    [SVProgressHUD dismiss];
    
}

-(void)addTapToViews {
    [self.BLEView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowBLEController" sender:nil];
    }];
    [self.bindDeviceView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowBondDeviceController" sender:nil];
    }];
    [self.MQTTView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowMQTTController" sender:nil];
    }];
    
}

- (IBAction)showMenu:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    LeftDrawerViewController *vc = (LeftDrawerViewController  *)self.mm_drawerController.leftDrawerViewController;
    vc.headerView.nickNameLabel.text =[NSString stringWithFormat:@"%@",[userDefault objectForKey:@"USER_NAME"]];
    if ([userDefault objectForKey:@"USER_ICON"])
    {
        UIImage *image=[UIImage imageWithData:[userDefault objectForKey:@"USER_ICON"]];
        vc.headerView.headerImageView.image =image;
    }
}
@end
