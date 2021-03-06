//
//  BluetoothCommuticationViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/10.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

/* "CODE IS FAR AWAY FROM BUG WITH THE ANIMAL PROTECTING"
 *          %%       %%
 *         ##       ##
 *       ┏-##┓　  ┏-##┓
 *    ┏_┛ ┻---━┛_┻━━┓
 *    ┃　　　        ┃
 *    ┃　　 ━　      ┃
 *    ┃ @^　  @^    ┃
 *    ┃　　　　　　  ┃
 *    ┃　　 ┻　　　 ┃
 *    ┃_　　　　　 _┃
 *     ┗━┓　　　┏━┛
 *    　　┃　　　┃神兽保佑
 *    　　┃　　　┃永无BUG！
 *    　　┃　　　┗━━━┓----|
 *    　　┃　　　　　　　  ┣┓}}}
 *    　　┃　　　　　　　  ┏┛
 *    　　┗┓&&&┓-┏&&&┓┏┛-|
 *    　　　┃┫┫　 ┃┫┫
 *    　　　┗┻┛　 ┗┻┛
 *
 *
 *"CODE IS FAR AWAY FROM BUG WITH THE ANIMAL PROTECTING"
 */
#import "BLECommunicationViewController.h"
#import "AlertView.h"
#import "AppDelegate.h"
#import "ProgressChart.h"


@interface BLECommunicationViewController ()<CALayerDelegate>{
    BabyBluetooth *baby;
    dispatch_source_t _timer;
    
    NSInteger startTime;
    NSInteger timeLine;
    NSInteger runTime;
    NSInteger duration;
}
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UIButton *modeButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *pressureButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
/**
 * 两个控制buttonView
 */
@property (weak, nonatomic) IBOutlet UIStackView *controllButtonView;


@property (weak, nonatomic) IBOutlet UILabel *timeDisplay;
@property (weak, nonatomic) IBOutlet UILabel *pressureDisplay;
@property (weak, nonatomic) IBOutlet UIView *batteryView;


@property (assign,nonatomic) BOOL lockSelected;
@property (nonatomic,strong) MBProgressHUD *HUD;

- (IBAction)lock:(id)sender;
- (IBAction)start:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)tapModeButton:(id)sender;

@property (strong,nonatomic) CALayer *maskLayer;

@property (nonatomic,strong) CBPeripheral *peripheral;
@property (nonatomic,strong) CBCharacteristic *sendCharacteristic;
@property (nonatomic,strong) CBCharacteristic *receiveCharacteristic;

@property (nonatomic,assign) BOOL isConnected;
@property (nonatomic,assign) BOOL blueToothPowerOn;

@property (nonatomic,strong)NSMutableData *readBuf;

//model
@property (nonatomic,assign) BOOL isLocked;
@property (nonatomic,assign) NSInteger batteryLevel;
@property (nonatomic,assign) NSInteger treatMode;
@property (nonatomic,strong) NSString *pressure;
@property (nonatomic,assign) NSInteger runningState;

@property (nonatomic,assign) NSInteger keepPressure;
@property (nonatomic,assign) NSInteger intervalPressure;
@property (nonatomic,assign) NSInteger dynamicPressure;

//压力圈
@property (nonatomic,strong)ProgressData *progress;
@property (nonatomic,strong)ProgressChart * chart;

@end

