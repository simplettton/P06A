//
//  ServerRecordViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/2/27.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ServerRecordViewController.h"
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startRequest];
//    [self getDataWithPage:4];
    self.title = @"治疗记录";
    [self initAll];
}

-(void)initAll{
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

-(void)startRequest{

    
    NetWorkTool *netWorkTool = [NetWorkTool sharedNetWorkTool];
    
    NSDictionary *parameters = @{
                                    @"action":@"getonetreatsum",
                                    @"id":DeviceId
                                 };

    [netWorkTool POST:HTTPServerURLSting
           parameters:parameters
             progress:^(NSProgress * _Nonnull uploadProgress) {

             } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 NSDictionary *jsonDict = responseObject;
                 if (jsonDict != nil) {
                     NSString *state = [jsonDict objectForKey:@"state"];

                     if ([state intValue] == 1) {
                         sum = [[jsonDict objectForKey:@"sum"]intValue];
                         numberOfPage = (sum +10-1)/10;
                         
                         for (int i =0; i < numberOfPage; i++) {
                             [self getDataWithPage:i];
                         }
                         
                         
                         //更新总数UI
                         self.recordSumLabel.text = [jsonDict objectForKey:@"sum"];

                         
                         //获取第一页
                         NetWorkTool *netWorkTool = [NetWorkTool sharedNetWorkTool];
                         NSDictionary *parameter = @{
                                                     @"action":@"getalltreats",
                                                     @"page":@"0",
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
                                               NSArray *dataArray = [jsonDict objectForKey:@"body"];
                                               NSDictionary *firstDataDic = [dataArray objectAtIndex:0];
                                               NSString *timeStamp = [firstDataDic objectForKey:@"date"];
                                               
                                               //upload lase treatment date
                                               self.lastDateLabel.text = [self stringFromTimeIntervalString:timeStamp dateFormat:@"yyyy/MM/dd"];
                                           }
                                       }
                                       
                                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                       NSLog(@"error==%@",error);
                                   }];
                         
                         
                         
                     //获取最后一页
                         parameter = @{
                                         @"action":@"getalltreats",
                                         @"page":[NSString stringWithFormat:@"%ld",numberOfPage -1],
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
                                               NSArray *dataArray = [jsonDict objectForKey:@"body"];
                                               NSDictionary *firstDataDic = [dataArray lastObject];
                                               NSString *timeStamp = [firstDataDic objectForKey:@"date"];
                                               
                                               //upload lase treatment date
                                               self.firstDateLabel.text = [self stringFromTimeIntervalString:timeStamp dateFormat:@"yyyy/MM/dd"];
                                           }
                                       }
                                       
                                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                       NSLog(@"error==%@",error);
                                   }];
                         
                         
                         
                         
                         
                         
                     }
                 }
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"error==%@",error);
             }];
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
                              accumulateTime += [[dic objectForKey:@"dur"]intValue];
                              [datas addObject:dic];
                          }
                          dispatch_async(dispatch_get_main_queue(), ^{
                              
                              [self.tableView reloadData];
                              self.accumulateTimeLabel.text = [NSString stringWithFormat:@"%ld",(long)accumulateTime];
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
            cell.modeLabel.text = @"动态吸引";
            cell.modeImageView.image = [UIImage imageNamed:@"dynamic_grey"];
            break;
            
        case KeepMode:
            cell.modeLabel.text = @"持续吸引";
            cell.modeImageView.image = [UIImage imageNamed:@"keep_grey"];
            break;
        
        case IntervalMode:
            cell.modeLabel.text = @"间歇吸引";
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





@end
