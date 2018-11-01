//
//  ServerRecordViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/2/27.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <MJRefresh.h>
#import "ServerRecordViewController.h"
#import "RecordRepordViewController.h"
#import "MessageViewController.h"
#import "NetWorkTool.h"
#import "TreatmentRecordCell.h"
#import "PopoverView.h"
#import "UIImage+MessageImage.h"
#import "UIView+Tap.h"
#import "loadingView.h"
#import "ShadingLoadingView.h"

#define DeviceId @"P06A17A00001"
#define KeepMode 0x00
#define IntervalMode 0x01
#define DynamicMode 0x02

@interface ServerRecordViewController (){
    int page;
    int totalPage;
    BOOL isRefreshing;
    NSMutableArray *datas;
}
@property (weak, nonatomic) IBOutlet UIImageView *messageImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *recordSumLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *accumulateTimeLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@property (strong,nonatomic)NSMutableArray *deviceArray;
@property (strong,nonatomic)NSString *hireId;


@property (weak, nonatomic) IBOutlet UILabel *accumulateTimeTitle;
@property (weak, nonatomic) IBOutlet UILabel *hourTitle;
@property (weak, nonatomic) IBOutlet UILabel *finishTitle;
@property (weak, nonatomic) IBOutlet UILabel *beginDateTitle;
@property (weak, nonatomic) IBOutlet UILabel *finishDateTitle;


@end

@implementation ServerRecordViewController
{
    NSInteger numberOfPage;
    NSInteger accumulateTime;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = BEGetStringWithKeyFromTable(@"治疗记录", @"P06A");
    [self initAll];
}