@implementation BLECommunicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = BEGetStringWithKeyFromTable(@"便携负压", @"P06A");

    
    //检测有没有绑定蓝牙设备
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"MacString"]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:BEGetStringWithKeyFromTable(@"当前没有配对设备，请前往设置", @"P06A")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"取消", @"P06A") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"确认", @"P06A") style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  
                                                                  [self.navigationController popToRootViewControllerAnimated:YES];
                                                              }];
        [alert addAction:cancelAction];
        [alert addAction:defaultAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    }else{
        //配置svprogressHUD
        [SVProgressHUD showWithStatus:BEGetStringWithKeyFromTable(@"正在连接设备...", @"P06A")];
        [self performSelector:@selector(handleConnectTimeOut) withObject:nil afterDelay:5];
    }
    
    [self configureButtonUI];
    
    
    baby = [BabyBluetooth shareBabyBluetooth];
    [self babyDelegate];
    baby.scanForPeripherals().begin();
    
    //电池初始状态
    for (int i = 1; i < 5; i++) {
        UIImageView *imageView = [self.batteryView viewWithTag:i];
        imageView.highlighted = YES;
    }
    //创建数据缓存区
    self.readBuf = [[NSMutableData alloc] init];
    [self initPressureProgress];
  
}
-(void)initPressureProgress{
    if (self.chart == nil) {
        ProgressData * progress = [[ProgressData alloc] init];
        progress.maxValue = 200;
        progress.value = 0;
        progress.progressRadius = 110;
        progress.centerLable.stringFormat = @"%d";
        progress.centerLable.stringOffSet = CGSizeMake(0, -20);
        progress.centerLable.lableFont = [UIFont systemFontOfSize:40 weight:UIFontWeightSemibold];
        progress.centerLable.lableColor =UIColorFromHex(0x6CD56B);
        progress.progressBackColor = UIColorFromHex(0xd6d6d6);
        progress.progressGradientColor = @[UIColorFromHex(0x65B8F3),UIColorFromHex(0xBCCCF9),UIColorFromHex(0xA9D8F9)];
        //    UIColorFromHex(0x65D1F3),
        self.progress = progress;
        
        
        ProgressChart * chart = [[ProgressChart alloc] initWithFrame:CGRectZero];
        chart.gg_top = 130;
        chart.gg_size = CGSizeMake(238, 238);
        chart.gg_centerX = kScreenW / 2;
        chart.progressData = self.progress;
        self.chart = chart;
        [self.chart drawProgressChart];
        [self.view addSubview:self.chart];
    }
}
-(void)updatePressProgress{
    [self.chart drawProgressChart];
}
-(void)handleConnectTimeOut{
    if (!self.isConnected) {
//        [SVProgressHUD setMinimumSize:CGSizeZero];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
        [SVProgressHUD showInfoWithStatus:BEGetStringWithKeyFromTable(@"设备无响应", @"P06A")];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self addObserver:self
           forKeyPath:@"peripheral"
              options:NSKeyValueObservingOptionNew
              context:nil];
    [self addObserver:self
           forKeyPath:@"sendCharacteristic"
              options:NSKeyValueObservingOptionNew
              context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleBLEPowerOff) name:@"BLEPoweredOffNotification" object:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.isBLEPoweredOff) {
        [self handleBLEPowerOff];
    }else{
        if (self.sendCharacteristic) {
            [self askForDeviceState];
        }
        if (self.receiveCharacteristic) {
            [self setNotify:self.receiveCharacteristic];
        }
    }
}
-(void)handleBLEPowerOff{
    [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"未打开蓝牙无法连接设备", @"P06A")];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self removeObserver:self forKeyPath:@"peripheral" context:nil];
    [self removeObserver:self forKeyPath:@"sendCharacteristic" context:nil];
    [self stopTimer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"BLEPoweredOffNotification" object:nil];
    
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"peripheral"]) {
        [self connectPeripheral];
        [self.HUD hideAnimated:YES];
    }
    
    if ([keyPath isEqualToString:@"sendCharacteristic"]) {
        [self askForDuration];
        [self performSelector:@selector(askForDeviceState) withObject:nil afterDelay:0.10];
    }
}


#pragma mark - configureUI
-(void)configureButtonUI{
    
    [self.startButton setTitle:BEGetStringWithKeyFromTable(@"开始", @"P06A") forState:UIControlStateNormal];
    [self.pauseButton setTitle:BEGetStringWithKeyFromTable(@"暂停", @"P06A") forState:UIControlStateNormal];
    [self.stopButton setTitle:BEGetStringWithKeyFromTable(@"结束", @"P06A") forState:UIControlStateNormal];
    
    [self.lockButton setTitle:BEGetStringWithKeyFromTable(@"锁屏", @"P06A") forState:UIControlStateNormal];
    
    [self configureButton:self.modeButton WithTitle:BEGetStringWithKeyFromTable(@"连续模式", @"P06A") imageName:@"keep_grey"];
    [self configureButton:self.lockButton WithTitle:BEGetStringWithKeyFromTable(@"锁屏", @"P06A") imageName:@"lock"];
    
    [self.pressureButton setTitle:BEGetStringWithKeyFromTable(@"治疗压力", @"P06A") forState:UIControlStateNormal];
    
    
    self.lockButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.modeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.pauseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.stopButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.lockButton setTitleEdgeInsets:UIEdgeInsetsMake(self.lockButton.imageView.frame.size.height+20 ,-self.lockButton.imageView.frame.size.width, 0.0,0.0)];
    [self.lockButton setImageEdgeInsets:UIEdgeInsetsMake(-20, 0.0,0.0, -self.lockButton.titleLabel.bounds.size.width)];
    
    [self.modeButton setTitleEdgeInsets:UIEdgeInsetsMake(self.modeButton.imageView.frame.size.height+20 ,-self.modeButton.imageView.frame.size.width, 0.0,0.0)];
    [self.modeButton setImageEdgeInsets:UIEdgeInsetsMake(-20, 0.0,0.0, -self.modeButton.titleLabel.bounds.size.width)];
    
    self.startButton.layer.cornerRadius = 15;
    self.startButton.layer.borderWidth = 2;
    self.startButton.layer.borderColor = [UIColor whiteColor].CGColor;

    //圆角
    CGFloat radius = 15.0f;
    UIBezierPath *maskPath=[UIBezierPath bezierPathWithRoundedRect:self.stopButton.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer=[[CAShapeLayer alloc]init];
    maskLayer.frame=self.stopButton.bounds;
    maskLayer.lineWidth = 2;
    maskLayer.borderColor = [UIColor whiteColor].CGColor;
    maskLayer.path=maskPath.CGPath;
    self.stopButton.layer.mask=maskLayer;
    
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:self.pauseButton.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer1=[[CAShapeLayer alloc]init];
    maskLayer1.frame=self.pauseButton.bounds;
    maskLayer1.path=maskPath1.CGPath;
    maskLayer1.lineWidth = 2;
    maskLayer1.borderColor = [UIColor whiteColor].CGColor;
    self.pauseButton.layer.mask=maskLayer1;
    self.pressureButton.layer.cornerRadius = 15;
}


