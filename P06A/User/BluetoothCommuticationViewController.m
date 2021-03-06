//
//  BluetoothCommuticationViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/10.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "BLECommunication.h"
#import <MBProgressHUD.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SVProgressHUD.h"
#import "BabyBluetooth.h"
#import "ModeChooseView.h"
#import "PressParameterSetView.h"
#import "Pack.h"
#import "Unpack.h"
#import "SetTreatmentParameterController.h"
#import "BLERecordViewController.h"
//#import "GuideBindDeviceViewController.h"

#define SERVICE_UUID            @"00001000-0000-1000-8000-00805f9b34fb"
#define TX_CHARACTERISTIC_UUID  @"00001001-0000-1000-8000-00805f9b34fb"
#define RX_CHARACTERISTIC_UUID  @"00001002-0000-1000-8000-00805f9b34fb"

typedef NS_ENUM(NSInteger,KCmdids)
{
    CMDID_POWER_CONTROL         = 0X0e,
    CMDID_LOCK_CONTROL          = 0X0f,
    CMDID_CONNECT_SUCCESFULLY   = 0Xff,
    CMDID_TREAT_MODE            = 0X01,
    CMDID_PRESSURE_SET          = 0X02,
    CMDID_PRESSURE_GET          = 0X03,
    CMDID_BATTERY_DATA          = 0X04,
    CMDID_TREAT_TIME            = 0X06,
    
    CMDID_WORK_TIME             = 0X07,
    CMDID_INTERVAL_TIME         = 0X08,
    CMDID_UP_TIME               = 0X09,
    CMDID_DOWN_TIME             = 0X0A,
    CMDID_DATE                  = 0X0D,
    
    CMDID_TREAT_RECORD_SUM      = 0X0C,
    CMDID_PAGE_TREAT_RECORD     = 0X10,
    
    CMDID_DEVICE_STATE          = 0XFA,
    CMDID_ALERT_INFORMATION     = 0X0B,
    
    
};
typedef NS_ENUM(NSInteger,Kdata)
{
    DATA_BETTERY_STATE_CHARGE = 0X06,
    
    DATA_TREAT_MODE_KEEP      = 0X00,
    DATA_TREAT_MODE_INTERVAL  = 0X01,
    DATA_TREAT_MODE_DYNAMIC   = 0X02,
    
    RUNNING_STATE_POWER_OFF   = 0X00,
    RUNNING_STATE_POWER_ON    = 0X01,
    RUNNING_STATE_PAUSE       = 0X02,
    
    WARNING_WASTE_LIQUIDES_IS_FULL = 0X00,
    WARNING_PRESSURE_TOO_HIGH      = 0X01,
    WARNING_PRESSURE_TOO_LOW       = 0X02,
    WARNING_USE_EXPIRATION         = 0X03,
    WARNING_BATTERY_EXCEPTION      = 0X04
    
    
};

@interface BLECommunication ()<CALayerDelegate>{
    BabyBluetooth *baby;
}
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *modeButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *pressureButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;


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


@end

@implementation BLECommunication

- (void)viewDidLoad {
    [super viewDidLoad];

    //检测有没有绑定蓝牙设备
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"MacString"]) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                               message:@"当前没有配对设备，请前往设置"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * _Nonnull action) {
//                                                                          GuideBindDeviceViewController *vc = [[GuideBindDeviceViewController alloc]init];
//                                                                          [self.navigationController pushViewController:vc animated:YES];
                                                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                                                      }];
        
                [alert addAction:cancelAction];
                [alert addAction:defaultAction];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alert animated:YES completion:nil];
                });
    }else{
        //配置svprogressHUD
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD setMinimumSize:CGSizeMake(200, 100)];
        [SVProgressHUD setCornerRadius:5];
        [SVProgressHUD showWithStatus:@"Connecting"];
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
    
}

-(void)handleConnectTimeOut{
    if (!self.isConnected) {
        [SVProgressHUD setMinimumSize:CGSizeZero];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
        [SVProgressHUD showInfoWithStatus:@"下位机无响应"];
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
    if (self.sendCharacteristic) {
        [self askForDeviceState];
    }
    if (self.receiveCharacteristic) {

        [self setNotify:self.receiveCharacteristic];

    }
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
//    [baby cancelAllPeripheralsConnection];
    [self removeObserver:self forKeyPath:@"peripheral" context:nil];
    [self removeObserver:self forKeyPath:@"sendCharacteristic" context:nil];
    
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"peripheral"]) {
        [self connectPeripheral];
        [self.HUD hideAnimated:YES];
    }
    
    if ([keyPath isEqualToString:@"sendCharacteristic"]) {
//        [self performSelector:@selector(askForDeviceState) withObject:nil afterDelay:0.5];
        [self askForDeviceState];
    }
}


