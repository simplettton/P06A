//
//  BluetoothCommuticationViewController.h
//  P06A
//
//  Created by Binger Zeng on 2018/1/10.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SVProgressHUD.h"
#import "BabyBluetooth.h"
#import "ModeChooseView.h"
#import "PressParameterSetView.h"
#import "ParameterView.h"
#import "Pack.h"
#import "Unpack.h"
#import "SetTreatmentParameterController.h"

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
    
    CMDID_DEVICE_STATE          = 0X12,
    CMDID_DEVICE_TYPE           = 0XFA,
    CMDID_ALERT_INFORMATION     = 0X0B,
    
    
};
typedef NS_ENUM(NSInteger,Kdata)
{
    DATA_BETTERY_STATE_CHARGE = 0X06,
    
    DATA_TREAT_MODE_KEEP      = 0X00,
    DATA_TREAT_MODE_INTERVAL  = 0X01,
    DATA_TREAT_MODE_DYNAMIC   = 0X02,
    
    STATE_STOP            = 0X00,
    STATE_RUNNING         = 0X01,
    STATE_PAUSE           = 0X02,
    
    WARNING_WASTE_LIQUIDES_IS_FULL = 0X00,
    WARNING_PRESSURE_TOO_HIGH      = 0X01,
    WARNING_PRESSURE_TOO_LOW       = 0X02,
    WARNING_USE_EXPIRATION         = 0X03,
    WARNING_BATTERY_EXCEPTION      = 0X04
    
    
};

@interface BLECommunicationViewController : UIViewController

@end
