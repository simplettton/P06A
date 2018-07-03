//
//  SetTreatmentParameterController.m
//  P06A
//
//  Created by Binger Zeng on 2018/2/2.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "SetTreatmentParameterController.h"
#import <SVProgressHUD.h>
#import "TimeSetCell.h"
#import "Unpack.h"
#import "Pack.h"

#define CELL_KEY_TAG 11
#define CELL_VALUE_TAG 22
typedef NS_ENUM(NSInteger,KCmdids)
{

    CMDID_WORK_TIME             = 0X07,
    CMDID_INTERVAL_TIME         = 0X08,
    CMDID_UP_TIME               = 0X09,
    CMDID_DOWN_TIME             = 0X0A,
};
@interface SetTreatmentParameterController ()
@property (nonatomic,strong)NSArray *dataKeys;
@property (nonatomic,strong)NSMutableDictionary *dataDic;
@property (strong ,nonatomic)NSMutableData *readBuf;

@end

@implementation SetTreatmentParameterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"治疗参数";
    [self initAll];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    if(self.receiveCharacteristic!=nil) {
        
        //通知方式监听一个characteristic的值
        [baby notify:self.currPeripheral
      characteristic:self.receiveCharacteristic
               block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                   NSLog(@"setTreatmentController----------------------------------------------");

                   NSData *data = self.receiveCharacteristic.value;
                   if (data) {
                       [self.readBuf appendData:data];
                       [self analyzeReceivedData];
                   }
               }];
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    if (self.currPeripheral) {
        [baby cancelNotify:self.currPeripheral characteristic:self.receiveCharacteristic];
    }

}

-(void)initAll {
    self.dataKeys = @[@"工作时间",@"间歇时间",@"上升时间",@"下降时间"];
    self.dataDic = [[NSMutableDictionary alloc]init];
    self.readBuf = [[NSMutableData alloc]init];
    
    NSArray *keys = @[@"WorkTime",@"IntervalTime",@"UpTime",@"DownTime"];
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    
    for (int i= 0; i<4; i++) {
        if ([userDefaultes objectForKey:keys[i]]) {
            [self.dataDic setObject: [userDefaultes objectForKey:keys[i]] forKey:self.dataKeys[i]];
        }
    }
    
    
    
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.sectionHeaderHeight  = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.contentInset = UIEdgeInsetsMake(20 - 35, 0, 0, 0);
    
    [self babyDelegate];
    
}
#pragma mark - babyDelegate