-(void)initAll{
    
    //界面标题
    self.accumulateTimeTitle.text = BEGetStringWithKeyFromTable(@"你累计治疗时间", @"P06A");
    self.hourTitle.text = [NSString stringWithFormat:@"(%@)",BEGetStringWithKeyFromTable(@"小时", @"P06A")];
    self.finishTitle.text = BEGetStringWithKeyFromTable(@"完成（次）", @"P06A");
    self.beginDateTitle.text = BEGetStringWithKeyFromTable(@"开始治疗日期", @"P06A");
    self.finishDateTitle.text = BEGetStringWithKeyFromTable(@"最近治疗日期", @"P06A");
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    //跳转消息界面
    [self.messageImage addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowMessage" sender:nil];
    }];
    //右上角筛选菜单
    [self getDevices];

}
#pragma mark - filterButton
-(void)getDevices{
    self.deviceArray = [[NSMutableArray alloc]initWithCapacity:20];
    [ShadingLoadingView showLoadingViewInView:self.view];
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Patient/HireMyList"] params:@{} hasToken:YES success:^(HttpResponse *responseObject) {
        if ([responseObject.result intValue] ==1) {
                for (NSDictionary *dataDic in responseObject.content) {
                    if((![self.deviceArray containsObject:dataDic])){
                        [self.deviceArray addObject:dataDic];
                }
                    self.hireId = [responseObject.content firstObject][@"hireid"];
                     [self initTableHeaderAndFooter];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                    });
            }
        }else{
            [SVProgressHUD showErrorWithStatus:responseObject.errorString];
        }
    } failure:nil];
}
- (IBAction)rightButtonAction:(id)sender {
    PopoverView *popoverView = [PopoverView popoverView];
    NSMutableArray *actionArray = [[NSMutableArray alloc]initWithCapacity:20];
    
    //全部tab
    if (!self.hireId) {
        PopoverAction *allAction = [PopoverAction actionWithImage:[UIImage imageNamed:@"pickStar"] title:[NSString stringWithFormat:@"%@",@"全部"] handler:^(PopoverAction *action) {
            NSString *hiredId = nil;
            self.hireId = hiredId;
            [self refresh];
        }];
        [actionArray addObject:allAction];
    } else {
        PopoverAction *allAction = [PopoverAction actionWithTitle:[NSString stringWithFormat:@"\t%@",@"全部"] handler:^(PopoverAction *action) {
            self.hireId = nil;
            [self refresh];
        }];
        
        [actionArray addObject:allAction];
    }
    
    //有序号的tab
    if ([self.deviceArray count]>0) {
        for (NSDictionary *deviceDic in self.deviceArray) {
//            NSString *date = [self stringFromTimeIntervalString:deviceDic[@"starttime"] dateFormat:@"M/d "];
            NSString *title = @"";
            if ([deviceDic[@"hireid"]isEqualToString:self.hireId]) {
                //当前选中的租借设备打钩标记
//                title = [NSString stringWithFormat:@"%@%@",date,deviceDic[@"serialnum"]];
                title = [NSString stringWithFormat:@"%@",deviceDic[@"serialnum"]];
                PopoverAction *action = [PopoverAction actionWithImage:[UIImage imageNamed:@"pickStar"] title:title handler:^(PopoverAction *action) {
                    NSString *hiredId = deviceDic[@"hireid"];
                    self.hireId = hiredId;
                    [self refresh];
                }];
                [actionArray addObject:action];
            }
            else{
                //未选中的租借设备不打钩
//                title = [NSString stringWithFormat:@"\t  %@%@",date,deviceDic[@"serialnum"]];
                title = [NSString stringWithFormat:@"\t%@",deviceDic[@"serialnum"]];
                PopoverAction *action = [PopoverAction actionWithTitle:title handler:^(PopoverAction *action) {
                    
                    NSString *hiredId = deviceDic[@"hireid"];
                    self.hireId = hiredId;
                    [self refresh];
                }];
                [actionArray addObject:action];
            }
        }
    }
    
    //popoverView.showShade = YES; // 显示阴影背景
    //popoverView.style = PopoverViewStyleDark; // 设置为黑色风格
    //popoverView.hideAfterTouchOutside = NO; // 点击外部时不允许隐藏
    popoverView.arrowStyle = PopoverViewArrowStyleTriangle;
    [popoverView showToView:sender withActions:actionArray];
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
    [footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    self.tableView.mj_footer = footer;
}

-(void)refresh{
    [self askForData:YES];
}
-(void)loadMore{
    [self askForData:NO];
}
-(void)askForData:(BOOL)isRefresh{
//    [SVProgressHUD showWithStatus:@"正在加载中..."];
//    [loadingView showLoadingViewInView:self.view];

    NSMutableDictionary *parameter = [[NSMutableDictionary alloc]initWithCapacity:20];
    if (self.hireId != nil) {
        [parameter setObject:self.hireId forKey:@"hireid"];
    }
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Data/MyTreatRecord?action=Summary"]
                                  params:parameter
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
 
                                     if ([responseObject.result integerValue] == 1) {
                                         
                                         NSNumber *count = responseObject.content[@"count"];
                                         //页数
                                         self->totalPage = ([count intValue]+7-1)/7;
                                         if (self->totalPage <= 1) {
                                             self.tableView.mj_footer.hidden = YES;
                                         }else{
                                             self.tableView.mj_footer.hidden = NO;
                                         }
                                         if ([count intValue]>0) {
                                             //获取列表数据
                                             [self getNetworkData:isRefresh];
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 NSNumber *hour = [responseObject.content objectForKey:@"hour"];
                                                 self.accumulateTimeLabel.text = [self formatFloat:[hour floatValue]];
                                                 self.firstDateLabel.text = [responseObject.content objectForKey:@"firsttime"];
                                                 self.lastDateLabel.text = [responseObject.content objectForKey:@"lasttime"];
                                                 self.recordSumLabel.text = [NSString stringWithFormat:@"%@",[responseObject.content objectForKey:@"count"]];
                                                 NSInteger newlog = [[responseObject.content objectForKey:@"newlog"]integerValue];
                                                 
                                                 //UIImage+MessageImage 显示未读消息
                                                 self.messageImage.image = [[UIImage imageNamed:@"newlog"] hh_messageImageWithCount:newlog imageSize:CGSizeMake(30, 30) tipRadius:9 tipTop:9 tipRight:9  fontSize:12 textColor:nil tipColor:nil];
                                                 [self.messageImage sizeToFit];
                                             });
                                         }else{
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
//                                                 [SVProgressHUD dismiss];
//                                                 [loadingView stopAnimation];
                                                 [ShadingLoadingView stopAnimation];
                                                 self.accumulateTimeLabel.text = @"0";
                                                 self.firstDateLabel.text = @"/";
                                                 self.lastDateLabel.text = @"/";
                                                 self.recordSumLabel.text = @"0";
                                                 
                                             });
                                             
                                             [self->datas removeAllObjects];
                                             [self endRefresh];

                                             [self.tableView reloadData];
                                         }
                                     }else{
                                             [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                         }
                                 } failure:^(NSError *error){
//                                     [loadingView stopAnimation];
//                                     [SVProgressHUD dismiss];
                                     [ShadingLoadingView stopAnimation];
                                 }];
}

