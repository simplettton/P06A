//
//  MQTTCommunicationViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/2/6.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MQTTCommunicationViewController.h"
#import "AAGlobalMacro.h"
NSString *const HOST = @"218.17.22.131";
NSString *const PORT = @"3080";
NSString *const MQTTUserName = @"admin";
NSString *const MQTTPassWord = @"password";


@interface MQTTCommunicationViewController ()

@property (strong, nonatomic) MQTTSessionManager *manager;
@property (strong, nonatomic) NSString *base;
@property (nonatomic,strong) NSString* isConnectedString;
@property (nonatomic,assign) BOOL isFirstReceivedMessage;

@property (weak, nonatomic) IBOutlet UIView *batteryView;
@property (weak, nonatomic) IBOutlet UILabel *currentPressureLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UIView *pressureView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;



@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureSetLabel;
@property (weak, nonatomic) IBOutlet UILabel *upTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *downTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


//model
@property (nonatomic,assign) BOOL isLocked;
@property (nonatomic,assign) NSInteger batteryLevel;
@property (nonatomic,assign) NSInteger treatMode;
@property (nonatomic,assign) NSInteger pressureSet;
@property (nonatomic,assign) NSInteger currentPressure;
@property (nonatomic,assign) NSInteger upTime;
@property (nonatomic,assign) NSInteger downTime;
@property (nonatomic,assign) NSInteger runningState;
@property (nonatomic,assign) NSInteger treatmentTime;
@property (nonatomic,assign) NSInteger alertIndex;

@property (nonatomic,strong)AAChartView *aaChartView;
@property (nonatomic,strong)NSMutableArray *array;
@end

@implementation MQTTCommunicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //订阅设备id
    self.base = @"P06A17A00001";
    
    [self initAll];
    [self connect];
    [self showChart];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMinimumSize:CGSizeMake(200, 100)];
    [SVProgressHUD setCornerRadius:5];
    [SVProgressHUD showWithStatus:@"Connecting"];
    [self performSelector:@selector(handleConnectTimeOut) withObject:nil afterDelay:5];
    
}

-(void)handleConnectTimeOut{
    if (![self.isConnectedString isEqualToString:@"YES"]) {
        [SVProgressHUD setMinimumSize:CGSizeZero];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
        [SVProgressHUD showInfoWithStatus:@"下位机无响应"];
    }
}

-(void)initAll{
    self.array = [[NSMutableArray alloc]initWithArray:@[@0,@0,@0,@0,@0,@0]];
    for (int i = 0; i<30; i++) {
        [self.array addObject:[NSNumber numberWithInteger:0]];
    }
    self.isConnectedString = [[NSString alloc]init];
    
    //电池初始状态
    for (int i = 1; i < 5; i++) {
        UIImageView *imageView = [self.batteryView viewWithTag:i];
        imageView.highlighted = YES;
    }
    //status
    self.statusButton.layer.cornerRadius = 15;
//    self.statusButton.layer.borderWidth = 2;
//    self.statusButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.pressureView.layer.cornerRadius = 15;
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.manager addObserver:self
                   forKeyPath:@"state"
                      options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                      context:nil];
    
//    [self.isConnectedString addObserver:self forKeyPath:@"isConnectedString" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.manager removeObserver:self forKeyPath:@"state" context:nil];
//    [self.isConnectedString removeObserver:self forKeyPath:@"isConnectedString" context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
//    if ([keyPath isEqualToString:@"isConnectedString"]) {
//        if ([self.isConnectedString isEqualToString:@"YES"]) {
//            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
//            [SVProgressHUD setMinimumSize:CGSizeZero];
//            [SVProgressHUD setCornerRadius:14];
//            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"设备连接成功"]];
//            [SVProgressHUD dismissWithDelay:0.9];
//
//        }
//    }
    switch (self.manager.state) {

        case MQTTSessionManagerStateClosed:
            NSLog(@"----------------------------------------closed");
            [SVProgressHUD showErrorWithStatus:@"断开连接"];
            break;
        case MQTTSessionManagerStateClosing:
            NSLog(@"----------------------------------------closing");
            break;
        case MQTTSessionManagerStateConnecting:
            NSLog(@"--------------------------------------connecting");
            break;
        case MQTTSessionManagerStateConnected:
            NSLog(@"-------------------------------------connected");
            
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
            [SVProgressHUD setMinimumSize:CGSizeZero];
            [SVProgressHUD setCornerRadius:14];
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"设备连接成功"]];
            [SVProgressHUD dismissWithDelay:0.9];
            
            //询问设备状态包
            [self sendDataWithCmdid:0x97 dataString:nil];
            
            break;
        case MQTTSessionManagerStateStarting:
            NSLog(@"------------------------------------startConnecting");
            break;
        case MQTTSessionManagerStateError:
            NSLog(@"--------------------------------------------error");
        default:
            break;
    }
}

