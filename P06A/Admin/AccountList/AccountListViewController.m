//
//  AccountListViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/9/13.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AccountListViewController.h"
#import "AccountListCell.h"
#import <MJRefresh.h>
@interface AccountListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    int page;
    int totalPage;
    BOOL isRefreshing;
    NSMutableArray *datas;
}
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@end

@implementation AccountListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"机构列表";
    [self initAll];
}
-(void)initAll{
    self.tableView.tableFooterView = [[UIView alloc]init];
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    self.navigationItem.backBarButtonItem =[ [UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self setBorderWithView:self.titleView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0XBEBEBE) borderWidth:0.5f];
    [self setBorderWithView:self.buttomView top:YES left:NO bottom:NO right:NO borderColor:UIColorFromHex(0X6D9BCB) borderWidth:0.5f];
    [self initTableHeaderAndFooter];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self refresh];
}
#pragma mark - Refresh
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
    [footer setTitle:@"---END---" forState:MJRefreshStateNoMoreData];
    self.tableView.mj_footer = footer;
}
-(void)refresh{
    [self askForData:YES];
}
-(void)loadMore{
    [self askForData:NO];
}
-(void)askForData:(BOOL)isRefresh{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:20];
    [params setObject:@"3" forKey:@"institutionstype"];
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Institutions/List?action=Count"]
                                  params:params
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     
                                     if ([responseObject.result intValue] == 1) {
                                         NSString *count = responseObject.content[@"count"];
                                         
                                         //页数
                                         self->totalPage = ([count intValue]+7-1)/7;
                                         if (self->totalPage <= 1) {
                                             self.tableView.mj_footer.hidden = YES;
                                         }else{
                                             self.tableView.mj_footer.hidden = NO;
                                         }
                                         if ([count intValue] >0) {
                                             
                                             [self getNetworkData:isRefresh];
                                             

                                         }else{
                                             [self->datas removeAllObjects];
                                             [self endRefresh];
                                             [self.tableView reloadData];
                                         }
                                     }else{
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
    [mutableParam setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [mutableParam setObject:@"3" forKey:@"institutionstype"];
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

-(void)endRefresh{
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}
#pragma mark - Tableview DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [datas count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AccountListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[AccountListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    if ([datas count]>0) {
        self.tableView.tableHeaderView.hidden = NO;
        NSDictionary *dataDic = [datas objectAtIndex:indexPath.row];

        
//        NSDictionary *roleDic = @{
//                                      @0:@"系统管理员",
//                                      @1:@"用服工程师",
//                                      @2:@"代理商",
//                                      @3:@"医院",
//                                      @4:@"医生",
//                                      @5:@"患者"
//                                 };
        NSDictionary *institutionDic = @{
                                         @0:@"公司",
                                         @1:@"代理商机构",
                                         @2:@"医院"
                                         };
        NSNumber *institutionType = [dataDic objectForKey:@"institutionstype"];
        cell.roleLabel.text = institutionDic[institutionType];
        cell.organizationLabel.text = [dataDic objectForKey:@"name"];
        
    }else{
        self.tableView.tableHeaderView.hidden = YES;
    }
    return cell;
}
- (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width
{
    
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height - width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width - width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}
@end