-(void)updateUI{
    if (self.runningState != STATE_RUNNING) {
        //保存的电压值
        NSArray *savedPressKeys = @[@"KeepPress",@"IntervalPress",@"DynamicPress"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *pressString = [defaults objectForKey:savedPressKeys[self.treatMode]];
        
        self.pressureDisplay.text = pressString == nil? @"125": pressString;
        //刷新press进度圈
        self.progress.value = [pressString integerValue];
        
    }else{
        
        //正在运行中
        self.pressureDisplay.text = self.pressure;
        
        //刷新press进度圈
        self.progress.value = [self.pressure integerValue];
    }
    [self updatePressProgress];
    //开关状态
    switch (self.runningState) {
        case STATE_PAUSE:
        {
            self.controllButtonView.hidden = NO;
            self.startButton.hidden = YES;
            
            self.pauseButton.titleLabel.text = BEGetStringWithKeyFromTable(@"继续", @"P06A");
            [self.pauseButton setTitle:BEGetStringWithKeyFromTable(@"继续", @"P06A") forState:UIControlStateNormal];

            
        }
            break;
            
        case STATE_STOP:
            self.controllButtonView.hidden = YES;
            self.startButton.hidden = NO;
            self.timeDisplay.text = @"00:00";
            
            break;
        case STATE_RUNNING:
            self.controllButtonView.hidden = NO;
            self.startButton.hidden = YES;
            self.pauseButton.titleLabel.text = BEGetStringWithKeyFromTable(@"暂停", @"P06A");
            [self.pauseButton setTitle:BEGetStringWithKeyFromTable(@"暂停", @"P06A") forState:UIControlStateNormal];
            
            break;
            
        default:
            break;
    }
   

    
    //模式
    switch (self.treatMode) {
        case 0:
            
            [self configureButton:self.modeButton WithTitle:BEGetStringWithKeyFromTable(@"连续模式", @"P06A") imageName:@"keep_grey"];
            
            break;
        case 1:
            
            [self configureButton:self.modeButton WithTitle:BEGetStringWithKeyFromTable(@"间隔模式", @"P06A") imageName:@"interval_grey"];
            
            break;
        case 2:
            
            [self configureButton:self.modeButton WithTitle:BEGetStringWithKeyFromTable(@"动态模式", @"P06A") imageName:@"dynamic_grey"];
            
            break;
        default:
            break;
    }
    
    //锁
    if (self.isLocked) {
        [self configureButton:self.lockButton WithTitle:BEGetStringWithKeyFromTable(@"解锁",@"P06A") imageName:@"unlock"];
        if (!self.maskLayer){
            CALayer *maskLayer = [[CALayer alloc]init];
            maskLayer.frame = self.view.bounds;
            maskLayer.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.4].CGColor;
            maskLayer.delegate = self;
            [self.view.layer addSublayer:maskLayer];
            [maskLayer setNeedsDisplay];
            self.maskLayer = maskLayer;
        }
        
        self.modeButton.enabled = NO;
        self.startButton.enabled = NO;
        self.pressureButton.enabled = NO;
        
    }else {
        if (self.maskLayer) {
            [self.maskLayer removeFromSuperlayer];
            self.maskLayer = nil;
        }
        [self configureButton:self.lockButton WithTitle:BEGetStringWithKeyFromTable(@"锁屏", @"P06A") imageName:@"lock"];
        
        self.modeButton.enabled = YES;
        self.startButton.enabled = YES;
        self.pressureButton.enabled = YES;
    }
    
    //电量
    [self updateBatteryUI];
    
}

