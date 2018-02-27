//
//  TimeSetCell.h
//  P06A
//
//  Created by Binger Zeng on 2018/2/2.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeSetCell : UITableViewCell
@property (assign,nonatomic)NSInteger treatmentMaxTime;
@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
- (IBAction)reduceNumber:(id)sender;
- (IBAction)addNumber:(id)sender;

@end
