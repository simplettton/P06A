//
//  FileListView.h
//  UpdateOnline
//
//  Created by Binger Zeng on 2018/6/21.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"
typedef void (^returnBlock)(FileModel *file);
@interface FileListView : UIView<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) returnBlock returnEvent;
@property (weak,   nonatomic) IBOutlet UITableView *tableView;
@property (weak,   nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;
@property (strong, nonatomic) NSMutableArray *fileArray;
+(void)showAboveIn:(UIViewController *)controller withData:(NSMutableArray *)data returnBlock:(returnBlock)returnEvent;
@end
