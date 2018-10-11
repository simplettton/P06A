//
//  ParameterView.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/22.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#define C_Button_Selected_Color 0x85DB95
#define C_Button_UnSelected_Color 0xf8f8f8
#define MAX_PRESS_VALUE 200
#define MIN_PRESS_VALUE 50
#define EACH_PRESS_STEP 25
#define NUMBER_DISPLAY_LABEL_TAG 22

#define DynamicModeMaxTime 10
#define IntervalModeMaxTime 30

#import "ParameterView.h"

@interface ParameterView()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *modeView;
@property (weak, nonatomic) IBOutlet UILabel *pressLabel;
@property (nonatomic,strong)NSNumber* selectedMode;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;


@property (weak, nonatomic) IBOutlet UILabel *firstTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureSetLabel;

@property (weak, nonatomic) IBOutlet UILabel *firstTimeValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondTimeValueLabel;

@property (weak, nonatomic) IBOutlet UIStackView *firstTimeStack;
@property (weak, nonatomic) IBOutlet UIStackView *secondTimeStack;

@property (weak, nonatomic) IBOutlet UIButton *keepModeButton;
@property (weak, nonatomic) IBOutlet UIButton *intervalModeButton;
@property (weak, nonatomic) IBOutlet UIButton *dynamicModeButton;

@end
@implementation ParameterView
-(void)awakeFromNib{
    [super awakeFromNib];
    [self.cancelButton setTitle:BEGetStringWithKeyFromTable(@"取消", @"P06A") forState:UIControlStateNormal];
    [self.saveButton setTitle:BEGetStringWithKeyFromTable(@"保存", @"P06A") forState:UIControlStateNormal];
    [self.keepModeButton setTitle:BEGetStringWithKeyFromTable(@"连续模式", @"P06A") forState:UIControlStateNormal];
    [self.intervalModeButton setTitle:BEGetStringWithKeyFromTable(@"间隔模式", @"P06A") forState:UIControlStateNormal];
    [self.dynamicModeButton setTitle:BEGetStringWithKeyFromTable(@"动态模式", @"P06A") forState:UIControlStateNormal];
    self.pressureSetLabel.text = [BEGetStringWithKeyFromTable(@"压力设置", @"P06A")stringByAppendingString:@"(-mmHg)"];
    self.keepModeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.intervalModeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.dynamicModeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    self.backgroundView.layer.cornerRadius = 5;

}

+(void)alertControllerAboveIn:(UIViewController *)controller mode:(NSInteger)modeInterger setReturn:(ReturnBlock)returnEvent{
    
    ParameterView *view = [[NSBundle mainBundle]loadNibNamed:@"ParameterView" owner:nil options:nil][0];
    
    view.frame = CGRectMake(0, 0, kScreenW, kScreenH);
    
    view.returnEvent = returnEvent;
    
    view.mode = modeInterger;
    
    [view configureUI];
    
    [controller.view addSubview:view];
    
    view.backgroundView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.2, 0.2);
    
    view.backgroundView.alpha = 0;
    
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
    
    [UIView animateWithDuration:0.3
                          delay:0.1
         usingSpringWithDamping:0.5
          initialSpringVelocity:10
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         view.backgroundView.alpha = 1;
                         view.backgroundView.transform = transform;
                     }
                     completion:nil];
}

-(void)configureUI{
    
    UIButton *btn = [self.modeView viewWithTag:self.mode+1];
    [self changeMode:btn];

}