-(void)updateBatteryUI {
    //电池
    switch (self.batteryLevel) {
        case DATA_BETTERY_STATE_CHARGE:
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
            
            UIImageView *chargeImageView = [self.batteryView viewWithTag:DATA_BETTERY_STATE_CHARGE];
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
}

#pragma mark - babyDelegate


- (void)babyDelegate {
    __weak typeof(self) weakSelf = self;
    __weak typeof(baby) weakBaby = baby;
//    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
//        if (central.state == CBCentralManagerStatePoweredOn) {
//            if (weakSelf.HUD) {
//                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
//            }
//            weakSelf.blueToothPowerOn = YES;
//            weakBaby.scanForPeripherals().begin();
//            [weakSelf performSelector:@selector(connectPeripheral) withObject:nil afterDelay:1.0];
//
//        }else if(central.state == CBCentralManagerStatePoweredOff) {
//            if (weakSelf.view) {
//                weakSelf.blueToothPowerOn = NO;
//                weakSelf.HUD = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
//                weakSelf.HUD.mode = MBProgressHUDModeText;
//                weakSelf.HUD.label.text = @"设备尚未打开蓝牙,请在设置中打开";
//                [weakSelf.HUD showAnimated:YES];
//                [weakSelf.navigationController popViewControllerAnimated:YES];
//            }
//        }
//    }];
    
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {

        
//        if ([peripheral.name hasPrefix:@"P06A"])
//        {

            //获取mac地址
            NSData *data = (NSData *)[advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
            Byte *dataByte = (Byte *)[data bytes];
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:20];
            if (dataByte) {
                for (int i =0 ; i < 6; i++) {
                    [array addObject:[NSString stringWithFormat:@"%x",dataByte[i]]];
                }
            }

            NSString *macString = [array componentsJoinedByString:@""];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *savedMacString = [userDefaults objectForKey:@"MacString"];
//            NSString *savedPeripheralName = [userDefaults objectForKey:@"PeripheralName"];
            if (!savedMacString) {

            }else {
                if([savedMacString isEqualToString:macString]){
                    if (weakSelf.HUD) {
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    }
                    [weakBaby cancelScan];
                    weakSelf.peripheral = peripheral;
                }
//                if ([savedMacString isEqualToString:macString] &&  [savedPeripheralName isEqualToString:peripheral.name]){
//                    if (weakSelf.HUD) {
//                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
//                    }
//                    [weakBaby cancelScan];
//                    weakSelf.peripheral = peripheral;
//
//                }
            }
//        }
    }];
    
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        weakSelf.isConnected = YES;
        NSLog(@"连接成功");
        [weakSelf performSelector:@selector(showConnectAlert) withObject:nil afterDelay:0.05];
        [weakBaby cancelScan];


    }];
    
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"设备连接失败", @"P06A")];
        [SVProgressHUD dismissWithDelay:0.9];
 
    }];
    
    
    
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开连接");

        weakBaby.scanForPeripherals().begin();
//        [weakSelf showDisconnectAlert];
        weakSelf.peripheral = nil;
        weakSelf.sendCharacteristic = nil;
        
    }];
    
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"didDiscoverservices");
    }];
    
    //发现service的Characteristics
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_UUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics)
            {

                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:RX_CHARACTERISTIC_UUID]])
                {
                    weakSelf.receiveCharacteristic = characteristic;
                    if (![characteristic isNotifying]) {
                        [weakSelf setNotify:characteristic];
                    }
                }
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TX_CHARACTERISTIC_UUID]])
                {
                    weakSelf.sendCharacteristic = characteristic;
                    
                }
            }
        }
    }];
    
    //接收到的数据操作
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    
    
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        //设置查找规则是名称大于0 ， the search rule is peripheral.name length > 0
        if (peripheralName.length >0) {
            return YES;
        }
        return NO;
    }];
    
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}


#pragma mark - receiveData
-(void)setNotify:(CBCharacteristic *)characteristic {
    __weak typeof(self)weakSelf = self;
    [weakSelf.peripheral setNotifyValue:YES forCharacteristic:characteristic];
    [baby notify:weakSelf.peripheral
  characteristic:characteristic
           block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//               NSLog(@"BLECommunication----------------------------------------------");
               NSData *data = characteristic.value;

               Byte *dataWithCmdIdBytes = (Byte *)[data bytes];
               NSMutableArray *dataArray = [[NSMutableArray alloc]init];
               for (int i = 0; i<[data length]; i++) {
                   [dataArray addObject:[NSString stringWithFormat:@"%02X",dataWithCmdIdBytes[i]]];
               }
               NSString *string = [dataArray componentsJoinedByString:@"---"];
               NSLog(@"receive----------%@",string);
               
               
               if (data) {
                   //将数据存入缓存
                   [weakSelf.readBuf appendData:[self convertData:data]];
                   [weakSelf analyzeReceivedData];
               }
           }];
}

-(void)analyzeReceivedData{
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
        else//如果缓存中的数据长度不够一个包的长度，则包不完整(处理半包，继续读取)
        {
            _readBuf = [[NSMutableData alloc]init];
//            [_socket readDataWithTimeout:-1 buffer:_readBuf bufferOffset:_readBuf.length tag:0];//继续读取数据
            return;
        }
    }
}

