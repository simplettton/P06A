//
//  UpdateOnlineViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/4.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "UpgradeOnlineViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <UserNotifications/UserNotifications.h>
#import "BabyBluetooth.h"
#import "MBProgressHUD.h"
#import "SVProgressHUD.h"

#import "Pack.h"
#import "Unpack.h"


#define FILEPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]


#define SERVICE_UUID            @"00001000-0000-1000-8000-00805f9b34fb"
#define TX_CHARACTERISTIC_UUID  @"00001001-0000-1000-8000-00805f9b34fb"
#define RX_CHARACTERISTIC_UUID  @"00001002-0000-1000-8000-00805f9b34fb"


static NSString * const kOpenFileNotification = @"KOpenFileNotification";
static NSString * const kFileName = @"KFileName";
static NSString * const kFilePath = @"KFilePath";

static NSInteger  const BLE_SEND_MAX_LEN = 20;
static NSInteger  const EACH_TIME_PACKECT_NUM = 50;
static NSInteger  const UPGRATE_TIME_INTERVAL = 0.5;

#define PACKNUMBER ([self.binData length]/BLE_SEND_MAX_LEN)

typedef NS_ENUM(NSUInteger,ViewTags) {
    nameLableTag    = 1,
    addressLabelTag = 2,
    RSSILabelTag    = 3
};

typedef NS_ENUM(NSInteger,KCmdids) {
    CMDID_UPGRATE_REQUEST                = 0X9B,
    CMDID_SEND_DATA                      = 0X9F,
    CMDID_ARM_UPGRATE_PREPARE_COMPLETED  = 0X0D,
    CMDID_ARM_UPGRATE_DATA_REQUEST       = 0X0F,
    CMDID_ARM_UPGRATE_SUCCESSFULLY       = 0X14,
    CMDID_ARM_WAIT_UPGRATE_TIMEOUT       = 0X16,
};

@interface UpgradeOnlineViewController (){
    NSMutableArray *peripheralDataArray;
    BabyBluetooth *baby;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileLengthLabel;
@property (weak, nonatomic) IBOutlet UIView *fileView;


@property (nonatomic, strong) NSString *documentPath;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSData *binData;


@property (nonatomic, assign) BOOL isConnected;

//发了多少包
@property (nonatomic, assign) int sendTimes;

//发送的字节序号
@property (nonatomic, assign) int beginByte;

//缓存
@property (nonatomic,strong)NSMutableData *readBuf;

@property (strong ,nonatomic) CBPeripheral *peripheral;
@property (nonatomic,strong) CBCharacteristic *sendCharacteristic;
@property (nonatomic,strong) CBCharacteristic *receiveCharacteristic;


@property (nonatomic,strong) MBProgressHUD *HUD;

@end

@implementation UpgradeOnlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设备升级";
    [self initALL];
}

-(void)initALL {
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    peripheralDataArray = [[NSMutableArray alloc]init];
    
    baby = [BabyBluetooth shareBabyBluetooth];
    [self babyDelegate];
    
    [self setUpRefresh];
    [self configFileView];
    if (!self.binData)
    {
        self.fileView.hidden = YES;
    }
    self.sendTimes = 0;
    self.beginByte = 0;
    
    //创建数据缓存区
    self.readBuf = [[NSMutableData alloc] init];
    
    //这个可以查找 [FilePath getDelegateFilePath] 路径下的所有文件
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]enumeratorAtPath:FILEPATH];
    for (NSString *fileName in enumerator)
    {
        self.fileName = fileName;
        self.documentPath = [FILEPATH stringByAppendingPathComponent:fileName];
        if (self.documentPath)
        {
            BOOL isDirectory = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:[FILEPATH stringByAppendingPathComponent:fileName] isDirectory:&isDirectory];
            if (!isDirectory)
            {
                NSLog(@"File path is: %@", self.documentPath);
                NSData * resultdata = [[NSData alloc] initWithContentsOfFile:self.documentPath];
                self.binData = resultdata;
                self.fileView.hidden = NO;
                
                [self configFileView];
            }
        }
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self addObserver:self
           forKeyPath:@"sendCharacteristic"
              options:NSKeyValueObservingOptionNew
              context:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [baby cancelAllPeripheralsConnection];
    baby.scanForPeripherals().begin();
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleNotification:)
                                                name:kOpenFileNotification
                                              object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [baby cancelScan];

    [baby cancelAllPeripheralsConnection];

    [self removeObserver:self forKeyPath:@"sendCharacteristic" context:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:kOpenFileNotification
                                                 object:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sendCharacteristic"]) {
        [self performSelector:@selector(upgrate) withObject:nil afterDelay:0.02];
    }
}


