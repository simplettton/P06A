//
//  ModeChooseView.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/12.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//


#define KVIEW_H [UIScreen mainScreen].bounds.size.height
#define KVIEW_W [UIScreen mainScreen].bounds.size.width

//typedef NS_ENUM(NSInteger,modeTags) {
//    keepModeTag = 1,intervalModeTag = 2,dynamicModeTag = 3
//};
#import "ModeChooseView.h"

@interface ModeChooseView()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end
@implementation ModeChooseView
-(void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    self.cancelButton.layer.cornerRadius = 5;
}

+(void)alertControllerAboveIn:(UIViewController *)controller selectedReturn:(SlectedReturn)returnEvent {
    ModeChooseView *alert =[[NSBundle mainBundle]loadNibNamed:@"ModeChooseView" owner:nil options:nil][0];
    
    alert.frame = CGRectMake(0, 0, KVIEW_W, KVIEW_H);
    
    alert.returnEvent = returnEvent;
    
    [controller.view addSubview:alert];
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
    
    alert.backgroundView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.2,0.2);
    alert.backgroundView.alpha = 0;
    /**
     *  usingSpringWithDamping：0-1 数值越小，弹簧振动效果越明显
     *  initialSpringVelocity ：数值越大，一开始移动速度越快
     */
    [UIView animateWithDuration:0.3 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
        alert.backgroundView.transform = transform;
        alert.backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];

}
- (IBAction)cancel:(id)sender {
        [self removeFromSuperview];
}
- (IBAction)tapOneMode:(id)sender {
    [self removeFromSuperview];
    switch ([sender tag]) {
        case 1:
            if (self.returnEvent) {
                self.returnEvent(0);
            }
            break;
        case 2:
        if (self.returnEvent) {
            self.returnEvent(1);
        }
            break;
        case 3:
        if (self.returnEvent) {
            self.returnEvent(2);
        }
            break;
            
        default:
            break;
    }
}
@end