-(void)handleCompleteData:(NSData *)complateData {
    
    NSData *data = [Unpack unpackData:complateData];
    if (data) {
        Byte *bytes = (Byte *)[data bytes];
//        for (int i = 0; i<[data length]; i++)
//        {
//            NSLog(@"bytes[%d] = %x",i,bytes[i]);
//        }
        Byte cmdid = bytes[0];
        Byte dataByte = bytes[1];

        
        switch (cmdid)
        {
            //治疗状态
            case CMDID_DEVICE_STATE:
            {
                //开关机状态
                self.runningState = bytes[1];
                
                //锁屏
                self.isLocked = bytes[2];
                
                //电池电量
                Byte batteryLevel = bytes[3];
                
                
                //充电
                if (batteryLevel == DATA_BETTERY_STATE_CHARGE) {
                    self.batteryLevel = batteryLevel;
                }else{
                    //转成8421表示
                    self.batteryLevel = 16 - (16>>batteryLevel);
                }
                self.treatMode = bytes[4];
                
                //电压
                self.keepPressure = bytes[5];
                self.intervalPressure = bytes[6];
                self.dynamicPressure = bytes[7];
                NSString *keepPress = [NSString stringWithFormat:@"%d",bytes[5]];
                NSString *intervalPress = [NSString stringWithFormat:@"%d",bytes[6]];
                NSString *dynamicPress = [NSString stringWithFormat:@"%d",bytes[7]];
                
                
                NSArray *values = @[keepPress,intervalPress,dynamicPress];
                NSArray *keys = @[@"KeepPress",@"IntervalPress",@"DynamicPress"];
                
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                
                for (NSString* key in keys) {
                    NSInteger index = [keys indexOfObject:key];
                    [userDefaultes setObject:values[index] forKey:key];
                    [userDefaultes synchronize];
                }
                
                NSString *pressure = values[self.treatMode];
                self.pressure = [NSString stringWithFormat:@"%@",pressure];
                
                //治疗时间
                NSArray *timeKeys = @[@"WorkTime",@"IntervalTime",@"UpTime",@"DownTime"];

                NSString *WorkTime = [NSString stringWithFormat:@"%d",bytes[8]];
                NSString *IntervalTime = [NSString stringWithFormat:@"%d",bytes[9]];
                NSString *UpTime = [NSString stringWithFormat:@"%d",bytes[10]];
                NSString *DownTime = [NSString stringWithFormat:@"%d",bytes[11]];
                
                NSArray *timeValues = @[WorkTime,IntervalTime,UpTime,DownTime];
                
                for (NSString* key in timeKeys) {
                    NSInteger index = [timeKeys indexOfObject:key];
                    [userDefaultes setObject:timeValues[index] forKey:key];
                    [userDefaultes synchronize];
                }
            }
                break;
                
            //治疗经过时间
            case CMDID_TREAT_TIME:
            {
                //因为下位机的bug写的这句 结束的时候保存的治疗时间值没有清零
                if (self.runningState == STATE_STOP ) {
                    startTime = 0;
                }
                Byte timeBytes [] = {bytes[1],bytes[2],bytes[3],bytes[4]};
                
                startTime = [self lBytesToInt:timeBytes withLength:4];

                //治疗经过时间
                long hour = startTime / 3600;
                long min = startTime / 60 % 60;
                NSString *hourString = [NSString stringWithFormat:hour>9?@"%ld":@"0%ld",hour];
                NSString *minString = [NSString stringWithFormat:min>9?@"%ld":@"0%ld",min];
                self.timeDisplay.text = [NSString stringWithFormat:@"%@:%@",hourString,minString];
                
            }
                break;
                
                
            //开关机状态
            case CMDID_POWER_CONTROL:
            {

                self.runningState = bytes[1];
                if (self.runningState == STATE_RUNNING) {
                    //获取系统当前的时间戳
//                    NSString *currentTimeString = [self getCurrentTime];
//                    [self writeWithCmdid:CMDID_DATE dataString:currentTimeString];
                    
                    if (!_timer) {
                        NSLog(@"timerStartTime = %ld",(long)startTime);
                        [self startGCDTimerWithStartTime:startTime];
                    }
                    
                }else if(self.runningState == STATE_PAUSE){
                    [self askForDuration];
                    [self stopTimer];
                }else if(self.runningState == STATE_STOP){
                    [self askForDuration];
                    [self stopTimer];
                    
                    //治疗经过时间
                    long hour = startTime / 3600;
                    long min = startTime / 60 % 60;
                    NSString *hourString = [NSString stringWithFormat:hour>9?@"%ld":@"0%ld",hour];
                    NSString *minString = [NSString stringWithFormat:min>9?@"%ld":@"0%ld",min];
                    self.timeDisplay.text = [NSString stringWithFormat:@"%@:%@",hourString,minString];
                }
                
            }
                break;
                
                
            //电压设置值
                
            case CMDID_PRESSURE_SET:
            {
                NSString *keepPress = [NSString stringWithFormat:@"%d",bytes[1]];
                NSString *intervalPress = [NSString stringWithFormat:@"%d",bytes[2]];
                NSString *dynamicPress = [NSString stringWithFormat:@"%d",bytes[3]];
                NSArray *values = @[keepPress,intervalPress,dynamicPress];
                NSArray *keys = @[@"KeepPress",@"IntervalPress",@"DynamicPress"];

                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];

                for (NSString* key in keys) {
                    NSInteger index = [keys indexOfObject:key];
                    [userDefaultes setObject:values[index] forKey:key];
                    [userDefaultes synchronize];
                }

                NSString *pressure = values[self.treatMode];
                self.pressure = [NSString stringWithFormat:@"%@",pressure];
                
            }
                break;
                
                
            //电压实时值
            case CMDID_PRESSURE_GET:
                self.pressure = [NSString stringWithFormat:@"%d",bytes[1]];
                
                break;
                
                
            //电池显示
            case CMDID_BATTERY_DATA:
            {
                
                Byte batteryLevel = bytes[1];
                //充电
                if (batteryLevel == DATA_BETTERY_STATE_CHARGE) {
                    self.batteryLevel = batteryLevel;
                }else{
                    //转成8421表示
                    self.batteryLevel = 16 - (16>>batteryLevel);
                }
                [self updateBatteryUI];
                
            }
                break;
                
            
            //模式
            case CMDID_TREAT_MODE:
            {
                
                self.treatMode = bytes[1];
                
            }
                break;
                
            //锁屏
            case CMDID_LOCK_CONTROL:
            {
                
                self.isLocked = bytes[1];
                
            }
                break;
                
            //治疗参数
            case CMDID_WORK_TIME:
            case CMDID_INTERVAL_TIME:
            case CMDID_UP_TIME:
            case CMDID_DOWN_TIME:
            {
                NSArray *keys = @[@"WorkTime",@"IntervalTime",@"UpTime",@"DownTime"];
                NSString *dataString = [NSString stringWithFormat:@"%d",dataByte];
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                [userDefaultes setObject:dataString forKey:keys[cmdid - CMDID_WORK_TIME]];
                [userDefaultes synchronize];
            }
                break;

            //警告信息
            case CMDID_ALERT_INFORMATION:
            {
                self.runningState = STATE_STOP;
                NSString *alertMessege = [[NSString alloc]init];
                switch (dataByte) {
                    case 0x00:  alertMessege = BEGetStringWithKeyFromTable(@"无异常报警",@"P06A");    break;
                    case 0x01:  alertMessege = BEGetStringWithKeyFromTable(@"设备废液瓶满",@"P06A");  break;
                    case 0x02:  alertMessege = BEGetStringWithKeyFromTable(@"设备压力过低",@"P06A");  break;
                    case 0x03:  alertMessege = BEGetStringWithKeyFromTable(@"设备压力过高",@"P06A");  break;
                    case 0x04:  alertMessege = BEGetStringWithKeyFromTable(@"设备电量异常",@"P06A");  break;
                    case 0x05:  alertMessege = BEGetStringWithKeyFromTable(@"设备使用到期",@"P06A");  break;
                    default:
                        break;
                }
//                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//                [SVProgressHUD showErrorWithStatus:alertMessege];
                [AlertView showAboveIn:self withData:alertMessege];
                
                //清零记时
                startTime = 0;
                [self stopTimer];
            }
                break;
            default:
                break;
        }
        [self updateUI];
    }
}


