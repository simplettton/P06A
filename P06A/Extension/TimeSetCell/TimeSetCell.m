//
//  TimeSetCell.m
//  P06A
//
//  Created by Binger Zeng on 2018/2/2.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TimeSetCell.h"
//#define TREATMENT_PARAMETER_MAX_TIME 30
#define TREATMENT_PARAMETER_MIN_TIME 0
@implementation TimeSetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)reduceNumber:(id)sender {
    NSString *value = self.valueLabel.text;
    NSInteger interger = [value integerValue];
    if (interger > TREATMENT_PARAMETER_MIN_TIME) {
        interger --;
        self.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)interger];
    }
}

- (IBAction)addNumber:(id)sender {
    NSString *value = self.valueLabel.text;
    NSInteger interger = [value integerValue];
    if (interger < ((!self.treatmentMaxTime) ? 30:self.treatmentMaxTime)) {
        interger ++;
        self.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)interger];
    }
}
@end
