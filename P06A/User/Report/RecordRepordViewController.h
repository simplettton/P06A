//
//  RecordRepordViewController.h
//  P06A
//
//  Created by Binger Zeng on 2018/3/1.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordRepordViewController : UIViewController
@property (nonatomic,strong)NSDictionary *dic;
@property (nonatomic,strong)NSString *recordId;
@property (nonatomic,assign)BOOL hasAlertMessage;
@property (nonatomic,assign)BOOL hasImage;
@end
