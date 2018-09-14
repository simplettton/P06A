//
//  AlertView.h
//  P06A
//
//  Created by Binger Zeng on 2018/9/10.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertView : UIView
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UILabel *alertMessageLabel;
@property (strong, nonatomic)NSString *alertMessage;
+(void)showAboveIn:(UIViewController *)controller withData:(NSString *)data;

@end