-(void)configFileView {
    self.fileNameLabel.text = [NSString stringWithFormat:@"%@",(self.fileName!=nil)?self.fileName:@"App.bin"];
    self.fileLengthLabel.text = [NSString stringWithFormat:@"%luk",(unsigned long)(self.binData?[self.binData length]/1024:0)];
}


#pragma mark - babyDelegate
- (void)babyDelegate {
    __weak typeof(self) weakSelf = self;
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBManagerStatePoweredOn) {
            weakSelf.HUD = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            weakSelf.HUD.label.text = @"扫描设备中";
            // 隐藏时候从父控件中移除
            weakSelf.HUD.removeFromSuperViewOnHide = YES;
            [weakSelf.HUD showAnimated:YES];
            
        }else if(central.state == CBManagerStatePoweredOff) {
            [SVProgressHUD showInfoWithStatus:@"请打开蓝牙以连接设备"];
            [SVProgressHUD dismissWithDelay:1.5];
            
        }
    }];
    
    //扫描到设备
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf insertTableView:peripheral advertisementData:advertisementData RSSI:RSSI];
        if ([peripheral.name hasPrefix:@"P06A"])
        {
//            NSData *data = (NSData *)[advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
//            Byte *dataByte = (Byte *)[data bytes];
//            
//            NSMutableArray *array = [NSMutableArray arrayWithCapacity:20];
//            for (int i =0 ; i < 6; i++) {
//                [array addObject:[NSString stringWithFormat:@"%x",dataByte[i]]];
//            }
//
//            NSString *mac = [array componentsJoinedByString:@"-"];
        }
    }];
    
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        weakSelf.isConnected = YES;
        NSLog(@"连接成功");

    }];
    
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开连接");
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
    if (peripheralName.length > 0) {
        return YES;
    }
        return NO;
    }];
}


#pragma mark - Notification
- (void)handleNotification:(NSNotification *)notification
{
    NSLog(@"File path is: %@", notification.userInfo[kFilePath]);
    self.documentPath = notification.userInfo[kFilePath];
    NSData * resultdata = [[NSData alloc] initWithContentsOfFile:self.documentPath];
    self.binData = resultdata;
    self.fileView.hidden = NO;
    
    //显示状态
    self.fileName = notification.userInfo[kFileName];
    NSString *statusString = [NSString stringWithFormat:@"成功打开文件%@",self.fileName];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    [self configFileView];
    [SVProgressHUD showSuccessWithStatus:statusString];
    
}


#pragma mark - receiveData
- (void)setNotify:(CBCharacteristic *)characteristic {
    __weak typeof(self)weakSelf = self;
    [weakSelf.peripheral setNotifyValue:YES forCharacteristic:characteristic];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
    });
}
//处理粘包
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

            [self handleResponseData:data];//处理包数据

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


- (void)handleResponseData:(NSData *)complateData {
    NSData *data = [Unpack unpackData:complateData];
    if (data != nil) {
        Byte* bytes = (Byte *)[data bytes];
        Byte cmdid = bytes[0];
        NSLog(@"receive------- %x",cmdid);
        switch (cmdid) {
            case CMDID_ARM_UPGRATE_PREPARE_COMPLETED:
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                self.HUD.mode = MBProgressHUDModeText;
                self.HUD.label.text = @"进入升级模式完毕";
                });
                break;
            }
            case CMDID_ARM_UPGRATE_DATA_REQUEST:
                if (self.binData) {
                    NSInteger packNumber;
                    if ([self.binData length] % BLE_SEND_MAX_LEN) {
                        packNumber = [self.binData length]/BLE_SEND_MAX_LEN +1;
                    }else {
                        packNumber = [self.binData length]/BLE_SEND_MAX_LEN;
                    }
                    
                    double progress = (double)self.sendTimes /(double)packNumber ;
                    NSLog(@"progress = %f",progress);

                    
                    //延迟1ms分包发送 精度条更新
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001/*延迟执行时间*/ * NSEC_PER_SEC));
                    
                    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                            [self sendSubPackage:self.binData];
                    });
                    
                    //进度条
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
                        self.HUD.label.text = [NSString stringWithFormat:@"升级中...%ld%%",self.sendTimes *100 /packNumber];
                        self.HUD.progress = progress;
                        NSLog(@"self.hud.progress = %f",self.HUD.progress);
                        
                    });

                }
                break;
            case CMDID_ARM_UPGRATE_SUCCESSFULLY:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.HUD.mode = MBProgressHUDModeText;
                    self.HUD.minSize = CGSizeZero;
                    self.HUD.label.text = @"升级成功";
                    [self.HUD hideAnimated:YES afterDelay:1.5];
                    
                });
                [self pushNotification];

                break;
            }
            case CMDID_ARM_WAIT_UPGRATE_TIMEOUT:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.HUD.label.text = @"✖️升级超时";
                    //✕✗✘/
                    [self.HUD hideAnimated:1.5];
                });

                break;
            }
            default:
                break;
        }
    }
}