#pragma mark - writeData


-(void)writeWithCmdid:(Byte)cmdid dataString:(NSString *)dataString{
    if (self.sendCharacteristic) {
        [self.peripheral writeValue:[Pack packetWithCmdid:cmdid
                                              dataEnabled:YES
                                                     data:[self convertHexStrToData:dataString]]
                  forCharacteristic:self.sendCharacteristic
                               type:CBCharacteristicWriteWithResponse];
    }
}
-(void)writeWithCmdid:(Byte)cmdid data:(NSData *)data{
    
    if (self.sendCharacteristic) {
        [self.peripheral writeValue:[Pack packetWithCmdid:cmdid
                                              dataEnabled:YES
                                                     data:data]
                  forCharacteristic:self.sendCharacteristic
                               type:CBCharacteristicWriteWithResponse];
    }
}


-(void)askForDeviceState {
//
//    [self.peripheral writeValue:[Pack packetWithCmdid:CMDID_DEVICE_STATE
//                                          dataEnabled:NO
//                                                 data:nil]
//              forCharacteristic:self.sendCharacteristic
//                           type:CBCharacteristicWriteWithResponse];
    [self writeWithCmdid:CMDID_DEVICE_STATE dataString:@"00"];

    
}

-(void)askForDuration {
    [self writeWithCmdid:CMDID_TREAT_TIME dataString:nil];
}


