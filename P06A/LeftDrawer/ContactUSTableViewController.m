//
//  ContactUSTableViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/6/27.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ContactUSTableViewController.h"

@interface ContactUSTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *phoneTitle;
@property (weak, nonatomic) IBOutlet UILabel *mailBoxTitle;

@end

@implementation ContactUSTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.title = BEGetStringWithKeyFromTable(@"联系客服", @"P06A");
    self.phoneTitle.text = BEGetStringWithKeyFromTable(@"客服电话", @"P06A");
    self.mailBoxTitle.text = BEGetStringWithKeyFromTable(@"邮箱", @"P06A");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

@end
