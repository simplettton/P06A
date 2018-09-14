//
//  BLERecordViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/2/5.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "BLERecordViewController.h"
#import "Unpack.h"
#import "Pack.h"
#define CMDID_RECORD_SUM    0X0C
#define CMDID_PAGE_RECORD   0X10

@interface BLERecordViewController ()
{
    NSInteger sum;
    NSInteger currentPage;
    NSInteger numberOfPages;
    NSMutableArray *datas;
}
- (IBAction)nextPage:(id)sender;
- (IBAction)previousPage:(id)sender;

@property (strong ,nonatomic)NSMutableData *readBuf;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *pageLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIView *pageView;
@property (weak, nonatomic) IBOutlet UIView *headView;

@end

@implementation BLERecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"治疗记录";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = [[UIView alloc]init];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self initAll];
    
    [self writeWithCmdid:CMDID_RECORD_SUM dataString:@"0000"];
    [self performSelector:@selector(getData) withObject:nil afterDelay:0.01];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if(self.receiveCharacteristic!=nil) {
        
        //通知监听characteristic的值
        [baby notify:self.currPeripheral
      characteristic:self.receiveCharacteristic
               block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                   NSLog(@"BLERecordController----------------------------------------------");
                   
                   NSData *data = self.receiveCharacteristic.value;
                   if (data) {
                       [self.readBuf appendData:data];
                       [self analyzeReceivedData];
                   }

               }];
    }
    
    datas = [[NSMutableArray alloc]initWithCapacity:20];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    if(self.receiveCharacteristic){
        [baby cancelNotify:self.currPeripheral characteristic:self.receiveCharacteristic];
    }
}


-(void)initAll{
    self.readBuf = [[NSMutableData alloc]init];
    self.headView.layer.borderColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1].CGColor;
    self.headView.layer.borderWidth = 1.0f;
    currentPage = 0;
}

#pragma mark - tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    RecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[RecordTableViewCell init]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if ([datas count]>0)
    {
        
        cell.numberLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row +1];
        NSString *treatWayString= @"";
        switch ([[datas[indexPath.row]objectForKey:@"Mode"]intValue])
        {
            case 0:
                treatWayString = @"连续模式";
                break;
            case 1:
                treatWayString = @"间隔模式";
                break;
            case 2:
                treatWayString = @"动态模式";
                break;
            default:
                treatWayString = @"治疗模式";
                break;
        }
        //治疗方式
        cell.treatWayLabel.text = [NSString stringWithFormat:@"%@",treatWayString];
        
        //治疗日期
        NSString *dateString = [datas[indexPath.row] objectForKey:@"Date"];
        if ([dateString isEqualToString:@"0"]) {
            cell.treatTimeLabel.text = @"";
        }
        else{
            cell.treatTimeLabel.text = [NSString stringWithFormat:@"%@",[self timeWithTimeIntervalString:dateString]];
        }
        
        //治疗时间
        cell.durationLabel.text = [NSString stringWithFormat:@"%@min",[datas[indexPath.row]objectForKey:@"Duration"]];
        
        //治疗压力
        cell.pressureLabel.text = [NSString stringWithFormat:@"-%@mmHg",[datas[indexPath.row]objectForKey:@"Pressure"]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - receiveData
//处理数据粘包问题
-(void)analyzeReceivedData {
    while (self.readBuf.length >= 2) {
        
        NSData *head = [_readBuf subdataWithRange:NSMakeRange(0, 2)];//取得头部数据
        
        NSData *lengthData = [head subdataWithRange:NSMakeRange(1, 1)];//取得长度数据
        
        NSInteger length;
        
        length = *((Byte *)([lengthData bytes]));
        
        NSInteger complateDataLength = length + 4;
        
        if (_readBuf.length >= complateDataLength)//如果缓存中数据够一个整包的长度
        {
            NSData *data = [_readBuf subdataWithRange:NSMakeRange(0, complateDataLength)];//截取一个包的长度(处理粘包)
            [self handleCompleteData:data];//处理包数据
            //从缓存中截掉处理完的数据,继续循环
            _readBuf = [NSMutableData dataWithData:[_readBuf subdataWithRange:NSMakeRange(complateDataLength, _readBuf.length - complateDataLength)]];
        }
        else//如果缓存中的数据长度不够一个包的长度，则包不完整(处理半包，继续                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      读取)
        {
            _readBuf = [[NSMutableData alloc]init];
            return;
        }
    }
}

-(void)handleCompleteData :(NSData *)receivedData {
    NSData *data = [Unpack unpackData:receivedData];
    if (data)
    {
        Byte *dataByte = (Byte *)[data bytes];
        Byte cmdid = dataByte[0];
        switch (cmdid) {
            case CMDID_RECORD_SUM:
                //记录总量
                sum = dataByte[1];
                numberOfPages = (sum+10-1)/10;
                
                self.pageLabel.text = [NSString stringWithFormat:@"%ld / %ld",(long)currentPage + 1,(long)numberOfPages];
                NSLog(@"sum = %ld",(long)sum);
                break;
            case CMDID_PAGE_RECORD:
            {

                //治疗模式
                NSString *mode = [NSString stringWithFormat:@"%d",dataByte[1]];
                
                //治疗压力
                NSString *pressure = [NSString stringWithFormat:@"%d",dataByte[2]];
                
                //治疗时间
                Byte durationBytes[] = {     dataByte[3],dataByte[4]     };
                UInt16 durationTime = [self lBytesToInt:durationBytes withLength:2];
                NSString *duration = [NSString stringWithFormat:@"%d",durationTime];
                
                //治疗日期
                Byte treatTime[] = {    dataByte[5],dataByte[6],dataByte[7],dataByte[8] };
                NSString *timeStamp = [NSString stringWithFormat:@"%d",[self lBytesToInt:treatTime withLength:4]];
                
                
                NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]initWithCapacity:30];
                [dataDic setObject:mode forKey:@"Mode"];
                [dataDic setObject:timeStamp forKey:@"Date"];
                [dataDic setObject:pressure forKey:@"Pressure"];
                [dataDic setObject:duration forKey:@"Duration"];
                
                
                NSLog(@"timeStamp = %@",timeStamp);
                

                [datas addObject:dataDic];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([datas count]>10) {
                        [datas removeObjectAtIndex:0];
                    }
                        [self.tableView reloadData];

                });
            }

                break;
                
            default:
                break;
        }
    }
}

