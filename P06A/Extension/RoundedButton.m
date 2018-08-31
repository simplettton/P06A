//
//  RoundedButton.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/31.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "RoundedButton.h"

@implementation RoundedButton

-(void)awakeFromNib{
    [super awakeFromNib];
    
    if ([self.backgroundColor isEqual:[UIColor clearColor]]) {
        [self.layer setBorderColor:UIColorFromHex(0xbbbbbb).CGColor];
    }
    [self.layer setCornerRadius:5.0f];
    [self.layer setMasksToBounds:YES];
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.layer setBorderColor:UIColorFromHex(0xf8f8f8).CGColor];
        [self.layer setCornerRadius:5.0f];
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderWidth:0.5f];
    };
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
