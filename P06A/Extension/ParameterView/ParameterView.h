//
//  ParameterView.h
//  P06A
//
//  Created by Binger Zeng on 2018/8/22.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SetReturn)(NSString *);

@interface ParameterView : UIView
@property(nonatomic,copy)SetReturn returnEvent;
@property(nonatomic,assign)NSInteger mode;
+(void)alertControllerAboveIn:(UIViewController *)controller mode:(NSInteger)modeInterger setReturn:(SetReturn)returnEvent;
@end