#pragma mark - chart

-(void)showChart{
    CGFloat chartViewWidth  = kScreenW;
    CGFloat chartViewHeight = kScreenH - 250;
    self.aaChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 60, chartViewWidth, chartViewHeight)];
    ////设置图表视图的内容高度(默认 contentHeight 和 AAChartView 的高度相同)
    //self.aaChartView.contentHeight = self.view.frame.size.height-250;
    [self.view addSubview:self.aaChartView];
    
    AAChartModel *chartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeSpline)//设置图表的类型(这里以设置的为柱状图为例)
    .titleSet(@"实时治疗压力")//设置图表标题
    .yAxisTitleSet(@"-mmHg")//设置图表 y 轴的单位
    .xAxisVisibleSet(NO)
    .yAxisTickPositionsSet(@[
                             @(0),@(50),@(100),@(150),@(200),@(250)
                             ])
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"pressure")
                 .dataSet(self.array)
                 ]);
    
    /*图表视图对象调用图表模型对象,绘制最终图形*/
    [_aaChartView aa_drawChartWithChartModel:chartModel];
}
- (IBAction)test:(id)sender {

    [self.array addObject:[NSNumber numberWithInt:4]];
    NSArray *aaChartModelSeriesArray = @[@{@"name":@"pressure",
                                           @"type":@"line",
                                           @"data":self.array
                                           }];
    [_aaChartView aa_onlyRefreshTheChartDataWithChartModelSeries:aaChartModelSeriesArray];
}
-(void)refreshChart{
    
    if ([self.array count]>35) {
        [self.array removeObjectAtIndex:0];
    }

    NSArray *aaChartModelSeriesArray = @[@{@"name":@"pressure",
                                           @"type":@"line",
                                           @"data":self.array
                                           }];
    [_aaChartView aa_onlyRefreshTheChartDataWithChartModelSeries:aaChartModelSeriesArray];
}

#pragma mark - connectMQTT

-(void)connect {
    
    if (!self.manager) {
        self.manager = [[MQTTSessionManager alloc] init];
        self.manager.delegate = self;
        //订阅主题
        self.manager.subscriptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:MQTTQosLevelExactlyOnce]
                                                                 forKey:[NSString stringWithFormat:@"%@1", self.base]];
        //连接服务器
        [self.manager connectTo:@"218.17.22.131"
                           port:3080
                            tls:false
                      keepalive:60
                          clean:true
                           auth:true
                           user:@"admin"
                           pass:@"password"
                           will:nil
                      willTopic:nil
                        willMsg:nil
                        willQos:MQTTQosLevelExactlyOnce
                 willRetainFlag:false
                   withClientId:nil
                 securityPolicy:nil
                   certificates:nil
                  protocolLevel:MQTTProtocolVersion31
                 connectHandler:^(NSError *error) {
                     
                 }];
        
    }else{
        [self.manager connectToLast:^(NSError *error) {
            NSLog(@"connectToLast error:%@",error);
        }];
    }

}

#pragma mark - sendData

-(void)sendDataWithCmdid:(NSInteger)cmdid dataString:(NSString *)dataString {
    
    [self.manager sendData:[Pack packetWithCmdid:cmdid
                                     dataEnabled:YES
                                            data:[self convertHexStrToData:dataString]]
                     topic:self.base
                       qos:MQTTQosLevelExactlyOnce
                    retain:FALSE];
}

#pragma mark - receiveData

- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    NSLog(@"--------------------------");
    
    //收到消息代表连接成功
    self.isConnectedString = @"YES";
    
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
//    [SVProgressHUD setMinimumSize:CGSizeZero];
//    [SVProgressHUD setCornerRadius:14];
//    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"设备连接成功"]];
//    [SVProgressHUD dismissWithDelay:0.9];
    
    
    NSData *completeData = [Unpack unpackData:data];
    if (completeData) {
        Byte *dataByte = (Byte *)[completeData bytes];
        Byte cmdid = dataByte[0];
        switch (cmdid) {
            //设备状态包
            case 0x90:
                self.runningState = dataByte[3];
                
                self.pressureSet = dataByte[4];
                
                self.treatMode = dataByte[5];

                self.upTime = dataByte [6];
                
                self.downTime = dataByte[7];
                
                self.isLocked = dataByte[9];
                
                Byte batteryLevel = dataByte[8];
                if (batteryLevel == 0x06) {
                    self.batteryLevel = batteryLevel;
                }else{
                    self.batteryLevel = 16 - (16>>batteryLevel);
                }
                
                break;
            
            //实时治疗信息包
            case 0x91:
                self.currentPressure = dataByte[3];
                NSLog(@"currentpress = %ld",(long)self.currentPressure);
                
                //图标数据添加 刷新图表
                [self.array addObject:[NSNumber numberWithUnsignedInteger:self.currentPressure]];
                [self refreshChart];
                
                Byte timeBytes [] = {dataByte[4],dataByte[5],dataByte[6],dataByte[7]};
                self.treatmentTime = [self lBytesToInt:timeBytes withLength:4];
                NSLog(@"self.treatmentTime = %ld",self.treatmentTime);
                break;
            
            //警告信息返回包
            case 0x95:
            {
                NSString *alertMessege = [[NSString alloc]init];
                Byte alertIndex = dataByte[3];
                
                switch (alertIndex) {
                    case 0x00:  alertMessege = @"设备废液瓶满";  break;
                    case 0x01:  alertMessege = @"设备压力过高";  break;
                    case 0x02:  alertMessege = @"设备压力过低";  break;
                    case 0x03:  alertMessege = @"设备使用到期";  break;
                    case 0x04:  alertMessege = @"设备电量异常";  break;
                    default:
                        break;
                }
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD showErrorWithStatus:alertMessege];
            }
                break;
                
            
            default:
                break;
        }
        [self updateUI];
    }
}

