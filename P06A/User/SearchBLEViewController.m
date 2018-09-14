//
//  SearchBLEViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/19.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "SearchBLEViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import <MBProgressHUD.h>
typedef NS_ENUM(NSUInteger,ViewTags) {
    nameLableTag         = 1,
    addressLabelTag      = 2,
    RSSILabelTag         = 3,
    BondedDeviceLabelTag = 555
};
@interface SearchBLEViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *peripheralDataArray;
    BabyBluetooth *baby;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)MBProgressHUD * HUD;

@end

@implementation SearchBLEViewController

#pragma mark - ViewControll Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设备绑定";

    peripheralDataArray = [[NSMutableArray alloc]init];
    baby = [BabyBluetooth shareBabyBluetooth];
    [self babyDelegate];
}

- (BOOL)navigationShouldPopOnBackButton {
    [self.navigationController popToRootViewControllerAnimated:YES];
    return NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    baby.scanForPeripherals().begin();
}

#pragma mark - babyDelegate
-(void)babyDelegate {
    __weak typeof(self) weakSelf = self;
    
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        [weakSelf insertTableView:peripheral advertisementData:advertisementData RSSI:RSSI];
    }];
    
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        if (peripheralName.length > 0) {
            return YES;
        }
        return NO;
    }];
    
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}
#pragma mark -UIViewController 方法
//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSArray *peripherals = [peripheralDataArray valueForKey:@"peripheral"];
    if(![peripherals containsObject:peripheral]) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:1];
        [indexPaths addObject:indexPath];
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setValue:peripheral forKey:@"peripheral"];
        [item setValue:RSSI forKey:@"RSSI"];
        [item setValue:advertisementData forKey:@"advertisementData"];
        NSLog(@"peripheral = %@",peripheral.name);
        NSLog(@"advertisementData = %@",advertisementData);
        [peripheralDataArray addObject:item];
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
#pragma mark - tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else {
        return peripheralDataArray.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //我的设备
    if (indexPath.section == 0) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        UILabel *label = [cell viewWithTag:BondedDeviceLabelTag];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if ([userDefault objectForKey:@"MacString"]) {

            label.text = [NSString stringWithFormat:@"蓝牙地址：%@",[userDefault objectForKey:@"MacString"]];
        }else{
            label.text = [NSString stringWithFormat:@"无"];
        }
        cell.selectionStyle
        = UITableViewCellSelectionStyleNone;
        return cell;
    }else{      //其他设备
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OtherDeviceCell"];
        NSDictionary *item = [peripheralDataArray objectAtIndex:indexPath.row];
        CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
        NSDictionary *advertisementData = [item objectForKey:@"advertisementData"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"OtherDeviceCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        //pheripheralName
        NSString *peripheralName;
        if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
            peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
        }else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)){
            peripheralName = peripheral.name;
        }else
        {
            peripheralName = [peripheral.identifier UUIDString];
        }
        
        UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:nameLableTag];
        nameLabel.text = [NSString stringWithFormat:@"%@",peripheralName];
        
        //BLE的mac地址
        UILabel *addressLabel = (UILabel *)[cell.contentView viewWithTag:addressLabelTag];
        NSData *data = (NSData *)[advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:20];
        if (data) {
            Byte *dataByte = (Byte *)[data bytes];
            for (int i =0 ; i < 6; i++) {
                [array addObject:[NSString stringWithFormat:@"%x",dataByte[i]]];
            }
        }
        NSString *mac = [array componentsJoinedByString:@"-"];
        if(!data) {
            addressLabel.text = peripheral.identifier.UUIDString;
        }else {
            addressLabel.text = mac;
        }
        return cell;
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"我的设备";
    } else {
        return @"其他设备";
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NSDictionary *item = [peripheralDataArray objectAtIndex:indexPath.row];
//        CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
        NSDictionary *advertisementData = [item objectForKey:@"advertisementData"];
        NSData *data = (NSData *)[advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
        if (!data) {
            self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.HUD.mode = MBProgressHUDModeText;
            self.HUD.label.text = @"无法获取该设备的mac地址";
            [self.HUD showAnimated:YES];
            [self.HUD hideAnimated:YES afterDelay:1];
        }else {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:20];
            if (data) {
                Byte *dataByte = (Byte *)[data bytes];
                for (int i =0 ; i < 6; i++) {
                    [array addObject:[NSString stringWithFormat:@"%x",dataByte[i]]];
                }
            }
            
            //保存新的绑定设备 mac地址 设备蓝牙名字
//            NSString *peripheralName = peripheral.name;
            NSString *macString = [array componentsJoinedByString:@""];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:macString forKey:@"MacString"];
//            [userDefaults setObject:peripheralName forKey:@"PeripheralName"];
            [userDefaults synchronize];
            
            //获取cpuid并保存
            [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Device/FindCpuidByMac"]
                                          params:@{@"mac":macString}
                                        hasToken:YES
                                         success:^(HttpResponse *responseObject) {
                                            if ([responseObject.result integerValue] == 1) {
                                                NSString *cpuid = [responseObject.content objectForKey:@"cpuid"];
                                                [userDefaults setObject:cpuid forKey:@"Cpuid"];
                                                [userDefaults synchronize];
                                              }
                                            }
                                        failure:nil];
            
            
            //提示框
            self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.HUD.mode = MBProgressHUDModeText;
            self.HUD.label.text = @"绑定成功";
            [self.HUD showAnimated:YES];
            [self.HUD hideAnimated:YES afterDelay:0.5];
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });

            
            //update 我的设备栏
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            UILabel *label = [cell viewWithTag:BondedDeviceLabelTag];
            label.text = [NSString stringWithFormat:@"蓝牙地址：%@",macString];
            
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 60.0;
    }else {
        return 44.0;
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"MacString"]) {
        [self performSegueWithIdentifier:@"ShowMyDevice" sender:nil];

    }else{
        
    }

}
@end
