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
#import "AppDelegate.h"

@interface UserHomeViewController ()
@property (weak, nonatomic) IBOutlet UIView *BLEView;
@property (weak, nonatomic) IBOutlet UIView *singleRecordView;
@property (weak, nonatomic) IBOutlet UIView *doubleView;


/**
 * 需要中英文转换的标题
 */
@property (weak, nonatomic) IBOutlet UILabel *MQTTTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *BLETitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatRecordTitleLabel;


@property (weak, nonatomic) IBOutlet UIView *bindDeviceView;
@property (weak, nonatomic) IBOutlet UIView *MQTTView;
@property (weak, nonatomic) IBOutlet UIView *treatmentRecordView;
@property (weak, nonatomic) IBOutlet UIView *moreView;
- (IBAction)showMenu:(id)sender;
@end

@implementation UserHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addTapToViews];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    
    [self setUserDefault];
//    //检测有没有绑定蓝牙设备
//    if (![UserDefault objectForKey:@"MacString"]) {
//        [self performSegueWithIdentifier:@"GuideBindDevice" sender:nil];
//    }

    [self initUI];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:51/255.0f green:157/255.0f blue:231/255.0f alpha:1];
    [self initUI];
    
    LeftDrawerViewController *drawerVC = (LeftDrawerViewController  *)self.mm_drawerController.leftDrawerViewController;
    [drawerVC initAll];
}
-(void)setUserDefault
{
    
    NSDictionary *defaultDic = @{
                                 @"USER_NAME":            @"游客",
                                 @"USER_GENDER":          @"--",
                                 @"AGE":                  @"0",
                                 @"TREAT_AREA":           @"手部",
                                 @"PHONE_NUMBER":         @"--",
                                 @"ADDRESS":              @"--",
                                 @"COMMUNICATION_MODE":   @"BLE",
                                 };
    
    for (NSString *key in [defaultDic allKeys]) {
        if(![UserDefault objectForKey:key]){
            [UserDefault setObject:[defaultDic objectForKey:key] forKey:key];
            [UserDefault synchronize];
        }
    }
    

    NSString *hireString = [UserDefault objectForKey:@"HireId"];

    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Patient/HireMyList"]
                                  params:@{
                                           @"IsProcessOver":@0  //筛选正在租借的设备
                                           }
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result integerValue] == 1) {
                                         NSMutableArray *dataArray = responseObject.content;
                                         if ([dataArray count]>0) {
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 self.singleRecordView.hidden = YES;
                                                 self.doubleView.hidden = NO;
                                             });
                                             
                                             if(!hireString){
                                                 //默认获取第一个设备信息
                                                 NSDictionary *dataDic = [dataArray firstObject];
                                                 NSString *hireId = [dataDic objectForKey:@"hireid"];
                                                 NSString *cpuId = [dataDic objectForKey:@"cpuid"];
                                                 NSString *serialNum = [dataDic objectForKey:@"serialnum"];
                                                 NSString *hospital = [dataDic objectForKey:@"from"];
                                                 NSString *type = [dataDic objectForKey:@"type"];
                                                 NSString *macString = [dataDic objectForKey:@"mac"];
                                                 NSString *treatArea = [dataDic objectForKey:@"parts"];
                                                 
                                                 //保存设备信息
                                                 [UserDefault setObject:hireId forKey:@"HireId"];
                                                 [UserDefault setObject:treatArea forKey:@"TREAT_AREA"];
                                                 [UserDefault setObject:cpuId forKey:@"Cpuid"];
                                                 [UserDefault setObject:serialNum forKey:@"SerialNum"];
                                                 [UserDefault setObject:hospital forKey:@"Hospital"];
                                                 [UserDefault setObject:macString forKey:@"MacString"];
                                                 [UserDefault setObject:type forKey:@"MachineType"];
                                                 [UserDefault synchronize];
                                            }
                                         }else{
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 self.singleRecordView.hidden = NO;
                                                 self.doubleView.hidden = YES;
                                             });
                                         }
                                     }else{
                                         [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                     }
                                 }
                                 failure:nil];

}

-(void)initUI {

    self.singleRecordView.layer.cornerRadius = 10.0f;
    //切换MQTT模块或者蓝牙模块
    NSString *mode = [UserDefault objectForKey:@"COMMUNICATION_MODE"];
    self.BLEView.hidden = [mode isEqualToString:@"MQTT"];
    self.MQTTView.hidden = [mode isEqualToString:@"BLE"];
    
    //初始化三个模块标题
    self.BLETitleLabel.text = BEGetStringWithKeyFromTable(@"蓝牙通信", @"P06A");
    self.MQTTTitleLabel.text = BEGetStringWithKeyFromTable(@"远程监控", @"P06A");
    self.treatRecordTitleLabel.text = BEGetStringWithKeyFromTable(@"治疗记录", @"P06A");
    
    //导航栏标题
    self.title = BEGetStringWithKeyFromTable(@"便携负压", @"P06A");
}




-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];

    //蓝牙连接断开
    BabyBluetooth *baby = [BabyBluetooth shareBabyBluetooth];
    [baby cancelAllPeripheralsConnection];
    [baby cancelScan];
    [SVProgressHUD dismiss];

}

-(void)addTapToViews {
    
    [self.BLEView addTapBlock:^(id obj) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        if (appDelegate.isBLEPoweredOff) {
            [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"未打开蓝牙无法连接设备", @"P06A")];
        }else{
            [self performSegueWithIdentifier:@"ShowBLEController" sender:nil];
        }
    }];

    [self.MQTTView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowMQTTController" sender:nil];
    }];
    [self.treatmentRecordView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowServerRecordController" sender:nil];
    }];
    [self.singleRecordView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowServerRecordController" sender:nil];
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
