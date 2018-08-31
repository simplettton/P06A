//
//  DeviceListView.h
//  P06A
//
//  Created by Binger Zeng on 2018/8/29.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^returnBlock)(NSString* serialNum);
@interface DeviceListView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) returnBlock returnEvent;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic,strong) NSMutableArray *DeviceArray;

+(void)showAboveIn:(UIViewController *)controller withData:(NSMutableArray *)data returnBlock:(returnBlock)returnEvent;
@end
