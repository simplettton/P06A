//
//  AccountCell.h
//  P06A
//
//  Created by Binger Zeng on 2018/9/13.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizationLabel;

@end
