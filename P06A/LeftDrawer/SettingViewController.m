//
//  SettingViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/15.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "SettingViewController.h"
#import "PhoneLoginViewController.h"
#import "PasswordLoginViewController.h"
#import "UIViewController+MMDrawerController.h"
@interface SettingViewController ()

@end

@implementation SettingViewController{
    NSString *selectedCommunicationMode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([UserDefault objectForKey:@"COMMUNICATION_MODE"]) {
        selectedCommunicationMode = [UserDefault objectForKey:@"COMMUNICATION_MODE"];
    }else{
        selectedCommunicationMode = @"BLE";
    }

}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self initUI];
}
-(void)initUI{

    UITableViewCell *BLECell =  self.tableView.visibleCells[0];
    UITableViewCell *MQTTCell = self.tableView.visibleCells[1];
    
    if ([selectedCommunicationMode isEqualToString:@"BLE"]) {
        BLECell.accessoryType = UITableViewCellAccessoryCheckmark;
        MQTTCell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        BLECell.accessoryType = UITableViewCellAccessoryNone;
        MQTTCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *view = [[UIView alloc]init];
    view.backgroundColor=UIColorFromHex(0xeeeeee);
    cell.selectedBackgroundView=view;
    
    //退出的section
    if (indexPath.section == 2) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"退出后不会删除任何历史记录，下次登录依然可以使用本账号。" preferredStyle:UIAlertControllerStyleActionSheet];
        
        //退出登录
        UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"立即退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [UserDefault setBool:NO forKey:@"IsLogined"];
            [UserDefault synchronize];
            
            UIViewController *loginVC;
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            NSString *userIdentity = [UserDefault objectForKey:@"Identity"];
            if ([userIdentity isEqualToString:@"patient"]) {
                loginVC = (PhoneLoginViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"PhoneLoginViewController"];
            }else{
                loginVC = (PasswordLoginViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"PasswordLoginViewController"];
            }
            UINavigationController* nav = (UINavigationController*)self.mm_drawerController.centerViewController;
            [nav pushViewController:loginVC animated:YES];
            [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished)
             {
                 [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
             }];
        }];
        
        //取消
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancelAction];
        [alert addAction:logoutAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        //除了退出的section选择打钩
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            if (cell) {
                NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                //同个section比较！
                if(cellIndexPath.section == indexPath.section){
                    if (cellIndexPath != indexPath) {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }else{
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                }
            }
        }
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {   //蓝牙通信
                selectedCommunicationMode = @"BLE";
            }else{      //远程通信
                selectedCommunicationMode = @"MQTT";
            }
        }
    }
}
- (IBAction)save:(id)sender {
    [UserDefault setObject:selectedCommunicationMode forKey:@"COMMUNICATION_MODE"];
    [UserDefault synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
