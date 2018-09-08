//
//  DistributeEquipmentViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/9/6.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DistributeEquipmentViewController.h"
#import "AccountCell.h"
#define TAG_HOSPITAL 1003
#define TAG_AGENT 1002
@interface DistributeEquipmentViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIStackView *accountTypeView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *accountButtons;
@property (strong, nonatomic)NSString *selectedRole;
@property (strong, nonatomic)NSString *selectedUser;

@end

@implementation DistributeEquipmentViewController{
    NSMutableArray *datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"分配设备";
    [self initAll];

}
-(void)initAll{
    self.tableView.tableFooterView = [[UIView alloc]init];
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    
    [self changeSelection:self.accountButtons[0]];
}
- (IBAction)changeSelection:(id)sender {
    for (UIButton *btn in self.accountButtons) {
        if ([btn tag] == [(UIButton *)sender tag]) {
            btn.backgroundColor = UIColorFromHex(0x5da9e9);
            
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            btn.backgroundColor = UIColorFromHex(0xf8f8f8);
            
            [btn setTitleColor:UIColorFromHex(0x212121) forState:UIControlStateNormal];
        }
    }
    self.selectedRole = [NSString stringWithFormat:@"%ld",([sender tag]-1000)];
    
    [self getNetworkData];
}

-(void)getNetworkData {
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Users/List?action=List"]
                                  params:@{
                                                @"role":self.selectedRole
                                           }
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result integerValue] == 1) {
                                         NSArray *dataArray = responseObject.content;
                                         if ([dataArray count]>0) {
                                             self.tableView.tableHeaderView.hidden = NO;
                                             NSLog(@"userlist = %@",responseObject.content);
                                             for (NSDictionary *dataDic in responseObject.content) {
                                                 if (![self->datas containsObject:dataDic]) {
                                                     [self->datas addObject:dataDic];
                                                 }
                                             }
                                         }else{
                                             self.tableView.tableHeaderView.hidden = YES;
                                         }
                                         [self.tableView reloadData];
                                     }else{
                                         [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                     }
                                 }
                                 failure:nil];
}
#pragma mark - Tableview DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [datas count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[AccountCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    if ([datas count]>0) {
        self.tableView.tableHeaderView.hidden = NO;
        NSDictionary *dataDic = [datas objectAtIndex:indexPath.row];
        cell.userNameLabel.text = [dataDic objectForKey:@"username"];
        cell.noteLabel.text = [dataDic objectForKey:@"from"];
        
    }else{
        self.tableView.tableHeaderView.hidden = YES;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AccountCell *cell = [tableView.visibleCells objectAtIndex:indexPath.row];
    for (AccountCell *cell in tableView.visibleCells) {
        cell.selectedView.image = [UIImage imageNamed:@"unselected"];
    }
    cell.selectedView.image = [UIImage imageNamed:@"selected"];
    NSDictionary *dataDic = [datas objectAtIndex:indexPath.row];
    
    self.selectedUser = [dataDic objectForKey:@"username"];
}
#pragma mark - action
- (IBAction)finish:(id)sender {
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Device/registered"]
                                  params:@{
                                               @"serialnum":self.serialNum,
                                               @"cpuid":self.cpuid,
                                               @"username":self.selectedUser
                                           }
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result intValue] == 1) {
                                         [SVProgressHUD showSuccessWithStatus:@"录入成功"];
                                         [self.navigationController popViewControllerAnimated:YES];
                                     }else{
                                         [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                     }
                                           }
                                 failure:nil];
}

@end
