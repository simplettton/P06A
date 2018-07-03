//
//  EditTreatAreaViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/3/7.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "EditTreatAreaViewController.h"

@interface EditTreatAreaViewController ()
@property(nonatomic,strong)NSString *selectedTreatArea;
@property(nonatomic,strong)NSArray *treatAreaArray;
@end

@implementation EditTreatAreaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"治疗部位";
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.treatAreaArray = @[@"手部",@"小臂",@"大臂",@"足部",@"小腿",@"大腿",@"腹部",@"背部",@"其他"];
    
    NSInteger index = [self.treatAreaArray indexOfObject:self.treatArea];

    UITableViewCell *cell = [[self.tableView visibleCells]objectAtIndex:index];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor =UIColorFromHex(0xebebeb);
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if (cell) {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            if (cellIndexPath != indexPath) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }else{
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            }
        }
    }
    self.selectedTreatArea = self.treatAreaArray[indexPath.row];
    
}
- (IBAction)save:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:self.selectedTreatArea forKey:@"TREAT_AREA"];
    [userDefault synchronize];
    [self.navigationController popViewControllerAnimated:YES];
    self.returnBlock(self.selectedRow,self.selectedTreatArea);
}
@end