#pragma mark - configureUI
-(void)configureButtonUI{
    [self.lockButton setTitleEdgeInsets:UIEdgeInsetsMake(self.lockButton.imageView.frame.size.height+20 ,-self.lockButton.imageView.frame.size.width, 0.0,0.0)];
    [self.lockButton setImageEdgeInsets:UIEdgeInsetsMake(-20, 0.0,0.0, -self.lockButton.titleLabel.bounds.size.width)];
    
    [self.recordButton setTitleEdgeInsets:UIEdgeInsetsMake(self.recordButton.imageView.frame.size.height+20 ,-self.recordButton.imageView.frame.size.width, 0.0,0.0)];
    [self.recordButton setImageEdgeInsets:UIEdgeInsetsMake(-20, 0.0,0.0, -self.recordButton.titleLabel.bounds.size.width)];
    
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


-(void)updateBatteryUI:(NSInteger )batteryLevel {
    switch (batteryLevel) {
        case DATA_BETTERY_STATE_CHARGE:
        {
            for (int i = 1; i < 5; i++) {
                UIImageView *imageView = [self.batteryView viewWithTag:i];
                imageView.highlighted = NO;
            }
            UIImageView *chargeImageView = [self.batteryView viewWithTag:batteryLevel];
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


-(void)updateModeUI{
    switch (self.treatMode) {
        case 0:
            
            [self configureButton:self.modeButton WithTitle:@"持续吸引" imageName:@"keep_grey"];
            
            break;
        case 1:
            
            [self configureButton:self.modeButton WithTitle:@"间歇吸引" imageName:@"interval_grey"];
            
            break;
        case 2:
            
            [self configureButton:self.modeButton WithTitle:@"动态吸引" imageName:@"dynamic_grey"];
            
            break;
        default:
            break;
    }
}


-(void)updateLockUI {

        if (self.isLocked) {
            [self configureButton:self.lockButton WithTitle:@"解锁" imageName:@"unlock"];
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
            self.recordButton.enabled = NO;
            self.startButton.enabled = NO;
            self.pressureButton.enabled = NO;
            
        }else {
            if (self.maskLayer) {
                [self.maskLayer removeFromSuperlayer];
                self.maskLayer = nil;
            }
            [self configureButton:self.lockButton WithTitle:@"锁屏" imageName:@"lock"];
            
            self.modeButton.enabled = YES;
            self.recordButton.enabled = YES;
            self.startButton.enabled = YES;
            self.pressureButton.enabled = YES;
        }

}


-(void)updatePressureUI:(NSString *)pressure {

    
    switch (self.runningState) {
        case RUNNING_STATE_PAUSE:
        case RUNNING_STATE_POWER_OFF:
            
            //保存的值
            self.pressureDisplay.text = self.pressure == nil? @"125":self.pressure;
            
            break;
        case RUNNING_STATE_POWER_ON:
            
            self.pressureDisplay.text = pressure;
    }

}


-(void)updatePowerControlUI {
    switch (self.runningState) {
        case RUNNING_STATE_PAUSE:
        case RUNNING_STATE_POWER_OFF:
            
            self.startButton.hidden = NO;
            self.pauseButton.hidden = YES;
            self.stopButton.hidden = YES;
            
            break;
        case RUNNING_STATE_POWER_ON:
            
            
            self.startButton.hidden = YES;
            self.pauseButton.hidden = NO;
            self.stopButton.hidden = NO;
            break;
            
        default:
            break;
    }
}


#pragma mark - babyDelegate

//- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
//    switch (central.state) {
//
//        case CBManagerStatePoweredOff:
//        {
//            if (self.view) {
//                self.blueToothPowerOn = NO;
//                self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                self.HUD.mode = MBProgressHUDModeText;
//                self.HUD.label.text = @"该设备尚未打开蓝牙,请在设置中打开";
//                [self.HUD showAnimated:YES];
//            }
//        }
//            break;
//        case CBManagerStatePoweredOn:
//            if (self.HUD) {
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            }
//            self.blueToothPowerOn = YES;
//            baby.scanForPeripherals().begin();
//            [self performSelector:@selector(connectPeripheral) withObject:nil afterDelay:1.0];
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            break;
//        default:
//            break;
//    }
//
//}

- (void)babyDelegate {
    __weak typeof(self) weakSelf = self;
    __weak typeof(baby) weakBaby = baby;
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBManagerStatePoweredOn) {
            if (weakSelf.HUD) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }
            weakSelf.blueToothPowerOn = YES;
            weakBaby.scanForPeripherals().begin();
            [weakSelf performSelector:@selector(connectPeripheral) withObject:nil afterDelay:1.0];

        }else if(central.state == CBManagerStatePoweredOff) {
            if (weakSelf.view) {
                weakSelf.blueToothPowerOn = NO;
                weakSelf.HUD = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                weakSelf.HUD.mode = MBProgressHUDModeText;
                weakSelf.HUD.label.text = @"设备尚未打开蓝牙,请在设置中打开";
                [weakSelf.HUD showAnimated:YES];
            }
        }
    }];
    
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

            NSString *macString = [array componentsJoinedByString:@"-"];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *savedMacString = [userDefaults objectForKey:@"MacString"];
            NSString *savedPeripheralName = [userDefaults objectForKey:@"PeripheralName"];
            if (!savedMacString) {

            }else {
                if ([savedMacString isEqualToString:macString] &&  [savedPeripheralName isEqualToString:peripheral.name]){
                    if (weakSelf.HUD) {
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    }
                    [weakBaby cancelScan];
                    weakSelf.peripheral = peripheral;
                    
                }
            }
