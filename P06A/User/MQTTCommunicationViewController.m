//
//  MQTTCommunicationViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/2/6.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MQTTCommunicationViewController.h"
#import "AAGlobalMacro.h"
#import "AlertView.h"
NSString *const HOST = @"218.17.22.130";
NSString *const PORT = @"21613";
NSString *const MQTTUserName = @"admin";
NSString *const MQTTPassWord = @"password";


@interface MQTTCommunicationViewController ()

//MQTT

@property (strong, nonatomic) MQTTSessionManager *manager;
@property (strong, nonatomic) NSMutableDictionary *subscriptions;
@property (strong, nonatomic) NSString *sendTopic;
//定时询问实时信息
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic,strong) NSString* isConnectedString;
@property (nonatomic,assign) BOOL isFirstReceivedMessage;

//12s刷新图表的timer
@property (strong, nonatomic) NSTimer *refreshTimer;

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
@property (nonatomic,assign) NSInteger workTime;
@property (nonatomic,assign) NSInteger restTime;

@property (nonatomic,assign) NSInteger runningState;
@property (nonatomic,assign) NSInteger treatmentTime;
@property (nonatomic,assign) NSInteger alertIndex;

@property (nonatomic,strong)AAChartView *aaChartView;
@property (nonatomic,strong)NSMutableArray
*array;
@end

@implementation MQTTCommunicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //发布数据主题
    NSString *cpuid = [UserDefault objectForKey:@"Cpuid"];
    self.sendTopic = [NSString stringWithFormat:@"P06A/todev/%@",cpuid];
    
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
        [SVProgressHUD showInfoWithStatus:BEGetStringWithKeyFromTable(@"设备无响应", @"P06A")];
    }
}

-(void)initAll{
    self.array = [[NSMutableArray alloc]initWithArray:@[@0,@0,@0,@0,@0,@0]];
    for (int i = 0; i<30; i++) {
        [self.array addObject:[NSNumber numberWithInteger:0]];
    }
    self.isConnectedString = [[NSString alloc]init];
    self.subscriptions = [[NSMutableDictionary alloc]init];
    
    //电池初始状态
    for (int i = 1; i < 5; i++) {
        UIImageView *imageView = [self.batteryView viewWithTag:i];
        imageView.highlighted = YES;
    }
    //status
    self.statusButton.layer.cornerRadius = 15;
    self.pressureView.layer.cornerRadius = 15;
    
    self.currentPressureLabel.text = [NSString stringWithFormat:@"%@: 0mmHg",BEGetStringWithKeyFromTable(@"当前治疗压力", @"P06A")];
    self.statusLabel.text = [NSString stringWithFormat:@"%@: %@",BEGetStringWithKeyFromTable(@"设备状态",@"P06A"),BEGetStringWithKeyFromTable(@"未连接", @"P06A")];
    self.modeLabel.text = BEGetStringWithKeyFromTable(@"治疗模式", @"P06A");
    self.pressureSetLabel.text = [NSString stringWithFormat:@"%@: 0mmhg",BEGetStringWithKeyFromTable(@"压力设置", @"P06A")];
    self.upTimeLabel.text = [NSString stringWithFormat:@"%@: 0min",BEGetStringWithKeyFromTable(@"上升时间", @"P06A")];
    self.downTimeLabel.text = [NSString stringWithFormat:@"%@: 0min",BEGetStringWithKeyFromTable(@"下降时间", @"P06A")];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.manager addObserver:self
                   forKeyPath:@"state"
                      options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                      context:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [self closeTimer];
    [self closeRealTime];
    
    [self.manager removeObserver:self forKeyPath:@"state" context:nil];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{

    switch (self.manager.state) {

        case MQTTSessionManagerStateClosed:
            NSLog(@"----------------------------------------closed");
            [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"断开连接", @"P06A")];
            [self closeRealTime];
            [self closeTimer];
            
            break;
        case MQTTSessionManagerStateClosing:
            NSLog(@"----------------------------------------closing");
            break;
        case MQTTSessionManagerStateConnecting:
            NSLog(@"--------------------------------------connecting");
            break;
        case MQTTSessionManagerStateConnected:
            NSLog(@"-------------------------------------connected");
            
            [SVProgressHUD setMinimumSize:CGSizeMake(100, 40)];
            [SVProgressHUD showSuccessWithStatus:BEGetStringWithKeyFromTable(@"已成功连接服务器", @"P06A")];
            
            //询问设备状态包
            [self sendDataWithCmdid:0x90 dataString:nil];

            [self startRealTime];
            //询问多一次实时信息
            [self performSelector:@selector(startRealTime) withObject:nil afterDelay:1];
            
            [self startTimer];
            
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
    .titleSet(BEGetStringWithKeyFromTable(@"实时治疗压力", @"P06A"))//设置图表标题
    .yAxisTitleSet(@"-mmHg")//设置图表 y 轴的单位
    .xAxisVisibleSet(NO)
    .yAxisTickPositionsSet(@[
                             @(0),@(50),@(100),@(150),@(200),@(250)
                             ])
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(BEGetStringWithKeyFromTable(@"压力", @"P06A"))
                 .dataSet(self.array)
                 ]);
    
    /*图表视图对象调用图表模型对象,绘制最终图形*/
    [_aaChartView aa_drawChartWithChartModel:chartModel];
}
- (IBAction)test:(id)sender {

    [self.array addObject:[NSNumber numberWithInt:106]];
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
//        self.manager.subscriptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:MQTTQosLevelExactlyOnce]
//                                                                 forKey:[NSString stringWithFormat:@"%@", self.base]];
        
//        [self subcribe:@"1b00080002434d5632303320e906f405"];
//        [self subcribe:@"toapp/1b00080002434d5632303320e906f405"];
//        [self subcribe:@"phone/1b00080002434d5632303320e906f405"];
        NSString *cpuid = [UserDefault objectForKey:@"Cpuid"];
        [self subcribe:cpuid];
        [self subcribe:[NSString stringWithFormat:@"toapp/%@",cpuid]];
        [self subcribe:[NSString stringWithFormat:@"phone/%@",cpuid]];
        
        //连接服务器
        [self.manager connectTo:@"218.17.22.130"
                           port:21613
                            tls:false
                      keepalive:60
                          clean:true
                           auth:true
                           user:@"admin"
                           pass:@"pwd321"
                           will:nil
                      willTopic:nil
                        willMsg:nil
                        willQos:MQTTQosLevelExactlyOnce
                 willRetainFlag:false
                   withClientId:nil
                 securityPolicy:nil
                   certificates:nil
                  protocolLevel:MQTTProtocolVersion31
                 connectHandler:nil];
        
    }else{
        [self.manager connectToLast:^(NSError *error) {
            NSLog(@"connectToLast error:%@",error);
        }];
    }

}
#pragma mark - subcription
-(void)subcribe:(NSString *)topic{
    NSString *newTopic = [NSString stringWithFormat:@"P06A/%@",topic];
    if (![self.manager.subscriptions.allKeys containsObject:newTopic]){
        [self.subscriptions setObject:[NSNumber numberWithInt:MQTTQosLevelExactlyOnce] forKey:newTopic];
        self.manager.subscriptions = [self.subscriptions copy];
    }
}

