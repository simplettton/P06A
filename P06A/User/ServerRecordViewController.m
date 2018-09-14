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
#import "TreatmentRecordCell.h"
#define HTTPServerURLSting @"http://192.168.2.127/yun/fuya/index.php"
#define DeviceId @"P06A17A00001"
#define KeepMode 0x00
#define IntervalMode 0x01
#define DynamicMode 0x02
@interface ServerRecordViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *recordSumLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *accumulateTimeLabel;

@end

@implementation ServerRecordViewController
{
    NSInteger sum;
    NSMutableArray *datas;
    NSInteger numberOfPage;
    NSInteger accumulateTime;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Data/MyTreatRecord?action=Summary"]
                                  params:nil
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                    if ([responseObject.result integerValue] == 1) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            self.accumulateTimeLabel.text = [NSString stringWithFormat:@"%@",[responseObject.content objectForKey:@"hour"]];
                                            self.firstDateLabel.text = [responseObject.content objectForKey:@"firsttime"];
                                            self.lastDateLabel.text = [responseObject.content objectForKey:@"lasttime"];
                                            self.recordSumLabel.text = [NSString stringWithFormat:@"%@",[responseObject.content objectForKey:@"count"]];
                                            
                                            self->sum = [[responseObject.content objectForKey:@"count"]intValue];
                                        });

                                        
                                        NSLog(@"receive : %@",responseObject.content);                                    }else{
                                        [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                    }
                                 } failure:nil];
    
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
    
//    self.accumulateTimeLabel.text = [NSString stringWithFormat:@"4"];
//    self.firstDateLabel.text = [self stringFromTimeIntervalString:@"1530428999" dateFormat:@"yyyy/MM/dd"];
//    self.lastDateLabel.text = [self stringFromTimeIntervalString:@"1533107399" dateFormat:@"yyyy/MM/dd"];
//    self.recordSumLabel.text = @"10";
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithCapacity:20];
    [dictionary setObject:@"0" forKey:@"mode"];
    [dictionary setObject:@"50" forKey:@"press"];
    [dictionary setObject:@"35" forKey:@"dur"];
    [dictionary setObject:@"1532070599" forKey:@"date"];
    [datas addObject:dictionary];
    
    NSMutableDictionary *dictionary1 = [[NSMutableDictionary alloc]initWithCapacity:20];
    [dictionary1 setObject:@"1" forKey:@"mode"];
    [dictionary1 setObject:@"50" forKey:@"press"];
    [dictionary1 setObject:@"35" forKey:@"dur"];
    [dictionary1 setObject:@"1532502599" forKey:@"date"];
    [datas addObject:dictionary1];
    
    NSMutableDictionary *dictionary2 = [[NSMutableDictionary alloc]initWithCapacity:20];
    [dictionary2 setObject:@"2" forKey:@"mode"];
    [dictionary2 setObject:@"100" forKey:@"press"];
    [dictionary2 setObject:@"20" forKey:@"dur"];
    [dictionary2 setObject:@"1532761799" forKey:@"date"];
    [datas addObject:dictionary2];
    
    NSMutableDictionary *dictionary3 = [[NSMutableDictionary alloc]initWithCapacity:20];
    [dictionary3 setObject:@"2" forKey:@"mode"];
    [dictionary3 setObject:@"80" forKey:@"press"];
    [dictionary3 setObject:@"40" forKey:@"dur"];
    [dictionary3 setObject:@"1532848199" forKey:@"date"];
    [datas addObject:dictionary3];
    
}

-(void)startRequest{
    
}


-(void)getDataWithPage:(NSInteger)page {
    
    NetWorkTool *netWorkTool = [NetWorkTool sharedNetWorkTool];
    
    NSDictionary *parameter = @{
                                @"action":@"getonetreats",
                                @"page":[NSString stringWithFormat:@"%ld",(long)page],
                                @"id":DeviceId
                                };
    
    [netWorkTool POST:HTTPServerURLSting
           parameters:parameter
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSDictionary *jsonDict = responseObject;
                  if (jsonDict != nil) {
                      NSString *state = [jsonDict objectForKey:@"state"];
                      if ([state intValue] == 1) {
                          NSArray *dataDic = [jsonDict objectForKey:@"body"];
                          
                          for(NSDictionary *dic in dataDic){
                              self->accumulateTime += [[dic objectForKey:@"dur"]intValue]/60;
                              [self->datas addObject:dic];
                          }
                          dispatch_async(dispatch_get_main_queue(), ^{
                              
                              [self.tableView reloadData];
                              self.accumulateTimeLabel.text = [NSString stringWithFormat:@"%ld",(long)self->accumulateTime];
                          });
                      }
                  }
                  
                  NSLog(@"%@",responseObject);
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"error==%@",error);
              }];
}

#pragma mark - tableView delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    TreatmentRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
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
    
    
    //pressure
    NSString *pressure = [dataDic objectForKey:@"press"];
    cell.pressureLabel.text = [NSString stringWithFormat:@"-%@mmHg",pressure];
    
    //duration
    NSString *minutes = [dataDic objectForKey:@"dur"];
    cell.durationLabel.text = [NSString stringWithFormat:@"治疗时间%@分钟",minutes];
    
    int hour = [minutes intValue]/60;
    int minute= [minutes intValue]%60;
    int second= [minutes intValue]*60%60;
    //治疗时间为两位数
    NSString *hourString = [NSString stringWithFormat:hour>9?@"%d":@"0%d",hour];
    NSString *minString = [NSString stringWithFormat:minute>9?@"%d":@"0%d",minute];
    NSString *secondString = [NSString stringWithFormat:second>9?@"%d":@"0%d",second];
    
    cell.detailDurationLabel.text = [NSString stringWithFormat:@"%@:%@:%@",hourString,minString,secondString];
    
    
    
    //timestamp
    NSString *timeStamp = [dataDic objectForKey:@"date"];
    cell.dateLabel.text = [self stringFromTimeIntervalString:timeStamp dateFormat:@"M月d日"];
    cell.timeLabel.text = [self stringFromTimeIntervalString:timeStamp dateFormat:@"H:mm"];
    
    
    
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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowServerReport"]) {
        RecordRepordViewController *vc = (RecordRepordViewController *)segue.destinationViewController;
        vc.dic = sender;
    }
}


@end