#pragma mark - writeData
- (void)writeData:(NSData *)data
{
    
    [self.peripheral writeValue:data
                  forCharacteristic:self.sendCharacteristic
                               type:CBCharacteristicWriteWithoutResponse];
}

//分包 每次发50个
-(void)sendSubPackage:(NSData*)completeData
{
    self.beginByte = self.sendTimes * BLE_SEND_MAX_LEN;
    for (int i = self.beginByte ;(i < (EACH_TIME_PACKECT_NUM * BLE_SEND_MAX_LEN + self.beginByte)) && (i < [completeData length]); i += BLE_SEND_MAX_LEN) {
        // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
        if ((i + BLE_SEND_MAX_LEN) < [completeData length]) {

            NSString *rangeStr = [NSString stringWithFormat:@"%i,%li", i,
                                  (long)BLE_SEND_MAX_LEN];
            NSData *subData = [completeData subdataWithRange:NSRangeFromString(rangeStr)];
            

            NSLog(@"i = %d",i);
            [self writeData:subData];
            NSLog(@"upgrateTime = %ld",(long)UPGRATE_TIME_INTERVAL);
            [NSThread sleepForTimeInterval:0.01];
            self.sendTimes ++;

        }
        else {
            //最后一个包
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([completeData length] - i)];
            NSData *subData = [completeData subdataWithRange:NSRangeFromString(rangeStr)];

            [self writeData:subData];
            [NSThread sleepForTimeInterval:0.01];
            self.sendTimes ++;
        }
    }
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return peripheralDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary *item = [peripheralDataArray objectAtIndex:indexPath.row];
    CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
    NSDictionary *advertisementData = [item objectForKey:@"advertisementData"];
    
    NSNumber *RSSI = [item objectForKey:@"RSSI"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name
    NSString *peripheralName;
    if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
        peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
    }else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)) {
        peripheralName = peripheral.name;
    }else
    {
        peripheralName = [peripheral.identifier UUIDString];
    }
    //mac地址
    NSData *data = (NSData *)[advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:20];
    if (data) {
        Byte *dataByte = (Byte *)[data bytes];

        for (int i =0 ; i < 6; i++) {
            [array addObject:[NSString stringWithFormat:@"%x",dataByte[i]]];
        }
    }
    
    NSString *mac = [array componentsJoinedByString:@"-"];
    
    
    UILabel *nameLabel      = (UILabel *)[cell.contentView viewWithTag:nameLableTag];
    UILabel *addressLabel   = (UILabel *)[cell.contentView viewWithTag:addressLabelTag];
    UILabel *RSSILabel      = (UILabel *)[cell.contentView viewWithTag:RSSILabelTag];
    
    if(!data) {     addressLabel.text = peripheral.identifier.UUIDString;   }
        else  {     addressLabel.text = mac;                                }
    
    nameLabel.text = [NSString stringWithFormat:@"%@",peripheralName];
    RSSILabel.text = [NSString stringWithFormat:@"RSSI:%@",RSSI];


    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 120.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [baby cancelScan];
    
    NSDictionary *item = [peripheralDataArray objectAtIndex:indexPath.row];
    CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
    self.peripheral = peripheral;
    if (!self.binData) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"系统查找不到升级文件，请找到bin文件并在本应用中打开"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });

    }
//    else if ([peripheral.name hasPrefix:@"P06A"]) {
//        baby.having(self.peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
//
//    }else {
//        [self showMessageWithTitle:@"当前升级文件不支持该设备的升级" hideAfterDelay:YES];
//    }
    else{
        baby.having(self.peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    }
}

- (void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSArray *peripherals = [peripheralDataArray valueForKey:@"peripheral"];
    if(![peripherals containsObject:peripheral]) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:0];
        [indexPaths addObject:indexPath];
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setValue:peripheral forKey:@"peripheral"];
        [item setValue:RSSI forKey:@"RSSI"];
        [item setValue:advertisementData forKey:@"advertisementData"];
        [peripheralDataArray addObject:item];
        
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - refresh

