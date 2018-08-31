//
//  AddDeviceCell.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/31.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddDeviceCell.h"

@implementation AddDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.ringButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
