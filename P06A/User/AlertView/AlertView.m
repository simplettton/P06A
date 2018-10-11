//
//  AlertView.m
//  P06A
//
//  Created by Binger Zeng on 2018/9/10.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AlertView.h"
@interface AlertView()
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@end
@implementation AlertView
-(void)awakeFromNib{
    [super awakeFromNib];
    [self.okButton setTitle:BEGetStringWithKeyFromTable(@"确认", @"P06A") forState:UIControlStateNormal];
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
}
+(void)showAboveIn:(UIViewController *)controller withData:(NSString *)data{
    AlertView *view = [[NSBundle mainBundle]loadNibNamed:@"AlertView" owner:nil options:nil][0];
    view.frame = CGRectMake(0, 0, kScreenW, kScreenH);
    view.alertMessage = data;
    view.alertMessageLabel.text = data;
    view.alertMessageLabel.adjustsFontSizeToFitWidth = YES;
    [controller.view addSubview:view];
    view.backgroundView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0.1 usingSpringWithDamping:1 initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
        view.backgroundView.alpha = 1;
    } completion:nil];
}
- (IBAction)confirm:(id)sender {
    [self removeFromSuperview];
}

@end
