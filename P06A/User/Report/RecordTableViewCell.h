//
//  RecordTableViewCell.h
//  P06A
//
//  Created by Binger Zeng on 2018/2/26.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatWayLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@end