#pragma mark - connect
-(void)connectPeripheral {
    if (!self.isConnected) {
        if (baby) {
            if (self.peripheral) {
                baby.having(self.peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
            }else {
                //开了蓝牙但是没有检测到设备
                if (self.blueToothPowerOn) {
//                    [self showDisconnectAlert];
                    baby.scanForPeripherals().begin();
                    
                }
            }
        }
    }
}

#pragma mark - action
- (IBAction)lock:(id)sender {

    if (!self.isLocked) {
        [self configureButton:self.lockButton WithTitle:BEGetStringWithKeyFromTable(@"解锁", @"P06A") imageName:@"unlock"];
        [self writeWithCmdid:CMDID_LOCK_CONTROL dataString:@"0100"];
        
    }else {
        [self configureButton:self.lockButton WithTitle:BEGetStringWithKeyFromTable(@"锁屏", @"P06A") imageName:@"lock"];
        [self writeWithCmdid:CMDID_LOCK_CONTROL dataString:@"0000"];
    }
    self.isLocked = !self.isLocked;
    
    if (!self.maskLayer) {
        CALayer *maskLayer = [[CALayer alloc]init];
        maskLayer.frame = self.view.bounds;
        maskLayer.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.4].CGColor;
        maskLayer.delegate = self;
        [self.view.layer addSublayer:maskLayer];
        
        //让代理方法调用 将周围的蒙版颜色加深
        
        [maskLayer setNeedsDisplay];
        self.maskLayer = maskLayer;
    }else {
        [self.maskLayer removeFromSuperlayer];
        self.maskLayer = nil;
    }

    self.modeButton.enabled = !self.modeButton.enabled;
    self.startButton.enabled = !self.startButton.enabled;
    self.pressureButton.enabled = !self.pressureButton.enabled;
}


- (IBAction)tapModeButton:(id)sender {
//    [ModeChooseView alertControllerAboveIn:self selectedReturn:^(NSInteger mode) {
//        switch (mode) {
//            case 0:
//
//                [self configureButton:self.modeButton WithTitle:@"连续模式" imageName:@"keep_grey"];
//                [self writeWithCmdid:CMDID_TREAT_MODE dataString:@"0000"];
//                break;
//            case 1:
//
//                [self configureButton:self.modeButton WithTitle:@"间隔模式" imageName:@"interval_grey"];
//                [self writeWithCmdid:CMDID_TREAT_MODE dataString:@"0100"];
//
//                break;
//            case 2:
//
//                [self configureButton:self.modeButton WithTitle:@"动态模式" imageName:@"dynamic_grey"];
//                [self writeWithCmdid:CMDID_TREAT_MODE dataString:@"0200"];
//
//                break;
//            default:
//                break;
//        }
//    }];
    [ParameterView alertControllerAboveIn:self mode:self.treatMode setReturn:^(NSDictionary *parameters) {
        __weak typeof(self) weakself = self;
        NSInteger mode = [[parameters objectForKey:@"mode"]integerValue];
        NSInteger press = [[parameters objectForKey:@"press"]integerValue];
        NSString *firstTime = [parameters objectForKey:@"firstTime"];
        NSString *secondTime = [parameters objectForKey:@"secondTime"];
        
        //设置模式 时间
        switch (mode) {
            case DATA_TREAT_MODE_KEEP:
                
                weakself.keepPressure = press;
                
                [self writeWithCmdid:CMDID_TREAT_MODE dataString:@"0000"];
                
                break;
            case DATA_TREAT_MODE_INTERVAL:
                
                weakself.intervalPressure = press;
                
                [self writeWithCmdid:CMDID_TREAT_MODE dataString:@"0100"];
                [self writeWithCmdid:CMDID_WORK_TIME dataString:firstTime];
                [self writeWithCmdid:CMDID_INTERVAL_TIME dataString:secondTime];
                
                break;
            
            case DATA_TREAT_MODE_DYNAMIC:
                weakself.dynamicPressure = press;
                
                [self writeWithCmdid:CMDID_TREAT_MODE dataString:@"0200"];
                [self writeWithCmdid:CMDID_UP_TIME dataString:firstTime];
                [self writeWithCmdid:CMDID_DOWN_TIME dataString:secondTime];

                break;
                
            default:
                break;
        }
        //设置压力
        Byte byte[] = {
                        weakself.keepPressure,
                        weakself.intervalPressure,
                        weakself.dynamicPressure
                      };
        NSData *pressData = [[NSData alloc]initWithBytes:byte length:3];
        [self writeWithCmdid:CMDID_PRESSURE_SET data:pressData];
        
        
        
    }];
    
}
- (IBAction)tapPressButton:(id)sender {
    
    [PressParameterSetView alertControllerAboveIn:self mode:self.treatMode setReturn:^(NSString *pressValue) {
        __weak typeof(self) weakself = self;
        switch (self.treatMode) {
            case DATA_TREAT_MODE_KEEP:
                
                weakself.keepPressure = pressValue.integerValue;
                
                break;
            case DATA_TREAT_MODE_INTERVAL:
                
                weakself.intervalPressure = pressValue.integerValue;
                
                break;
                
            case DATA_TREAT_MODE_DYNAMIC:
                weakself.dynamicPressure = pressValue.integerValue;

                break;
                
            default:
                break;
        }
        
        //设置压力
        Byte byte[] = {
            weakself.keepPressure,
            weakself.intervalPressure,
            weakself.dynamicPressure
        };
        NSData *pressData = [[NSData alloc]initWithBytes:byte length:3];
        [self writeWithCmdid:CMDID_PRESSURE_SET data:pressData];
    }];
    
}

