//
//  EditTableViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/17.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "EditTableViewController.h"

@interface EditTableViewController ()<UITextFieldDelegate>
{
    NSArray *items;
}
- (IBAction)save:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *contentTextField;
@end

@implementation EditTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc]init];
    //tableview group样式 section之间的高度调整
    self.tableView.sectionHeaderHeight  = 0;
    self.tableView.sectionFooterHeight = 20;
    self.tableView.contentInset = UIEdgeInsetsMake(20 - 35, 0, 0, 0);
    
    //设置内容
    self.title = [NSString stringWithFormat:@"%@%@",BEGetStringWithKeyFromTable(@"设置", @"P06A"),self.editKey];
    self.navigationItem.rightBarButtonItem.title = BEGetStringWithKeyFromTable(@"保存", @"P06A");
    self.contentTextField.text = self.editValue;
    
    items = [NSArray arrayWithObjects:@"USER_ICON",@"USER_NAME",@"USER_GENDER",@"AGE",@"TREAT_AREA",@"PHONE_NUMBER",@"ADDRESS",nil];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event
{
    
    [self.view endEditing:YES];
    
}
- (IBAction)save:(id)sender
{

    NSString *newValue = self.contentTextField.text;
    [UserDefault setObject: newValue forKey:[items objectAtIndex:self.selectedRow]];
    [UserDefault synchronize];
    [self.navigationController popViewControllerAnimated:YES];
    self.returnBlock(self.selectedRow, self.contentTextField.text);
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
