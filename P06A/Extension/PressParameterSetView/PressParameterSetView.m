//
//  PressParameterSetView.m
//  P06A
//
//  Created by Binger Zeng on 2018/2/3.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//
#define KVIEW_H [UIScreen mainScreen].bounds.size.height
#define KVIEW_W [UIScreen mainScreen].bounds.size.width
#define MAX_PRESS_VALUE 200
#define MIN_PRESS_VALUE 50
#define EACH_PRESS_STEP 25
#define NUMBER_DISPLAY_LABEL_TAG 22

#import "PressParameterSetView.h"
@interface PressParameterSetView()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end
@implementation PressParameterSetView
-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];

    
}

+(void)alertControllerAboveIn:(UIViewController *)controller mode:(NSInteger)modeInterger setReturn:(SetReturn)returnEvent{
    PressParameterSetView *alert = [[NSBundle mainBundle]loadNibNamed:@"PressParameterSetView" owner:nil options:nil][0];
    
    alert.frame = CGRectMake(0, 0, KVIEW_W, KVIEW_H);
    
    alert.returnEvent = returnEvent;
    
    alert.mode = modeInterger;
    
    [alert configureUI];
    
    [controller.view addSubview:alert];
    
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
    
    alert.backgroundView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.2,0.2);
    alert.backgroundView.alpha = 0;
    /**
     *  usingSpringWithDamping：0-1 数值越小，弹簧振动效果越明显
     *  initialSpringVelocity ：数值越大，一开始移动速度越快
     */
    [UIView animateWithDuration:0.3
                          delay:0.1
         usingSpringWithDamping:0.5
          initialSpringVelocity:10
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            alert.backgroundView.transform = transform;
                            alert.backgroundView.alpha = 1;
                        }
                        completion:^(BOOL finished) {

                     }];
}

- (IBAction)cancel:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)save:(id)sender {
    [self removeFromSuperview];
    
    NSString *hexString = _pressLabel.text;

    self.returnEvent(hexString);
}

- (IBAction)addNumber:(id)sender {
    UIStackView *stackView = (UIStackView *)[sender superview];
    UILabel *numberLabel = (UILabel *)[stackView viewWithTag:NUMBER_DISPLAY_LABEL_TAG];
    NSInteger number = [numberLabel.text integerValue];
    if (number<200) {
        number += EACH_PRESS_STEP;
    }
    numberLabel.text = [NSString stringWithFormat:@"%ld",(long)number];
}

- (IBAction)reduceNumber:(id)sender {
    UIStackView *stackView = (UIStackView *)[sender superview];
    UILabel *numberLabel = (UILabel *)[stackView viewWithTag:NUMBER_DISPLAY_LABEL_TAG];
    NSInteger number = [numberLabel.text integerValue];
    if (number > 0) {
        number -= EACH_PRESS_STEP;
    }
    numberLabel.text = [NSString stringWithFormat:@"%ld",(long)number];
}

-(void)configureUI{
    NSString *modeString = [[NSString alloc]init];
    switch (self.mode) {
        case 0x00:
            modeString = @"连续模式";
            break;
        case 0x01:
            modeString = @"间隔模式";
            break;
        case 0x02:
            modeString = @"动态模式";
            break;
            
        default:
            break;
    }
    //取出对应治疗模式保存的电压值
    NSArray *savedPressKeys = @[@"KeepPress",@"IntervalPress",@"DynamicPress"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pressString = [defaults objectForKey:savedPressKeys[self.mode]];

    
    self.pressLabel.text = pressString == nil? @"125" :pressString;
    self.modeLabel.text = modeString == nil?@"治疗模式":modeString;
    
}


-(NSString *)byteStringToHex:(NSString *)byteString{
    NSString *hexStr = @"";
    Byte value = [byteString integerValue];
    NSString *newHexStr = [NSString stringWithFormat:@"%x",value&0xFF];
    if([newHexStr length]==1)
        hexStr = [NSString stringWithFormat:@"0%@",newHexStr];
    else
        hexStr = newHexStr;
    return hexStr;
}

@end
