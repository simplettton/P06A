//
//  ServerRecordViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/2/27.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//


#import "ServerRecordViewController.h"
#import "RecordRepordViewController.h"
#import "NetWorkTool.h"
#import <MJRefresh.h>
#import "TreatmentRecordCell.h"
#import "PopoverView.h"
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

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *recordSumLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *accumulateTimeLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@property (strong,nonatomic)NSMutableArray *deviceArray;
@property (strong,nonatomic)NSString *hireId;

@end

@implementation ServerRecordViewController
{
    NSInteger numberOfPage;
    NSInteger accumulateTime;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"治疗记录";
    [self initAll];
}

-(void)initAll{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self initTableHeaderAndFooter];
    
    //右上角筛选菜单
    [self getDevices];
}
#pragma mark - filterButton
-(void)getDevices{
    self.deviceArray = [[NSMutableArray alloc]initWithCapacity:20];
    
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Patient/HireMyList"] params:@{} hasToken:YES success:^(HttpResponse *responseObject) {
        if ([responseObject.result intValue] ==1) {
                for (NSDictionary *dataDic in responseObject.content) {
                    if((![self.deviceArray containsObject:dataDic])){
                        [self.deviceArray addObject:dataDic];
                }
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
    if ([self.deviceArray count]>0) {
        for (NSDictionary *deviceDic in self.deviceArray) {
            NSString *title = deviceDic[@"serialnum"];
            PopoverAction *action = [PopoverAction actionWithTitle:title handler:^(PopoverAction *action) {
                
                NSString *hiredId = deviceDic[@"hireid"];
                self.hireId = hiredId;
                [self refresh];
            }];
            [actionArray addObject:action];
        }
    }

    //popoverView.showShade = YES; // 显示阴影背景
    //popoverView.style = PopoverViewStyleDark; // 设置为黑色风格
    //popoverView.hideAfterTouchOutside = NO; // 点击外部时不允许隐藏
    popoverView.arrowStyle = PopoverViewArrowStyleTriangle;
    [popoverView showToView:sender withActions:actionArray];
}

//-(void)testData{
//
//        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithCapacity:20];
//        [dictionary setObject:@"0" forKey:@"mode"];
//        [dictionary setObject:@"50" forKey:@"press"];
//        [dictionary setObject:@"35" forKey:@"duration"];
//        [dictionary setObject:@"1532070599" forKey:@"time"];
//        [datas addObject:dictionary];
//
//        NSMutableDictionary *dictionary1 = [[NSMutableDictionary alloc]initWithCapacity:20];
//        [dictionary1 setObject:@"1" forKey:@"mode"];
//        [dictionary1 setObject:@"50" forKey:@"press"];
//        [dictionary1 setObject:@"35" forKey:@"duration"];
//        [dictionary1 setObject:@"1532502599" forKey:@"time"];
//        [datas addObject:dictionary1];
//
//        NSMutableDictionary *dictionary2 = [[NSMutableDictionary alloc]initWithCapacity:20];
//        [dictionary2 setObject:@"2" forKey:@"mode"];
//        [dictionary2 setObject:@"100" forKey:@"press"];
//        [dictionary2 setObject:@"20" forKey:@"duration"];
//        [dictionary2 setObject:@"1532761799" forKey:@"time"];
//        [datas addObject:dictionary2];
//
//        NSMutableDictionary *dictionary3 = [[NSMutableDictionary alloc]initWithCapacity:20];
//        [dictionary3 setObject:@"2" forKey:@"mode"];
//        [dictionary3 setObject:@"80" forKey:@"press"];
//        [dictionary3 setObject:@"40" forKey:@"duration"];
//        [dictionary3 setObject:@"1532848199" forKey:@"time"];
//        [datas addObject:dictionary3];
//}
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
    NSMutableDictionary *parameter;
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
                                                 
                                             });
                                         }else{
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 self.accumulateTimeLabel.text = @"0";
                                                 self.firstDateLabel.text = @"/";
                                                 self.lastDateLabel.text = @"/";
                                                 self.recordSumLabel.text = @"0";
                                                 
                                             });
//                                             
//                                             [self->datas removeAllObjects];
//                                             [self endRefresh];

                                             [self.tableView reloadData];
                                         }
     
                                         
                                         
                                         NSLog(@"receive : %@",responseObject.content);                               }else{
                                             [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                         }
                                 } failure:nil];
}

-(void)endRefresh{
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
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
    if (self.hireId != nil) {
        [mutableParam setObject:self.hireId forKey:@"hireid"];
    }
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Data/MyTreatRecord?action=List"]
                                  params:mutableParam
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
                                     if ([responseObject.result integerValue] == 1) {
                                         NSArray *content = responseObject.content;
                                         if ([content count]>0) {
                                             NSLog(@"list = %@",content);
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
                                 failure:nil];
}

#pragma mark - tableView delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
            cell.modeLabel.text = @"动态模式";
            cell.modeImageView.image = [UIImage imageNamed:@"dynamic_grey"];
            break;
            
        case KeepMode:
            cell.modeLabel.text = @"连续模式";
            cell.modeImageView.image = [UIImage imageNamed:@"keep_grey"];
            break;
        
        case IntervalMode:
            cell.modeLabel.text = @"间隔模式";
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
    cell.durationLabel.text = [NSString stringWithFormat:@"治疗时间%@分钟",minutes];
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
    cell.dateLabel.text = [self stringFromTimeIntervalString:timeStamp dateFormat:@"M月d日"];
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
    }
}
@end
