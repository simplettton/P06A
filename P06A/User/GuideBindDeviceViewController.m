//
//  GuideBindDeviceViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/19.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "GuideBindDeviceViewController.h"
#import <MBProgressHUD.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface GuideBindDeviceViewController ()<CBCentralManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (strong,nonatomic) CBCentralManager *bluetoothManager;
@end

@implementation GuideBindDeviceViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.addButton.layer.cornerRadius = 10;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]init];
    backButton.title = @"返回";
    self.navigationItem.backBarButtonItem = backButton;
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.hidden = NO;
}
- (IBAction)backToMain:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSString *message = nil;
    switch (central.state) {

        case CBManagerStateUnsupported:
            message = @"设备蓝牙不支持,请检查系统设置";
            break;
        case CBManagerStateUnauthorized:
            message = @"设备蓝牙未授权,请检查系统设置";
            break;
        case CBManagerStatePoweredOff:
        {
            message = @"设备尚未打开蓝牙,请在设置中打开";
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.mode = MBProgressHUDModeText;
            HUD.label.text = @"设备尚未打开蓝牙,请在设置中打开";
            [HUD showAnimated:YES];
        }
            break;
        case CBManagerStatePoweredOn:
            message = @"蓝牙已经成功开启,请稍后再试";
             
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            break;
        default:
            break;
    }
    if(message!=nil&&message.length!=0)
    {
        NSLog(@"message == %@",message);
    }
}

@end
