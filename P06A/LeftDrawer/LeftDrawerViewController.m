//
//  LeftDrawerViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/15.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "LeftDrawerViewController.h"
#import "MyDeviceTableViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "PersonalInfomationViewController.h"
#import "ContactUSTableViewController.h"
#import "SettingViewController.h"
#import "UpgradeOnlineViewController.h"
#import "EditPasswordController.h"
#import "AppDelegate.h"

#import "PhoneLoginViewController.h"
#import "PasswordLoginViewController.h"

@interface LeftDrawerViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong ,nonatomic)NSArray *functionArray;
@property (strong ,nonatomic)NSArray *imageNameArray;
@end

@implementation LeftDrawerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    //分割线样式
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    [self initAll];
}
-(void)initAll {
    NSString *identity = [UserDefault objectForKey:@"Identity"];
    //判断身份显示不同的界面
    if ([identity isEqualToString:@"patient"]) {
        [self.headerView.myInformationButton addTarget:self action:@selector(buttonClickListener:) forControlEvents:UIControlEventTouchUpInside];
        
        self.functionArray = @[
                               @"",
                               BEGetStringWithKeyFromTable(@"系统设置", @"P06A"),
                               BEGetStringWithKeyFromTable(@"我的设备", @"P06A"),
                               BEGetStringWithKeyFromTable(@"联系我们", @"P06A"),
                               @"",@"",@"",@"",@""
                               ];
        self.imageNameArray = @[@"",@"setting",@"star",@"service",@"",@"",@"",@"",@""];
    }else{
        self.functionArray = @[
                               @"",
                               BEGetStringWithKeyFromTable(@"在线升级", @"P06A"),
                               BEGetStringWithKeyFromTable(@"修改密码", @"P06A"),
                               @"",@"",@"",@"",@"",
                               BEGetStringWithKeyFromTable(@"退出登录", @"P06A")
                               ];
        self.imageNameArray = @[@"",@"setting",@"help",@"",@"",@"",@"",@"",@""];
    }
    [self.tableView reloadData];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }

    UILabel *textLabel = [cell viewWithTag:2];
    UIImageView *imageView = [cell viewWithTag:1];
    imageView.image = [UIImage imageNamed:[self.imageNameArray objectAtIndex:indexPath.row]];
    
    textLabel.text = [self.functionArray objectAtIndex:indexPath.row];
    
    if ([textLabel.text isEqualToString:@""]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row==8){
        NSString *identity = [UserDefault objectForKey:@"Identity"];
        //判断身份显示不同的界面
        if ([identity isEqualToString:@"admin"]) {
            textLabel.text = BEGetStringWithKeyFromTable(@"退出登录", @"P06A");
            [textLabel setTextColor:UIColorFromHex(0x65B8F3)];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *identity = [UserDefault objectForKey:@"Identity"];
    UIStoryboard *mainStoryborad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    __block UIViewController *showVC;
    if ([identity isEqualToString:@"patient"]) {

        NSInteger settingIndex = [self.functionArray indexOfObject:BEGetStringWithKeyFromTable(@"系统设置", @"P06A")];
        NSInteger myDeviceIndex = [self.functionArray indexOfObject:BEGetStringWithKeyFromTable(@"我的设备", @"P06A")];
        NSInteger contactUSIndex = [self.functionArray indexOfObject:BEGetStringWithKeyFromTable(@"联系我们", @"P06A")];
        if (indexPath.row == myDeviceIndex) {
            
            MyDeviceTableViewController *myDeviceVC = (MyDeviceTableViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"MyDeviceViewController"];
            
            showVC = myDeviceVC;
            [self pushViewController:showVC];
//            UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
//
//            [nav pushViewController:showVC animated:YES];
        }else if (indexPath.row == contactUSIndex){
            
            ContactUSTableViewController *contactUSVC = (ContactUSTableViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"ContactUSTableViewController"];
            showVC = contactUSVC;
            [self pushViewController:showVC];
//            UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
//
//            [nav pushViewController:showVC animated:YES];
        }else if(indexPath.row == settingIndex){
            
            SettingViewController *settingVC = (SettingViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"SettingViewController"];
            showVC = settingVC;
            [self pushViewController:showVC];
//            UINavigationController *nav = (UINavigationController *)self.mm_drawerController.centerViewController;
//            [nav pushViewController:showVC animated:YES];
            
        }
    }else{
        //用服
        
        NSInteger upgradeIndex = [self.functionArray indexOfObject:BEGetStringWithKeyFromTable(@"在线升级", @"P06A")];
        NSInteger changePWDIndex = [self.functionArray indexOfObject:BEGetStringWithKeyFromTable(@"修改密码", @"P06A")];
        if (indexPath.row == upgradeIndex) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            if (appDelegate.isBLEPoweredOff) {
                [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"未打开蓝牙无法升级设备", @"P06A")];
            }else{
                UpgradeOnlineViewController *upgradeVC = (UpgradeOnlineViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"UpgradeOnlineViewController"];
                showVC = upgradeVC;
                [self pushViewController:showVC];
            }
        }else if (indexPath.row == changePWDIndex){
            EditPasswordController *editPasswordVC = (EditPasswordController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"EditPasswordController"];
            showVC = editPasswordVC;
            [self pushViewController:showVC];
        }else if (indexPath.row==8) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:BEGetStringWithKeyFromTable(@"退出后不会删除任何历史数据，下次登录仍然可以使用本账号。", @"P06A")
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction* logoutAction = [UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"退出登录", @"P06A")
                                                                   style:UIAlertActionStyleDestructive
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     [UserDefault setBool:NO forKey:@"IsLogined"];
                                                                     [UserDefault synchronize];
                                                                     
                                                                     NSString *userIdentity = [UserDefault objectForKey:@"Identity"];
                                                                     
                                                                     if ([userIdentity isEqualToString:@"patient"]) {
                                                                         
                                                                         showVC = (PhoneLoginViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"PhoneLoginViewController"];
                                                                         
                                                                     }else{
                                                                         showVC = (PasswordLoginViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"PasswordLoginViewController"];
                                                                         
                                                                     }
                                                                     
                                                                     
                                                                     UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
                                                                     [nav pushViewController:showVC animated:YES];
                                                                     [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished)
                                                                      {
                                                                          [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                                                                      }];
                                                                     
                                                                     
                                                                 }];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"取消", @"P06A")
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * action) {}];
            
            [alert addAction:cancelAction];
            [alert addAction:logoutAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
 
    if (showVC)
    {
//        UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
//        [nav pushViewController:showVC animated:NO];
        [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished)
         {
             [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
         }];
    }
}

-(void)pushViewController:(UIViewController *)viewController
{
    UINavigationController *nav = (UINavigationController *)self.mm_drawerController.centerViewController;
    [nav pushViewController:viewController animated:YES];
}

-(void)buttonClickListener:(UIButton *)sender
{
    UIStoryboard *mainStoryborad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PersonalInfomationViewController *showVC = [mainStoryborad instantiateViewControllerWithIdentifier:@"PersonalInfomationViewController"];
    
    UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
    [nav pushViewController:showVC animated:NO];
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished)
     {
         [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
     }];
}


@end