- (IBAction)changeMode:(id)sender {
    
    self.mode = [sender tag]-1;
    self.selectedMode = [NSNumber numberWithInteger:[sender tag]];
    NSArray *modeTagArray = [NSArray arrayWithObjects:@1,@2,@3,nil];
    for (NSNumber *tag in modeTagArray) {
        UIButton *btn = [self.modeView viewWithTag:[tag integerValue]];
        if ([btn tag] == [sender tag]) {
            btn.backgroundColor = UIColorFromHex(C_Button_Selected_Color);
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            btn.backgroundColor = UIColorFromHex(C_Button_UnSelected_Color);
            [btn setTitleColor:UIColorFromHex(C_Button_Selected_Color) forState:UIControlStateNormal];
        }
    }
    
    //对应治疗模式保存的电压值
    NSArray *savedPressKeys = @[@"KeepPress",@"IntervalPress",@"DynamicPress"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pressString = [defaults objectForKey:savedPressKeys[self.mode]];
    
    self.pressLabel.text = pressString == nil? @"125" :pressString;

    //更换时间参数名称 以及时间参数
    switch (self.mode) {
        case MODE_KEEP:
            
            self.firstTimeStack.hidden = YES;
            self.secondTimeStack.hidden = YES;
            break;
        case MODE_INTERVAL:
            
            self.firstTimeStack.hidden = NO;
            self.secondTimeStack.hidden = NO;
            
            self.firstTimeLabel.text = [BEGetStringWithKeyFromTable(@"工作时间", @"P06A")stringByAppendingString:@"(min)"];
            self.secondTimeLabel.text = [BEGetStringWithKeyFromTable(@"间歇时间", @"P06A")stringByAppendingString:@"(min)"];
            
            if ([UserDefault objectForKey:@"WorkTime"]) {
                self.firstTimeValueLabel.text = [UserDefault objectForKey:@"WorkTime"];
            }
            if ([UserDefault objectForKey:@"IntervalTime"]) {
                self.secondTimeValueLabel.text = [UserDefault objectForKey:@"IntervalTime"];
            }
            
            break;
            
        case MODE_DYNAMIC:

            self.firstTimeStack.hidden = NO;
            self.secondTimeStack.hidden = NO;
            
            self.firstTimeLabel.text = [BEGetStringWithKeyFromTable(@"上升时间", @"P06A")stringByAppendingString:@"(min)"];
            self.secondTimeLabel.text = [BEGetStringWithKeyFromTable(@"下降时间", @"P06A")stringByAppendingString:@"(min)"];
            
            if ([UserDefault objectForKey:@"UpTime"]) {
                self.firstTimeValueLabel.text = [UserDefault objectForKey:@"UpTime"];
            }
            if ([UserDefault objectForKey:@"DownTime"]) {
                
                self.secondTimeValueLabel.text = [UserDefault objectForKey:@"DownTime"];
            }
            
            break;
        default:
            break;
    }
    
}

- (IBAction)cancel:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)save:(id)sender {
    [self removeFromSuperview];
    
    //压力
    NSNumber *press = [NSNumber numberWithInt:[self.pressLabel.text intValue]];
    
    //时间已转换成要发送的字符串
    NSString *firstTime = [self byteStringToHex:self.firstTimeValueLabel.text appendZero:YES];
    NSString *secondTime = [self byteStringToHex:self.secondTimeValueLabel.text appendZero:YES];
    
    //模式
    NSNumber *mode = [NSNumber numberWithInteger:self.mode];
    
    
    NSDictionary *parameterDic = @{
                                   @"mode":mode,
                                   @"press":press,
                                   @"firstTime":firstTime,
                                   @"secondTime":secondTime
                                   };
    self.returnEvent(parameterDic);
}
- (IBAction)addPressNumber:(id)sender {
    UIStackView *stackView = (UIStackView *)[sender superview];
    UILabel *numberLabel = (UILabel *)[stackView viewWithTag:NUMBER_DISPLAY_LABEL_TAG];
    NSInteger number = [numberLabel.text integerValue];
    if (number<200) {
        number += EACH_PRESS_STEP;
    }
    numberLabel.text = [NSString stringWithFormat:@"%ld",(long)number];
}

- (IBAction)reducePressNumber:(id)sender {
    UIStackView *stackView = (UIStackView *)[sender superview];
    UILabel *numberLabel = (UILabel *)[stackView viewWithTag:NUMBER_DISPLAY_LABEL_TAG];
    NSInteger number = [numberLabel.text integerValue];
    if (number > 0) {
        number -= EACH_PRESS_STEP;
    }
    numberLabel.text = [NSString stringWithFormat:@"%ld",(long)number];
}
- (IBAction)reduceTimeNumber:(id)sender {
    
    UIStackView *stackView = (UIStackView *)[sender superview];
    UILabel *numberLabel = (UILabel *)[stackView viewWithTag:NUMBER_DISPLAY_LABEL_TAG];
    NSString *value = numberLabel.text;
    
    NSInteger interger = [value integerValue];
    if (interger > 1) {
        interger --;
        numberLabel.text = [NSString stringWithFormat:@"%ld",(long)interger];
    }
}

- (IBAction)addTimeNumber:(id)sender {
    
    UIStackView *stackView = (UIStackView *)[sender superview];
    UILabel *numberLabel = (UILabel *)[stackView viewWithTag:NUMBER_DISPLAY_LABEL_TAG];
    NSString *value = numberLabel.text;
    
    NSInteger maxTime = 0;
    switch (self.mode) {
        case MODE_KEEP:
            break;
        case MODE_DYNAMIC:
            maxTime = DynamicModeMaxTime;
            break;
        case MODE_INTERVAL:
            maxTime = IntervalModeMaxTime;
            break;
        default:
            break;
    }
    NSInteger interger = [value integerValue];
    if (maxTime != 0) {
        if (interger < maxTime) {
            interger ++;
            numberLabel.text = [NSString stringWithFormat:@"%ld",(long)interger];
        }
    }else{
        return;
    }

}

-(NSString *)byteStringToHex:(NSString *)byteString appendZero:(BOOL)hasZero{

    NSString *hexStr = @"";
    Byte value = [byteString integerValue];
    NSString *newHexStr = [NSString stringWithFormat:@"%x",value&0xFF];
    if([newHexStr length]==1)
        hexStr = [NSString stringWithFormat:@"0%@",newHexStr];
    else
        hexStr = newHexStr;
    if (hasZero) {
        hexStr = [NSString stringWithFormat:@"%@00",hexStr];
    }
    return hexStr;
}

- (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width
{
    
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height - width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width - width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}


@end
