//
//  MyDeviceTableViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/3/9.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MyDeviceTableViewController.h"
#import "DeviceListView.h"
#import <SVProgressHUD.h>
@interface MyDeviceTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *macStringLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *hospitalLabel;
@end

@implementation MyDeviceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的设备";
    
    //默认选择第一个设备

    [self initSavedDeviceInfomation];
}
-(void)initSavedDeviceInfomation{
    
    NSString *serialNum = [UserDefault objectForKey:@"SerialNum"];
    NSString *hospital = [UserDefault objectForKey:@"Hospital"];
    NSString *type = [UserDefault objectForKey:@"MachineType"];
    NSString *macString = [UserDefault objectForKey:@"MacString"];
    
    self.serialNumLabel.text = serialNum;
    self.hospitalLabel.text = hospital;
    self.typeLabel.text = type;
    self.macStringLabel.text = macString;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    if(indexPath.section == 0){
        [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Patient/HireMyList"]
                                      params:@{}
                                    hasToken:YES
                                     success:^(HttpResponse *responseObject) {
                                         if ([responseObject.result integerValue] == 1) {
                                             NSMutableArray *dataArray = responseObject.content;
                                             if ([dataArray count]>0) {
                                                 [DeviceListView showAboveIn:self withData:dataArray returnBlock:^(NSDictionary *dataDic) {

                                                     NSString *cpuId = [dataDic objectForKey:@"cpuid"];
                                                     NSString *serialNum = [dataDic objectForKey:@"serialnum"];
                                                     NSString *hospital = [dataDic objectForKey:@"from"];
                                                     NSString *type = [dataDic objectForKey:@"type"];
                                                     NSString *macString = [dataDic objectForKey:@"mac"];
                                                     
                                                     self.serialNumLabel.text = serialNum;
                                                     self.hospitalLabel.text = hospital;
                                                     self.typeLabel.text = type;
                                                     self.macStringLabel.text = macString;
//                                                     
                                                     [UserDefault setObject:cpuId forKey:@"Cpuid"];
                                                     [UserDefault setObject:serialNum forKey:@"SerialNum"];
                                                     [UserDefault setObject:hospital forKey:@"Hospital"];
                                                     [UserDefault setObject:macString forKey:@"MacString"];
                                                     [UserDefault setObject:type forKey:@"MachineType"];
                                                     [UserDefault synchronize];
                                                 }];
                                             }
                                         }else{
                                             [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                         }
                                     }
                                     failure:nil];
        

    }else if (indexPath.section == 2) {
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
