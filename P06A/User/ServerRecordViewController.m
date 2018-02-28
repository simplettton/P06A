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
@interface ServerRecordViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ServerRecordViewController
{
    NSInteger sum;
    NSMutableArray *datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startRequest];
    [self getDataWithPage:1];
    self.title = @"治疗记录";
    [self initAll];
}

-(void)initAll{
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
                         NSLog(@"sum = %ld",(long)sum);
                     }else{
                         NSLog(@"error : state != 1");
                     }
                 }
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"error==%@",error);
             }];
}


-(void)getDataWithPage:(NSInteger)page {
    
    NetWorkTool *netWorkTool = [NetWorkTool sharedNetWorkTool];
    
    NSDictionary *parameter = @{
                                @"action":@"getalltreats",
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
                          NSDictionary *dataDic = [jsonDict objectForKey:@"body"];
                          datas = [[NSMutableArray alloc]initWithCapacity:20];
                          for(NSDictionary *dic in dataDic){
                              [datas addObject:dic];
                          }
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [self.tableView reloadData];
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





@end