- (IBAction)start:(id)sender {
    if (self.isConnected) {
        [self writeWithCmdid:CMDID_POWER_CONTROL dataString:@"0100"];
    }
}

- (IBAction)pause:(id)sender {

    if (self.runningState ==STATE_RUNNING) {
        [self writeWithCmdid:CMDID_POWER_CONTROL dataString:@"0200"];
    }else{
        [self writeWithCmdid:CMDID_POWER_CONTROL dataString:@"0100"];
    }
}


- (IBAction)stop:(id)sender {

    [self writeWithCmdid:CMDID_POWER_CONTROL dataString:@"0000"];
}


#pragma mark - privateData

//模式设置按钮格式切换
-(void)configureButton:(UIButton *)button WithTitle:(NSString *)title imageName:(NSString*)imageName {
    button.titleLabel.text = title;
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

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

-(NSString*) convertIntergerToString:(NSInteger)value
{
    Byte src[4]={0,0,0,0};
    
    //小端模式
    src[3] = (Byte)((value>>24) & 0xFF);
    src[2] = (Byte)((value>>16) & 0xFF);
    src[1] = (Byte)((value>>8) & 0xFF);
    src[0] = (Byte)(value & 0xFF);
    NSString *string = [NSString stringWithFormat:@"%x%x%x%x",src[0],src[1],src[2],src[3]];
    
    return string;
    
}

- (NSString *)getCurrentTime
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval currentTime = [date timeIntervalSince1970];
    NSLog(@"currentTimeInterval = %d",(int)currentTime);
    NSString *string =[self convertIntergerToString:(int)currentTime];
    return string;
}


/**
 *  该方法废弃
 */
-(void)showDisconnectAlert {
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.label.text = BEGetStringWithKeyFromTable(@"没有检测到设备，请检查设备是否开机", @"P06A");
    [self.HUD showAnimated:YES];
}

-(void)showConnectAlert {

    [SVProgressHUD showSuccessWithStatus:BEGetStringWithKeyFromTable(@"设备连接成功", @"P06A")];
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

- (void)startGCDTimerWithStartTime:(NSInteger)startTime
{
    __block NSInteger time = startTime;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), NSEC_PER_SEC * 1, 0);
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                            long hour = time / 3600;
                            long min = time / 60 % 60;
//                            long second = time % 60;
                            NSString *hourString = [NSString stringWithFormat:hour>9?@"%ld":@"0%ld",hour];
                            NSString *minString = [NSString stringWithFormat:min>9?@"%ld":@"0%ld",min];
//                            NSString *secondString = [NSString stringWithFormat:second>9?@"%ld":@"0%ld",second];
                            self.timeDisplay.text = [NSString stringWithFormat:@"%@:%@",hourString,minString];
                           
                            time++;

                       });
    });
    dispatch_resume(_timer);
}

- (void) stopTimer
{
    if(_timer)
    {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

#pragma mark - 反转义函数
-(NSData *)convertData:(NSData *)data{
    Byte *dataBytes = (Byte *)[data bytes];
    NSInteger length = [data length];
    uint8_t *ls = malloc(length);
    UInt32 lengthOfLs = 0;
    for (int i = 0; i<[data length]; i++) {
        if (dataBytes[i] == 0xcc) {
            ls[lengthOfLs++] = dataBytes[++i]-1;
        }
        else{
            ls[lengthOfLs++] = dataBytes[i];
        }
    }
    NSData *convertData = [NSData dataWithBytes:ls length:lengthOfLs];
    return convertData;
}
@end
