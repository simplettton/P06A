//
//  AddDeviceCell.h
//  P06A
//
//  Created by Binger Zeng on 2018/8/31.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddDeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *ringButton;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UITextField *serialNumTextField;
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;
@end
