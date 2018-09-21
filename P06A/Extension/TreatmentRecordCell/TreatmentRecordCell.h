//
//  TreatmentRecordCell.h
//  P06A
//
//  Created by Binger Zeng on 2018/2/28.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TreatmentRecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *modeImageView;
@property (weak, nonatomic) IBOutlet UILabel *treatAreaLabel;
@property (weak, nonatomic) IBOutlet UIImageView *alertImageView;

@end
