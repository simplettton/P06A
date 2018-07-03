//
//  MyDeviceTableViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/3/9.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MyDeviceTableViewController.h"
#import <SVProgressHUD.h>
@interface MyDeviceTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *macStringLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumLabel;
@end

@implementation MyDeviceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的设备";
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *string = [userDefault objectForKey:@"MacString"];
    self.macStringLabel.text = string;
    self.serialNumLabel.text = @"";
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"设备解除绑定后，您需要重新绑定新的设备，才能够正常测量，确定要解除绑定吗？" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"解除绑定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            
            if (![userDefault objectForKey:@"MacString"]) {
                [SVProgressHUD showErrorWithStatus:@"当前没有绑定设备"];
                
            }else{
                [userDefault setObject:nil forKey:@"MacString"];
                [userDefault synchronize];
                [SVProgressHUD showSuccessWithStatus:@"解绑成功"];
                
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC));
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });

            }
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
@end
