//
//  PressParameterSetView.h
//  P06A
//
//  Created by Binger Zeng on 2018/2/3.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SetReturn)(NSString *);
@interface PressParameterSetView : UIView

@property(nonatomic,copy)SetReturn returnEvent;
@property(nonatomic,assign)NSInteger mode;
@property (weak, nonatomic) IBOutlet UILabel *pressLabel;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
+(void)alertControllerAboveIn:(UIViewController *)controller mode:(NSInteger)modeInterger setReturn:(SetReturn)returnEvent;
@end
