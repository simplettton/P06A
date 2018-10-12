//
//  SettingViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/15.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//
#define CNS @"zh-Hans"
#define EN @"en"
#define LANGUAGE_SET @"LANGUAGESET"

#import "SettingViewController.h"
#import "PhoneLoginViewController.h"
#import "PasswordLoginViewController.h"
#import "UIViewController+MMDrawerController.h"
@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *BLETitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *MQTTTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *logoutTitleLabel;

@end

@implementation SettingViewController{
    NSString *selectedCommunicationMode;
    NSString *selectedLanguage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([UserDefault objectForKey:@"COMMUNICATION_MODE"]) {
        selectedCommunicationMode = [UserDefault objectForKey:@"COMMUNICATION_MODE"];
    }else{
        selectedCommunicationMode = @"BLE";
    }
    
    if ([UserDefault objectForKey:LANGUAGE_SET]) {
        selectedLanguage = [UserDefault objectForKey:LANGUAGE_SET];
    }else{
        selectedLanguage = CNS;
    }
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self initUI];
}
-(void)initUI{

    //导航栏标题
    self.title = BEGetStringWithKeyFromTable(@"设置",@"P06A");
    //savebutton
    self.navigationItem.rightBarButtonItem.title = BEGetStringWithKeyFromTable(@"保存", @"P06A");
    
    //界面文字
    self.BLETitleLabel.text = BEGetStringWithKeyFromTable(@"蓝牙通信", @"P06A");
    self.MQTTTitleLabel.text = BEGetStringWithKeyFromTable(@"远程监控", @"P06A");
    self.logoutTitleLabel.text = BEGetStringWithKeyFromTable(@"退出登录", @"P06A");
    
    UITableViewCell *BLECell =  self.tableView.visibleCells[0];
    UITableViewCell *MQTTCell = self.tableView.visibleCells[1];
    UITableViewCell *chineseCell = self.tableView.visibleCells[2];
    UITableViewCell *englishCell = self.tableView.visibleCells[3];
    
    //通信方式
    
    if ([selectedCommunicationMode isEqualToString:@"BLE"]) {
        BLECell.accessoryType = UITableViewCellAccessoryCheckmark;
        MQTTCell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        BLECell.accessoryType = UITableViewCellAccessoryNone;
        MQTTCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    //语言设置
    
    if ([selectedLanguage isEqualToString:CNS]) {
        chineseCell.accessoryType = UITableViewCellAccessoryCheckmark;
        englishCell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        chineseCell.accessoryType = UITableViewCellAccessoryNone;
        englishCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return BEGetStringWithKeyFromTable(@"通信方式", @"P06A");
            break;
        case 1:
            return BEGetStringWithKeyFromTable(@"语言切换", @"P06A");
            break;
        default:
            return nil;
            break;
    }

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
        }else if (indexPath.section == 1){
            if (indexPath.row == 0) {   //中文
                selectedLanguage = CNS;
            }else{  //英文s
                selectedLanguage = EN;
            }
        }
    }
}
- (IBAction)save:(id)sender {
    [UserDefault setObject:selectedCommunicationMode forKey:@"COMMUNICATION_MODE"];
//    [UserDefault setObject:selectedLanguage forKey:LANGUAGE_SET];
//    [UserDefault synchronize];
    [[BELanguageTool sharedInstance]setNewLanguage:selectedLanguage];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
