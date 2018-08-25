//
//  ParameterView.h
//  P06A
//
//  Created by Binger Zeng on 2018/8/22.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ReturnBlock)(NSDictionary *);
typedef NS_ENUM(NSInteger,modes){
    MODE_KEEP = 0X00,
    MODE_INTERVAL = 0X01,
    MODE_DYNAMIC = 0X02
};
@interface ParameterView : UIView
@property(nonatomic,copy)ReturnBlock returnEvent;
@property(nonatomic,assign)NSInteger mode;

+(void)alertControllerAboveIn:(UIViewController *)controller mode:(NSInteger)modeInterger setReturn:(ReturnBlock)returnEvent;

@end
