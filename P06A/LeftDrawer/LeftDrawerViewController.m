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
#import "LoginViewController.h"
#import "PersonalInfomationViewController.h"
#import "ContactUSTableViewController.h"
#import "SettingViewController.h"
#import "BaseHeader.h"

#import "PhoneLoginViewController.h"
#import "PasswordLoginViewController.h"

@interface LeftDrawerViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong ,nonatomic)NSArray *functionArray;
@property (strong ,nonatomic)NSArray *imageNameArray;
@end

@implementation LeftDrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    //分割线样式
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    
    NSString *identity = [UserDefault objectForKey:@"Identity"];
    //判断身份显示不同的界面
    if ([identity isEqualToString:@"patient"]) {
        [self.headerView.myInformationButton addTarget:self action:@selector(buttonClickListener:) forControlEvents:UIControlEventTouchUpInside];
        self.functionArray = @[@"",@"设置",@"我的设备",@"联系我们",@"帮助",@"",@"",@"",@"退出登录"];
        self.imageNameArray = @[@"",@"setting",@"star",@"service",@"help",@"",@"",@"",@""];
    }else{
        self.functionArray = @[@"",@"",@"",@"",@"",@"",@"",@"",@"退出登录"];
        self.imageNameArray = @[@"",@"",@"",@"",@"",@"",@"",@"",@""];
    }

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
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

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
        textLabel.text = @"退出登录";
        [textLabel setTextColor:UIColorFromHex(0x65B8F3)];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *identity = [UserDefault objectForKey:@"Identity"];
    UIStoryboard *mainStoryborad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    __block UIViewController *showVC;
    if ([identity isEqualToString:@"patient"]) {

        NSInteger settingIndex = [self.functionArray indexOfObject:@"设置"];
        NSInteger myDeviceIndex = [self.functionArray indexOfObject:@"我的设备"];
        NSInteger contactUSIndex = [self.functionArray indexOfObject:@"联系我们"];
        if (indexPath.row == myDeviceIndex) {
            
            MyDeviceTableViewController *myDeviceVC = (MyDeviceTableViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"MyDeviceViewController"];
            
            showVC = myDeviceVC;
            
            UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
            
            [nav pushViewController:showVC animated:YES];
        }else if (indexPath.row == contactUSIndex){
            
            ContactUSTableViewController *contactUSVC = (ContactUSTableViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"ContactUSTableViewController"];
            showVC = contactUSVC;
            UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
            
            [nav pushViewController:showVC animated:YES];
        }else if(indexPath.row == settingIndex){
            
            SettingViewController *settingVC = (SettingViewController *)[mainStoryborad instantiateViewControllerWithIdentifier:@"SettingViewController"];
            showVC = settingVC;
            UINavigationController *nav = (UINavigationController *)self.mm_drawerController.centerViewController;
            [nav pushViewController:showVC animated:YES];
            
        }
    }else{
        //用服
    }
 
    if (indexPath.row==8) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@"退出后不会删除任何历史数据，下次登录依然可以使用本账号。"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* logoutAction = [UIAlertAction actionWithTitle:@"立即退出"
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
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:cancelAction];
        [alert addAction:logoutAction];
        [self presentViewController:alert animated:YES completion:nil];
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
