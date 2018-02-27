//
//  EditTableViewController.h
//  AirWave
//
//  Created by Macmini on 2017/11/17.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTableViewController : UITableViewController
@property (nonatomic,copy)void(^returnBlock)(NSInteger,NSString *);
@property (nonatomic,strong)NSString *editKey;
@property (nonatomic,strong)NSString *editValue;
@property (nonatomic,assign)NSInteger selectedRow;
@end
