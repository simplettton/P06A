//
//  DeviceItemCell.h
//  P06A
//
//  Created by Binger Zeng on 2018/8/29.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *serialNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *hospitalLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;
@end
