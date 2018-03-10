//
//  MyDeviceTableViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/3/9.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MyDeviceTableViewController.h"
#import <SVProgressHUD.h>
#import <MBProgressHUD.h>
@interface MyDeviceTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *macStringLabel;
@property (strong,nonatomic)MBProgressHUD *HUD;
@end

@implementation MyDeviceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的设备";
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *string = [userDefault objectForKey:@"MacString"];
    self.macStringLabel.text = string;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 2;
//
//}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to thenew view controller.
}
*/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"设备解除绑定后，您需要重新绑定新的设备，才能够正常测量，确定要解除绑定吗？" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"解除绑定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            
            
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.HUD.mode = MBProgressHUDModeText;
            
            if ([userDefault objectForKey:@"MacString"]) {
                self.HUD.label.text = @"当前没有绑定设备";
                [self.HUD showAnimated:YES];
                [self.HUD hideAnimated:YES afterDelay:0.9];
                
            }else{
                [userDefault setObject:@"" forKey:@"MacString"];
                [userDefault synchronize];
                //            [SVProgressHUD showSuccessWithStatus:@"解绑成功"];
                

                self.HUD.label.text = @"解绑成功";
                [self.HUD showAnimated:YES];
                [self.HUD hideAnimated:YES afterDelay:0.5];
                
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