//        }
    }];
    
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        weakSelf.isConnected = YES;
        NSLog(@"连接成功");
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
        [SVProgressHUD setMinimumSize:CGSizeZero];
        [SVProgressHUD setCornerRadius:14];
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"设备连接成功"]];
        [SVProgressHUD dismissWithDelay:0.9];
//        weakSelf.HUD = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
//        weakSelf.HUD.mode = MBProgressHUDModeText;
//        weakSelf.HUD.label.text = @"设备连接已完成";
//        [weakSelf.HUD showAnimated:YES];
        [weakBaby cancelScan];
//        if (weakSelf.HUD) {
//            [weakSelf.HUD hideAnimated:YES afterDelay:1.0];
//        }

    }];
    
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"设备连接失败"]];
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
               NSLog(@"----------------------------------------------");
               NSData *data = characteristic.value;
               if (data) {

                   //将数据存入缓存区
                   [weakSelf.readBuf appendData:data];
                   [weakSelf analyzeReceivedData];
               }

           }];
}

-(void)analyzeReceivedData{
    while (self.readBuf.length >= 2) {
        
        NSData *head = [_readBuf subdataWithRange:NSMakeRange(0, 2)];//取得头部数据
        
        NSData *lengthData = [head subdataWithRange:NSMakeRange(1, 1)];//取得长度数据
        
//        NSInteger length = [[[NSString alloc] initWithData:lengthData
//                                                  encoding:NSUTF8StringEncoding] intValue];//得出内容长度
        
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
            //开关机状态
            case CMDID_POWER_CONTROL:
            {

                self.runningState = bytes[1];
                if (self.runningState == RUNNING_STATE_POWER_ON) {
                    //获取系统当前的时间戳
                    NSString *currentTimeString = [self getCurrentTime];
                    [self writeWithCmdid:CMDID_DATE dataString:currentTimeString];
                    
                }
                [self updatePowerControlUI];
                [self updatePressureUI:nil];
                
            }
                break;
                
                
            //电压设置值
                
            case CMDID_PRESSURE_SET:
            {
//                NSString *keepPress = [NSString stringWithFormat:@"%d",bytes[1]];
//                NSString *intervalPress = [NSString stringWithFormat:@"%d",bytes[2]];
//                NSString *dynamicPress = [NSString stringWithFormat:@"%d",bytes[3]];
//                NSArray *values = @[keepPress,intervalPress,dynamicPress];
//                NSArray *keys = @[@"KeepPress",@"IntervalPress",@"DynamicPress"];
//
//                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
//
//                for (NSString* key in keys) {
//                    NSInteger index = [keys indexOfObject:key];
//                    [userDefaultes setObject:values[index] forKey:key];
//                    [userDefaultes synchronize];
//                }

                Byte pressureData = bytes[1];
                self.pressure = [NSString stringWithFormat:@"%d",pressureData];
                [self updatePressureUI:nil];
                
            }
                break;
                
                
            //电压实时值
            case CMDID_PRESSURE_GET:
                
                [self updatePressureUI:[NSString stringWithFormat:@"%d",bytes[1]]];
                
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
                [self updateBatteryUI:self.batteryLevel];
                
            }
                break;
                
            
            //模式
            case CMDID_TREAT_MODE:
            {
                
                self.treatMode = bytes[1];
                [self updateModeUI];
                
            }
                break;
                
            //锁屏
            case CMDID_LOCK_CONTROL:
            {
                
                self.isLocked = bytes[1];
                [self updateLockUI];
                
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
                self.runningState = RUNNING_STATE_POWER_OFF;
                [self updatePowerControlUI];
                NSString *alertMessege = [[NSString alloc]init];
                switch (dataByte) {
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
                
//                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
//                                                                               message:@"当前没有配对设备，请前往设置"
//                                                                        preferredStyle:UIAlertControllerStyleAlert];
//
//                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
//                                                                      handler:^(UIAlertAction * _Nonnull action) {
//
//                                                                      }];
//
//                [alert addAction:cancelAction];
//                [alert addAction:defaultAction];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self presentViewController:alert animated:YES completion:nil];
//                });
                
            }
                break;
            default:
                break;
        }
    }
}


