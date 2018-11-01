//
//  DistributeEquipmentViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/9/6.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DistributeEquipmentViewController.h"
#import "MJRefresh.h"
#import "AccountCell.h"
#define TAG_HOSPITAL 1003
#define TAG_AGENT 1002
@interface DistributeEquipmentViewController ()<UITableViewDelegate,UITableViewDataSource>{
    int page;
    int totalPage;  //总页数
    BOOL isRefreshing; //是否正在下拉刷新或者上拉加载
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *accountButtons;
@property (strong, nonatomic)NSString *selectedRole;
@property (strong, nonatomic)NSString *selectedUser;

@end

@implementation DistributeEquipmentViewController
{
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
    [self initTableHeaderAndFooter];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *button =[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finish:)];
    self.navigationItem.rightBarButtonItem = button;
}
#pragma mark - refresh

-(void)initTableHeaderAndFooter{
    
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.textColor =UIColorFromHex(0xABABAB);
    
    self.tableView.mj_header = header;
    [self refresh];
    
    //上拉加载
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    self.tableView.mj_footer = footer;
}
-(void)refresh {
    [self askForData:YES];
}

-(void)loadMore {
    [self askForData:NO];
}

-(void)endRefresh {
    
    if (page == 0) {
        [self.tableView.mj_header endRefreshing];
    }
    [self.tableView.mj_footer endRefreshing];
}

-(void)askForData:(BOOL)isRefresh{
//
//        datas = [[NSMutableArray alloc]initWithCapacity:20];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:20];
        
        [params setObject:self.selectedRole forKey:@"institutionstype"];
        
        [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Institutions/List?action=Count"]
                                      params:params
                                    hasToken:YES
                                     success:^(HttpResponse *responseObject) {
                                         
                                         if ([responseObject.result intValue] == 1)
                                         {
                                             NSString *count = responseObject.content[@"count"];
                                             
                                             //页数
                                             self->totalPage = ([count intValue]+7-1)/7;
                                             if (self->totalPage <= 1)
                                             {
                                                 self.tableView.mj_footer.hidden = YES;
                                             }
                                             else
                                             {
                                                 self.tableView.mj_footer.hidden = NO;
                                             }
                                             
                                             if ([count intValue] >0)
                                             {
                                                 [self getNetworkData:isRefresh];
                                             }
                                             else
                                             {
                                                 [self->datas removeAllObjects];
                                                 [self endRefresh];
                                                 [self.tableView reloadData];
                                             }
                                         }
                                         else
                                         {
                                             [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                         }
                                     } failure:nil];
        
    
}
-(void)getNetworkData:(BOOL)isRefresh{
    
    if (isRefresh) {
        page = 0;
    }else{
        page ++;
    }
    
    //配置请求http
    NSMutableDictionary *mutableParam = [[NSMutableDictionary alloc]init];
    
    [mutableParam setObject:self.selectedRole forKey:@"institutionstype"];
    [mutableParam setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    NSDictionary *params = (NSDictionary *)mutableParam;
    
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Institutions/List?action=List"]
                                  params:params
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     [self endRefresh];
                                     self->isRefreshing = NO;
                                     
                                     if (self->page == 0) {
                                         [self->datas removeAllObjects];
                                     }
                                     
                                     if (self->isRefreshing) {
                                         if (self->page >= self->totalPage) {
                                             [self endRefresh];
                                         }
                                         return;
                                     }
                                     
                                     self->isRefreshing = YES;
                                     
                                     //上拉加载更多
                                     if (self->page >=self->totalPage) {
                                         [self endRefresh];
                                         [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                         return;
                                     }
                                     
                                     if ([responseObject.result intValue] == 1) {
                                         NSArray *content = responseObject.content;
                                         if ([content count]>0) {
                                             for (NSDictionary *dataDic in responseObject.content) {
                                                 if (![self->datas containsObject:dataDic]) {
                                                     [self->datas addObject:dataDic];
                                                 }
                                             }
                                         }
                                            [self.tableView reloadData];
                                     }
                                 } failure:nil];
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
    
    [self refresh];
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
        NSDictionary *dataDic = [datas objectAtIndex:indexPath.row];
        cell.userNameLabel.text = [dataDic objectForKey:@"name"];
        
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
    
    self.selectedUser = [dataDic objectForKey:@"id"];
}
#pragma mark - action
- (IBAction)finish:(id)sender {
    if (self.selectedUser == nil) {
        [SVProgressHUD showErrorWithStatus:@"请选择分配账号"];
    }else{
        [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Device/registered"]
                                      params:@{
                                               @"serialnum":self.serialNum,
                                               @"cpuid":self.cpuid,
                                               @"institutionsid":self.selectedUser
                                               }
                                    hasToken:YES
                                     success:^(HttpResponse *responseObject) {
                                         if ([responseObject.result intValue] == 1) {
                                             BOOL isAddNew = [[responseObject.content objectForKey:@"isaddnew"]boolValue];
                                             NSString *showMessage = [[NSString alloc]init];
                                             if (isAddNew) {
                                                 showMessage = @"已录入设备";
                                             }else{
                                                 showMessage = @"已换绑序列号";
                                             }
                                             [SVProgressHUD showSuccessWithStatus:showMessage];
                                             [self.navigationController popViewControllerAnimated:YES];
                                         }else{
                                             [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                         }
                                     }
                                     failure:nil];
        }
    }
 

@end