-(void)endRefresh {
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}
-(void)getNetworkData:(BOOL)isRefresh {
    if (isRefresh) {
        page = 0;
    }else{
        page ++;
    }
    //配置请求http
    NSMutableDictionary *mutableParam = [[NSMutableDictionary alloc]init];
    [mutableParam setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    if (self.hireId != nil) {
        [mutableParam setObject:self.hireId forKey:@"hireid"];
    }
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Data/MyTreatRecord?action=List"]
                                  params:mutableParam
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
//                                     [SVProgressHUD dismiss];
//                                     [loadingView stopAnimation];
                                     [ShadingLoadingView stopAnimation];
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
                                     if ([responseObject.result integerValue] == 1) {
                                         NSArray *content = responseObject.content;
                                         if ([content count]>0) {
                                             for (NSDictionary *dataDic in responseObject.content) {
                                                    if (![self->datas containsObject:dataDic]) {
                                                    [self->datas addObject:dataDic];
                                                 }
                                             }
                                         }
                                         [self.tableView reloadData];
                                     }else{
                                         [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                     }
                                 }
                                 failure:^(NSError *error){
//                                     [SVProgressHUD dismiss];
//                                     [loadingView stopAnimation];
                                     [ShadingLoadingView stopAnimation];
                                 }];
}

#pragma mark - tableView delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    TreatmentRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[TreatmentRecordCell init]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //mode
    NSDictionary *dataDic = [datas objectAtIndex:indexPath.row];
    NSInteger mode = [[dataDic objectForKey:@"mode"]intValue];
    switch (mode) {
            
        case DynamicMode:
            cell.modeLabel.text = BEGetStringWithKeyFromTable(@"动态模式", @"P06A");
            cell.modeImageView.image = [UIImage imageNamed:@"dynamic_grey"];
            break;
            
        case KeepMode:
            cell.modeLabel.text = BEGetStringWithKeyFromTable(@"连续模式", @"P06A");
            cell.modeImageView.image = [UIImage imageNamed:@"keep_grey"];
            break;
        
        case IntervalMode:
            cell.modeLabel.text = BEGetStringWithKeyFromTable(@"间隔模式", @"P06A");
            cell.modeImageView.image = [UIImage imageNamed:@"interval_grey"];
            break;
            
        default:
            break;
    }

    //press
    NSString *pressure = [dataDic objectForKey:@"press"];
    cell.pressureLabel.text = [NSString stringWithFormat:@"-%@mmHg",pressure];
    
    //duration
    NSString *minutes = [dataDic objectForKey:@"duration"];
    cell.durationLabel.text = [NSString stringWithFormat:BEGetStringWithKeyFromTable(@"治疗时间%@分钟", @"P06A"),minutes];
//
//    int hour = [minutes intValue]/60;
//    int minute= [minutes intValue]%60;
//    int second= [minutes intValue]*60%60;
//    //治疗时间为两位数
//    NSString *hourString = [NSString stringWithFormat:hour>9?@"%d":@"0%d",hour];
//    NSString *minString = [NSString stringWithFormat:minute>9?@"%d":@"0%d",minute];
//    NSString *secondString = [NSString stringWithFormat:second>9?@"%d":@"0%d",second];
//
//    cell.detailDurationLabel.text = [NSString stringWithFormat:@"%@:%@:%@",hourString,minString,secondString];
    
    //treatArea
    cell.treatAreaLabel.text = [dataDic objectForKey:@"parts"];

    //timestamp
    NSString *timeStamp = [dataDic objectForKey:@"time"];
    cell.dateLabel.text = [self stringFromTimeIntervalString:timeStamp dateFormat:@"M/d"];
    cell.timeLabel.text = [self stringFromTimeIntervalString:timeStamp dateFormat:@"H:mm"];

    //alertCount
    NSNumber *count = [dataDic objectForKey:@"warningcount"];
    if ([count integerValue]>0) {
        cell.alertImageView.hidden = NO;
    }else{
        cell.alertImageView.hidden = YES;
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ShowServerReport" sender:datas[indexPath.row]];
}

#pragma mark - privateMethod
//时间戳字符串转化为日期或时间
- (NSString *)stringFromTimeIntervalString:(NSString *)timeString dateFormat:(NSString*)dateFormat
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateFormat];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}
- (NSString *)formatFloat:(float)f
{
    if (fmodf(f, 1)==0) {    //如果有一位小数点
        return [NSString stringWithFormat:@"%.0f",f];
    } else if (fmodf(f*10, 1)==0) {     //如果有两位小数点
        return [NSString stringWithFormat:@"%.1f",f];
    } else {
        return [NSString stringWithFormat:@"%.2f",f];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowServerReport"]) {
        RecordRepordViewController *vc = (RecordRepordViewController *)segue.destinationViewController;
        vc.dic = sender;
        vc.recordId = sender[@"recordid"];
        vc.hasImage = [sender[@"imgexist"]boolValue];
        vc.hasAlertMessage = [sender[@"warningcount"]integerValue]>0;
    }else if([segue.identifier isEqualToString:@"ShowMessage"]){
        MessageViewController *vc = (MessageViewController *)segue.destinationViewController;
        vc.hireId = self.hireId;
    }
}
@end