#pragma mark - writeData
-(void)writeWithCmdid:(Byte)cmdid dataString:(NSString *)dataString{
    
    [self.currPeripheral writeValue:[Pack packetWithCmdid:cmdid
                                              dataEnabled:YES
                                                     data:[self convertHexStrToData:dataString]]
                  forCharacteristic:self.sendCharacteristic
                               type:CBCharacteristicWriteWithResponse];
    
}

-(void)getData {
    
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    NSString *dataString = [NSString stringWithFormat:currentPage< 0x0f ? @"0%lx" :@"%lx",(long)currentPage];
    [self writeWithCmdid:CMDID_PAGE_RECORD dataString:dataString];
}

#pragma mark - privite
-(NSData *) convertHexStrToData:(NSString *)hexString {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hexString.length; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

//Byte数组转成int类型
-(int) lBytesToInt:(Byte[]) byte withLength:(int)length
{
    int height = 0;
    NSData * testData =[NSData dataWithBytes:byte length:length];
    for (int i = 0; i < [testData length]; i++)
    {
        if (byte[[testData length]-i] >= 0)
        {
            height = height + byte[[testData length]-i];
        } else
        {
            height = height + 256 + byte[[testData length]-i];
        }
        height = height * 256;
    }
    if (byte[0] >= 0)
    {
        height = height + byte[0];
    } else {
        height = height + 256 + byte[0];
    }
    return height;
}

//时间戳字符串转化为时间
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}
- (IBAction)nextPage:(id)sender {
    if (currentPage != numberOfPages -1)
    {
        self.rightButton.enabled = YES;
        currentPage = currentPage +1;
        if (currentPage == numberOfPages -1)
        {
            self.rightButton.enabled = NO;
        }
    }
    else{
        self.rightButton.enabled = NO;
    }
    
    if (currentPage !=0 )
    {
        self.leftButton.enabled = YES;
    }
    self.pageLabel.text = [NSString stringWithFormat:@"%ld / %ld",(long)currentPage + 1,(long)numberOfPages];
    [self performSelector:@selector(getData) withObject:nil afterDelay:0.1];
}

- (IBAction)previousPage:(id)sender {
    if (currentPage !=0 )
    {
        self.leftButton.enabled = YES;
        currentPage = currentPage -1;
        if (currentPage == 0)
        {
            self.leftButton.enabled = NO;
        }
    }else
    {
        self.leftButton.enabled = NO;
    }
    
    if (currentPage != numberOfPages -1)
    {
        self.rightButton.enabled = YES;
    }
    self.pageLabel.text = [NSString stringWithFormat:@"%ld / %ld",(long)currentPage + 1,(long)numberOfPages];
    [self performSelector:@selector(getData) withObject:nil afterDelay:0.1];
}
@end