#pragma mark - sendData

-(void)sendDataWithCmdid:(NSInteger)cmdid dataString:(NSString *)dataString {
    
    [self.manager sendData:[Pack packetWithCmdid:cmdid
                                     dataEnabled:YES
                                            data:[self convertHexStrToData:dataString]]
                     topic:self.sendTopic
                       qos:MQTTQosLevelExactlyOnce
                    retain:FALSE];
}
-(void)startRefreshChartTimer{
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addPointTochart) userInfo:nil repeats:YES];
}

//定时获取实时信息timer
-(void)startTimer{
    //5min发送一次请求实时信息
    self.timer = [NSTimer scheduledTimerWithTimeInterval:300
                                                  target:self
                                                selector:@selector(startRealTime)
                                                userInfo:nil
                                                 repeats:YES];
}

-(void)closeTimer{
    [self.timer invalidate];
    self.timer = nil;

    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

-(void)startRealTime{
    [self sendDataWithCmdid:0x91 dataString:@"0100"];
}
-(void)closeRealTime{
    [self sendDataWithCmdid:0x91 dataString:@"0000"];
}

#pragma mark - receiveData

- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
//    NSLog(@"----------------------topic:%@--------------------------",topic);
    
    //收到消息代表连接成功
    self.isConnectedString = @"YES";

 
    NSData *completeData = [Unpack unpackMqttData:data];
    if (completeData) {
        Byte *dataByte = (Byte *)[completeData bytes];
        Byte cmdid = dataByte[0];
        switch (cmdid) {
            //设备状态包
            case 0x90:
                self.runningState = dataByte[1];
                
                self.pressureSet = dataByte[2];
                
                self.treatMode = dataByte[3];

                self.upTime = dataByte [4];
                
                self.downTime = dataByte[5];
                
                self.workTime = dataByte[6];
                
                self.restTime = dataByte[7];

                Byte batteryLevel = dataByte[8];
                if (batteryLevel == 0x06) {
                    self.batteryLevel = batteryLevel;
                }else{
                    self.batteryLevel = 16 - (16>>batteryLevel);
                }
                self.isLocked = dataByte[9];
                
                break;
            
            //实时治疗信息包
            case 0x91:
                self.currentPressure = dataByte[1];

//                [self startRefreshChartTimer];
                [self addPointTochart];

                Byte timeBytes [] = {dataByte[2],dataByte[3],dataByte[4],dataByte[5]};
                self.treatmentTime = [self lBytesToInt:timeBytes withLength:4];
//                NSLog(@"self.treatmentTime = %ld",self.treatmentTime);
                break;
            
            //警告信息返回包
            case 0x95:
            {
                NSString *alertMessege = [[NSString alloc]init];
                Byte alertIndex = dataByte[1];
                
                switch (alertIndex) {
                    case 0x00:  alertMessege = BEGetStringWithKeyFromTable(@"无异常报警",@"P06A");    break;
                    case 0x01:  alertMessege = BEGetStringWithKeyFromTable(@"设备废液瓶满",@"P06A");  break;
                    case 0x02:  alertMessege = BEGetStringWithKeyFromTable(@"设备压力过低",@"P06A");  break;
                    case 0x03:  alertMessege = BEGetStringWithKeyFromTable(@"设备压力过高",@"P06A");  break;
                    case 0x04:  alertMessege = BEGetStringWithKeyFromTable(@"设备电量异常",@"P06A");  break;
                    case 0x05:  alertMessege = BEGetStringWithKeyFromTable(@"设备使用到期",@"P06A");  break;
                    default:
                        break;
                }
                [AlertView showAboveIn:self withData:alertMessege];
            }
                break;
                
            
            default:
                break;
        }
        [self updateUI];
    }
}
-(void)addPointTochart{
    //图标数据添加 刷新图表
    [self.array addObject:[NSNumber numberWithUnsignedInteger:self.currentPressure]];
    [self refreshChart];
}

