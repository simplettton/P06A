//
//  ParameterView.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/22.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#define C_Button_Selected_Color 0x85DB95
#define C_Button_UnSelected_Color 0xf8f8f8

#import "ParameterView.h"


@interface ParameterView()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *modeView;
@property (nonatomic,strong)NSNumber* selectedMode;
@end
@implementation ParameterView
-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
}
+(void)alertControllerAboveIn:(UIViewController *)controller mode:(NSInteger)modeInterger setReturn:(SetReturn)returnEvent{
    
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
    
}

- (IBAction)changeMode:(id)sender {
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
