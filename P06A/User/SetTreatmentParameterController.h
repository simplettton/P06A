//
//  SetTreatmentParameterController.h
//  P06A
//
//  Created by Binger Zeng on 2018/2/2.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"
@interface SetTreatmentParameterController : UITableViewController{
@public
    BabyBluetooth *baby;
}
@property(strong,nonatomic)CBPeripheral *currPeripheral;
@property (strong,nonatomic)CBCharacteristic *sendCharacteristic;
@property (strong,nonatomic)CBCharacteristic *receiveCharacteristic;

@end