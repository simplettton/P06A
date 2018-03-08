//
//  EditTreatAreaViewController.h
//  P06A
//
//  Created by Binger Zeng on 2018/3/7.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTreatAreaViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,copy)void(^returnBlock)(NSInteger,NSString *);
@property (nonatomic,strong)NSString *treatArea;
@property (nonatomic,assign)NSInteger selectedRow;
@end