-(void)updateUI {
    
    //设备状态
    NSString *statusString;
    switch (self.runningState) {
        case 0x00:
            statusString = BEGetStringWithKeyFromTable(@"空闲", @"P06A");
            self.currentPressure = 0;
            self.treatmentTime = 0;
//            self.currentPressureLabel.text = [NSString stringWithFormat:@"当前治疗压力:0mmHg"];
//            self.timeLabel.text = @"00:00";
            break;
        case 0X01:
            statusString = BEGetStringWithKeyFromTable(@"治疗中", @"P06A");
            break;
        case 0x02:
            statusString = BEGetStringWithKeyFromTable(@"暂停", @"P06A");
        default:
            break;
    }
    self.statusLabel.text = [NSString stringWithFormat:@"%@: %@",BEGetStringWithKeyFromTable(@"设备状态", @"P06A"),statusString];
    
    //治疗模式
    
    switch (self.treatMode) {
        case 0:
            
            self.modeLabel.text = BEGetStringWithKeyFromTable(@"MQTT连续模式", @"P06A");
            self.upTimeLabel.text = @"";
            self.downTimeLabel.text = @"";
            
            break;
        case 1:
            
            self.modeLabel.text = BEGetStringWithKeyFromTable(@"MQTT间隔模式", @"P06A");
            self.upTimeLabel.text = [NSString stringWithFormat:@"%@: %ldmin",BEGetStringWithKeyFromTable(@"工作时间", @"P06A"),self.workTime];
            self.downTimeLabel.text = [NSString stringWithFormat:@"%@: %ldmin",BEGetStringWithKeyFromTable(@"间歇时间", @"P06A"),self.restTime];
            
            break;
        case 2:
            
            self.modeLabel.text = BEGetStringWithKeyFromTable(@"MQTT动态模式", @"P06A");
            self.upTimeLabel.text = [NSString stringWithFormat:@"%@: %ldmin",BEGetStringWithKeyFromTable(@"上升时间", @"P06A"),self.upTime];
            self.downTimeLabel.text = [NSString stringWithFormat:@"%@: %ldmin",BEGetStringWithKeyFromTable(@"下降时间", @"P06A"),self.downTime];
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
    self.pressureSetLabel.text = [NSString stringWithFormat:@"%@: -%ldmmHg",BEGetStringWithKeyFromTable(@"压力设置", @"P06A"),(long)self.pressureSet];
    
    //实时压力值
    NSString *currentPressureString = BEGetStringWithKeyFromTable(@"当前治疗压力", @"P06A");
    NSString *displayFormat = self.currentPressure == 0 ? @"%@: %ldmmHg" :@"%@: -%ldmmHg";
    self.currentPressureLabel.text = [NSString stringWithFormat:displayFormat,currentPressureString,self.currentPressure];
    
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