-(void)babyDelegate {
    
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@ 已断开连接",peripheral.name);
        
//        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@ 已断开连接",peripheral.name]];
        
    }];
    
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        
    }];
    
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        
    }];
    
    [baby setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBCharacteristic *characteristic, NSError *error)
     {
         NSLog(@"didUpdata");
         
     }];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 2) {
//        return 3;
//    }else{
        return 2;
//    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerTitle;
    if (section == 0) {
        headerTitle = [NSString stringWithFormat:@"间歇模式时间参数(min)"];
    }else if(section == 1){
        headerTitle = [NSString stringWithFormat:@"动态模式时间参数(min)"];
    }
    return headerTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    TimeSetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TimeSetCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"TimeSetCell" owner:self options:nil];
        cell = (TimeSetCell *)array.firstObject;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    NSString *dataKey = self.dataKeys[indexPath.section *2 + indexPath.row];
    cell.keyLabel.text = dataKey;
    NSString *dataValue = self.dataDic[dataKey];
    cell.valueLabel.text = dataValue != nil? dataValue:@"no data";
    
    
    if (indexPath.section == 0) {
        cell.treatmentMaxTime = 30;
    }else {
        cell.treatmentMaxTime = 10;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


#pragma mark - writeData
//发送设置时间参数的指令

- (IBAction)save:(id)sender {
    NSArray * cells = self.tableView.visibleCells;
    for (TimeSetCell *cell in cells) {
        NSString * dataString = cell.valueLabel.text;
        dataString = [self byteStringToHex:dataString];
        dataString = [NSString stringWithFormat:@"%@00",dataString];
        NSLog(@"dataString = %@",dataString);
        NSUInteger index = [cells indexOfObject:cell];
        [self writeWithCmdid:index + 7 dataString:dataString];
    }
}

-(void)writeWithCmdid:(Byte)cmdid dataString:(NSString *)dataString{
    
    [self.currPeripheral writeValue:[Pack packetWithCmdid:cmdid
                                          dataEnabled:YES
                                                 data:[self convertHexStrToData:dataString]]
              forCharacteristic:self.sendCharacteristic
                           type:CBCharacteristicWriteWithResponse];
}

#pragma mark - receiveData
//处理数据粘包问题
-(void)analyzeReceivedData{
    while (self.readBuf.length >= 2) {
        
        NSData *head = [_readBuf subdataWithRange:NSMakeRange(0, 2)];//取得头部数据
        
        NSData *lengthData = [head subdataWithRange:NSMakeRange(1, 1)];//取得长度数据
        
        NSInteger length;
        
        length = *((Byte *)([lengthData bytes]));
        
        //        [lengthData getBytes: &length length: sizeof(lengthData)];
        
        NSInteger complateDataLength = length + 4;
        
        if (_readBuf.length >= complateDataLength)//如果缓存中数据够一个整包的长度
        {
            NSData *data = [_readBuf subdataWithRange:NSMakeRange(0, complateDataLength)];//截取一个包的长度(处理粘包)
            [self handleCompleteData:data];//处理包数据
            //从缓存中截掉处理完的数据,继续循环
            _readBuf = [NSMutableData dataWithData:[_readBuf subdataWithRange:NSMakeRange(complateDataLength, _readBuf.length - complateDataLength)]];
        }
        else//如果缓存中的数据长度不够一个包的长度，则包不完整(处理半包，继续读取)
        {
            //            [_socket readDataWithTimeout:-1 buffer:_readBuf bufferOffset:_readBuf.length tag:0];//继续读取数据
            return;
        }
    }
}

-(void)handleCompleteData :(NSData *)receivedData {
    NSData *data = [Unpack unpackData:receivedData];
    if (data) {
        Byte* bytes = (Byte *)[data bytes];
        Byte cmdid = bytes[0];
        Byte dataByte = bytes[1];
        
//        NSString *dataString = [NSString stringWithFormat:@"%d",dataByte];
        
        //命令数值对应keys中索引是-7的关系
        switch (cmdid) {
//            case CMDID_WORK_TIME:
//                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
//                [SVProgressHUD setMinimumSize:CGSizeZero];
//                [SVProgressHUD setCornerRadius:14];
//                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"保存成功"]];
//                [SVProgressHUD dismissWithDelay:0.9];
//                break;
            case CMDID_WORK_TIME:
            case CMDID_INTERVAL_TIME:
            case CMDID_UP_TIME:
            case CMDID_DOWN_TIME:
            {
                //存到本地
                NSArray *keys = @[@"WorkTime",@"IntervalTime",@"UpTime",@"DownTime"];
                NSString *dataString = [NSString stringWithFormat:@"%d",dataByte];
                
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                [userDefaultes setObject:dataString forKey:keys[cmdid - CMDID_WORK_TIME]];
                [userDefaultes synchronize];
                
                //提示成功
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
                [SVProgressHUD setMinimumSize:CGSizeZero];
                [SVProgressHUD setCornerRadius:14];
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"保存成功"]];
                [SVProgressHUD dismissWithDelay:0.9];
                
                [self performSelector:@selector(back) withObject:nil afterDelay:0.5];
                
            }
                break;
                
            default:
                break;
        }
//        if (cmdid>=CMDID_WORK_TIME && cmdid <= CMDID_DOWN_TIME) {
//            [self.dataDic setObject:dataString forKey:(NSString *)self.dataKeys[cmdid - 7]];
//        }
    }
//    [self.tableView reloadData];
    
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
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

-(NSString *)byteStringToHex:(NSString *)byteString{
    NSString *hexStr = @"";
    Byte value = [byteString integerValue];
    NSString *newHexStr = [NSString stringWithFormat:@"%x",value&0xFF];
    if([newHexStr length]==1)
        hexStr = [NSString stringWithFormat:@"0%@",newHexStr];
    else
        hexStr = newHexStr;
    return hexStr;
}

@end