- (void)setUpRefresh {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    NSLog(@"下拉刷新");
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [refreshControl beginRefreshing];
    [self.tableView addSubview:refreshControl];
    [self refresh:refreshControl];
}
// 下拉刷新触发，在此获取数据
- (void)refresh:(UIRefreshControl *)refreshControl {
    NSLog(@"refreshClick: -- 刷新触发");
    [refreshControl endRefreshing];
    baby.scanForPeripherals().begin();
    [self.tableView reloadData];
}


#pragma mark - upgrate

- (void)upgrate {
    if(self.isConnected)
    {
        if (self.binData)
        {
            [self sendUpgrateRequest];
            
            [self showMessageWithTitle:@"正在请求进入升级模式…" hideAfterDelay:NO];
        }else
        {
            [SVProgressHUD showErrorWithStatus:@"没有找到升级包"];
            [SVProgressHUD dismissWithDelay:1];
        }
    }else
    {
        [SVProgressHUD showErrorWithStatus:@"设备未连接"];
        [SVProgressHUD dismissWithDelay:1];
    }
    NSLog(@"=============upgrate is called================");
}

-(void)sendUpgrateRequest
{
    NSInteger crc32 = [self getCRC32WithData:self.binData];
    NSInteger length = [self.binData length];
    
    
    [self.peripheral writeValue:[Pack packetWithCmdid:CMDID_UPGRATE_REQUEST
                                          dataEnabled:YES
                                                 data:[self combineData:length withCrc32:crc32]]
              forCharacteristic:self.sendCharacteristic
                           type:CBCharacteristicWriteWithoutResponse];
    NSLog(@"=========================send upgrate request is called================");
}

#pragma mark - Private Method
-(uint32_t)getCRC32WithData:(NSData *)pdata
{
    NSLog(@"length = %lu",(unsigned long)[pdata length]);
    //生成码表
    uint crc;
    uint *crc32Table = malloc(sizeof(*crc32Table)*256);;
    for (uint i = 0; i < 256; i++)
    {
        crc = i;
        for (int j = 8; j > 0; j--)
        {
            if ((crc & 1) == 1)
            {
                crc = (crc >> 1) ^ 0xEDB88320;
            }
            else
            {
                crc >>= 1;
            }
        }
        crc32Table[i] = crc;
    }
    
    uint value = 0xffffffff;
    NSUInteger len = [pdata length];
    Byte *data = (Byte *)[pdata bytes];
    
    for (int i = 0; i < len; i++)
    {
        value = (value >> 8) ^ crc32Table[(value & 0xFF)^data[i]];
    }
    return value ^ 0xffffffff;
}
-(NSData *)combineData:(NSUInteger)dataLength withCrc32:(NSUInteger)crc
{
    Byte b1=dataLength & 0xff;
    Byte b2=(dataLength>>8) & 0xff;
    Byte b3=(dataLength>>16) & 0xff;
    Byte b4=(dataLength>>24) & 0xff;
    
    Byte b5=crc & 0xff;
    Byte b6=(crc>>8) & 0xff;
    Byte b7=(crc>>16) & 0xff;
    Byte b8=(crc>>24) & 0xff;
    Byte byte[] = {b1,b2,b3,b4,b5,b6,b7,b8};
    
    NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
    return data;
}
-(NSData*) dataWithByte:(Byte)value {
    NSData *data = [NSData dataWithBytes:&value length:1];
    return data;
}

-(void)showMessageWithTitle:(NSString *)title hideAfterDelay:(BOOL)wantHide {
    if (self.HUD) {
        [self.HUD removeFromSuperview];
    }
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.removeFromSuperViewOnHide = YES;
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.label.text = title;
    self.HUD.minSize = CGSizeMake(217, 60);
    if (wantHide) {
        [self.HUD hideAnimated:YES afterDelay:1.5];
    }
}
-(void)pushNotification {
    
    // 1.创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"";
    content.subtitle = @"";
    content.body = @"你的便携负压设备升级成功";
    content.badge = @1;

    // 2.设置声音
    UNNotificationSound *sound = [UNNotificationSound defaultSound];
    content.sound = sound;
    
    // 3.触发模式
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.05 repeats:NO];
    
    // 4.设置UNNotificationRequest
    NSString *requestIdentifer = @"TestRequest";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:trigger];
    
    //5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    }];
    
}


@end