-(void)updateUI {
    
    //设备状态
    NSString *statusString;
    switch (self.runningState) {
        case 0x00:
            statusString = [NSString stringWithFormat:@"空闲"];
            self.currentPressure = 0;
            self.treatmentTime = 0;
//            self.currentPressureLabel.text = [NSString stringWithFormat:@"当前治疗压力:0mmHg"];
//            self.timeLabel.text = @"00:00";
            break;
        case 0X01:
            statusString = [NSString stringWithFormat:@"治疗中"];
            break;
        case 0x02:
            statusString = [NSString stringWithFormat:@"暂停"];
        default:
            break;
    }
    self.statusLabel.text = [NSString stringWithFormat:@"设备状态:%@",statusString];
    
    //治疗模式
    
    switch (self.treatMode) {
        case 0:
            
            self.modeLabel.text = @"持续吸引模式";
            self.upTimeLabel.text = @"";
            self.downTimeLabel.text = @"";
            
            break;
        case 1:
            
            self.modeLabel.text = @"间歇吸引模式";
            self.upTimeLabel.text = [NSString stringWithFormat:@"工作时间:%ldmin",self.upTime];
            self.downTimeLabel.text = [NSString stringWithFormat:@"休息时间:%ldmin",self.downTime];
            
            break;
        case 2:
            
            self.modeLabel.text = @"动态吸引模式";
            self.upTimeLabel.text = [NSString stringWithFormat:@"上升时间:%ldmin",self.upTime];
            self.downTimeLabel.text = [NSString stringWithFormat:@"下降时间:%ldmin",self.downTime];
            break;
        default:
            break;
    }
    
    //电池
    
    switch (self.batteryLevel) {
        case 0x06:
        {
            for (int i = 1; i < 5; i++) {
                UIImageView *imageView = [self.batteryView viewWithTag:i];
                imageView.highlighted = NO;
            }
            UIImageView *chargeImageView = [self.batteryView viewWithTag:self.batteryLevel];
            chargeImageView.highlighted = YES;
        }
            break;
        default:
        {
            char temp = 0x01;
            char lastTempt = 0x00;
            
            UIImageView *chargeImageView = [self.batteryView viewWithTag:0x06];
            chargeImageView.highlighted = NO;
            //判断低4位某一位是否为1(从1开始)
            for (int i = 1; i < 5; i++) {
                
                lastTempt = self.batteryLevel >> (i-1);
                if (lastTempt & temp) {
                    UIImageView *imageView = [self.batteryView viewWithTag:i];
                    imageView.highlighted = YES;
                }else {
                    UIImageView *imageView = [self.batteryView viewWithTag:i];
                    imageView.highlighted = NO;
                }
            }
        }
            break;
    }
    
    
    //压力设置
    self.pressureSetLabel.text = [NSString stringWithFormat:@"压力设置:-%ldmmHg",(long)self.pressureSet];
    
    //实时压力值
    NSString *displayFormat = self.currentPressure == 0 ? @"当前治疗压力:%ldmmHg" :@"当前治疗压力:-%ldmmHg";
    self.currentPressureLabel.text = [NSString stringWithFormat:displayFormat,self.currentPressure];
    
    //治疗经过时间
    NSInteger hour = self.treatmentTime / 3600;
    NSInteger min = (self.treatmentTime / 60)%60;
    NSInteger second = self.treatmentTime % 60;
    
    //治疗时间为两位数
    NSString *hourString = [NSString stringWithFormat:hour>9?@"%ld":@"0%ld",(long)hour];
    NSString *minString = [NSString stringWithFormat:min>9?@"%ld":@"0%ld",(long)min];
//    NSString *secondString = [NSString stringWithFormat:second>9?@"%ld":@"0%ld",(long)second];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@",hourString,minString];
    

}

#pragma mark - privateMethod
//大端
-(NSData *) convertHexStrToData:(NSString *)hexString {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hexString.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

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
@end