#pragma mark - writeData
- (void)writeData:(NSData *)data {
    [self.peripheral writeValue:data
              forCharacteristic:self.sendCharacteristic
                           type:CBCharacteristicWriteWithResponse];
}

-(void)writeWithCmdid:(Byte)cmdid dataString:(NSString *)dataString{
    
    [self.peripheral writeValue:[Pack packetWithCmdid:cmdid
                                          dataEnabled:YES
                                                 data:[self convertHexStrToData:dataString]]
              forCharacteristic:self.sendCharacteristic
                           type:CBCharacteristicWriteWithResponse];
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
                    [self showDisconnectAlert];
                    baby.scanForPeripherals().begin();
                    
                }
            }
        }
    }
}


#pragma mark - action
- (IBAction)lock:(id)sender {

    if (!self.isLocked) {
        [self configureButton:self.lockButton WithTitle:@"解锁" imageName:@"unlock"];
        [self writeWithCmdid:CMDID_LOCK_CONTROL dataString:@"0100"];
        
    }else {
        [self configureButton:self.lockButton WithTitle:@"锁屏" imageName:@"lock"];
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
    self.recordButton.enabled = !self.recordButton.enabled;
    self.startButton.enabled = !self.startButton.enabled;
    self.pressureButton.enabled = !self.pressureButton.enabled;
}


- (IBAction)tapModeButton:(id)sender {
    [ModeChooseView alertControllerAboveIn:self selectedReturn:^(NSInteger mode) {
        switch (mode) {
            case 0:
                
                [self configureButton:self.modeButton WithTitle:@"持续吸引" imageName:@"keep_grey"];
                [self writeWithCmdid:CMDID_TREAT_MODE dataString:@"0000"];
                break;
            case 1:
                
                [self configureButton:self.modeButton WithTitle:@"间歇吸引" imageName:@"interval_grey"];
                [self writeWithCmdid:CMDID_TREAT_MODE dataString:@"0100"];
                
                break;
            case 2:
                
                [self configureButton:self.modeButton WithTitle:@"动态吸引" imageName:@"dynamic_grey"];
                [self writeWithCmdid:CMDID_TREAT_MODE dataString:@"0200"];
                
                break;
            default:
                break;
        }
    }];
}
- (IBAction)tapPressButton:(id)sender {
    [PressParameterSetView alertControllerAboveIn:self mode:self.treatMode setReturn:^(NSString *pressValue) {
        NSString *dataString = [NSString stringWithFormat:@"%@",pressValue];
        [self writeWithCmdid:CMDID_PRESSURE_SET dataString:dataString];
    }];
}


- (IBAction)start:(id)sender {
    [self writeWithCmdid:CMDID_POWER_CONTROL dataString:@"0100"];
}


- (IBAction)pause:(id)sender {

    [self writeWithCmdid:CMDID_POWER_CONTROL dataString:@"0200"];
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
    NSString *string =[self convertIntergerToString:(int)currentTime];
    return string;
}
-(void)showDisconnectAlert {
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.label.text = @"没有检测到设备，请检查设备是否开机";
    [self.HUD showAnimated:YES];
}

-(void)askForDeviceState {

    [self writeWithCmdid:CMDID_DEVICE_STATE dataString:@"0032"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowSetController"]) {
        SetTreatmentParameterController *vc = (SetTreatmentParameterController *)segue.destinationViewController;
        vc.sendCharacteristic = self.sendCharacteristic;
        vc.receiveCharacteristic = self.receiveCharacteristic;
        vc.currPeripheral = self.peripheral;
        vc ->baby = self ->baby;
    }else if ([segue.identifier isEqualToString:@"ShowBLERecord"]){
        BLERecordViewController *vc = (BLERecordViewController *)segue.destinationViewController;
        vc.sendCharacteristic = self.sendCharacteristic;
        vc.receiveCharacteristic = self.receiveCharacteristic;
        vc.currPeripheral = self.peripheral;
        vc ->baby = self ->baby;
    }
}

@end
