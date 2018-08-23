//
//  ModeChooseView.h
//  P06A
//
//  Created by Binger Zeng on 2018/1/12.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SlectedReturn) (NSInteger);
@interface ModeChooseView : UIView

@property (nonatomic, copy) SlectedReturn returnEvent;

+(void)alertControllerAboveIn:(UIViewController *)controller selectedReturn:(SlectedReturn)returnEvent;
@end
