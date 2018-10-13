//
//  LeftDrawerViewController.h
//  P06A
//
//  Created by Binger Zeng on 2018/1/15.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftHeaderView.h"
@interface LeftDrawerViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet LeftHeaderView *headerView;
-(void)initAll;
@end
