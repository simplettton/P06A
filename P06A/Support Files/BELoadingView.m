//
//  BELoadingView.m
//  loadingAnimation
//
//  Created by Binger Zeng on 2018/10/25.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "BELoadingView.h"

#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha:1]
static bool isOnloding = NO;

@interface BELoadingView()

@property(nonatomic,strong)UILabel *oneLable;
@property(nonatomic,strong)UILabel *twoLable;
@property(nonatomic,strong)UILabel *threeLable;

@property(nonatomic,strong)NSMutableArray *loadViewArray;
@end

@implementation BELoadingView
-(instancetype)initWithFrame:(CGRect)frame {
    
    
    if (self = [super initWithFrame:frame]) {
    
        _loadViewArray = [[NSMutableArray alloc] initWithCapacity:0];
  
        _oneLable = [self createLableWithFrame:CGRectMake(0, 0, 10, 10) adnColor:RGBColor(38, 152, 232)];
        [self addSubview:_oneLable];
        
        
        _twoLable = [self createLableWithFrame:CGRectMake(25, 0, 10, 10) adnColor:RGBColor(38, 152, 232)];
        [self addSubview:_twoLable];
        
        _threeLable = [self createLableWithFrame:CGRectMake(50, 0, 10, 10) adnColor:RGBColor(38, 152, 232)];
        
        [self addSubview:_threeLable];
    }
    
    return self;
    
}

+(void)hideLoadingView:(UIView *)view{
  
    [self removeViewInnView:view];
    
}

+(void)showLoadingViewInView:(UIView *)view{
    
    if (isOnloding) {
        
        return;
    }
  
    isOnloding = YES;
    
    BELoadingView *selfLoad = [[BELoadingView alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    selfLoad.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0);
    
    [view addSubview:selfLoad];
    
    [selfLoad began];
}

+(void)beginAnimation{
  
    UIView *topView = [UIApplication sharedApplication].keyWindow;
    
    [self showLoadingViewInView:topView];
}

+(void)stopAnimation{
  
    UIView *topView = [UIApplication sharedApplication].keyWindow;
    [self removeViewInnView:topView];
}


+(void)removeViewInnView:(UIView *)view{
    
  
    if ([view isKindOfClass:[BELoadingView class]]) {
    
        [UIView animateWithDuration:0.3 animations:^{
            
            view.alpha = 0;
            
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
            
            isOnloding = NO;
            
        }];

        // return;
    }
    
    //  UIScrollView
    
    for (UIView *subviews in view.subviews) {
        if (subviews.subviews.count > 0) {
            
            [self removeViewInnView:subviews];
        }
    }
    
}


-(void)began{
    
    CABasicAnimation *anmation = [self createBasic];
    
    [_oneLable.layer addAnimation:anmation forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        CABasicAnimation *anmation1 = [self createBasic];
        
        [self->_twoLable.layer addAnimation:anmation1 forKey:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            CABasicAnimation *anmation2 = [self createBasic];
            
            [self->_threeLable.layer addAnimation:anmation2 forKey:nil];
          
        });
    });
}

-(CABasicAnimation *)createBasic{
  
    CABasicAnimation *anmation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anmation.autoreverses = YES;
    anmation.duration = 0.6;
    anmation.fromValue = @(0.9);
    anmation.toValue = @(0.3);
    anmation.repeatCount = LONG_LONG_MAX;
    //anmation.repeatDuration = 2;
    anmation.removedOnCompletion = NO;
    anmation.fillMode = kCAFillModeForwards;
    
    return anmation;
}
-(UILabel *)createLableWithFrame:(CGRect)frame adnColor:(UIColor *)color{
  
    UILabel *lable = [[UILabel alloc] initWithFrame:frame];
    lable.backgroundColor = color;
    lable.layer.opacity = 0.9;
    UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:lable.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:lable.bounds.size];
    CAShapeLayer * maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = lable.bounds;
    maskLayer.path = maskPath.CGPath;
    lable.layer.mask = maskLayer;
    
    return lable;
    
}


@end
