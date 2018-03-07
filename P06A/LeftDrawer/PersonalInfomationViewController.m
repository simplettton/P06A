//
//  PersonalInfomationViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/10.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PersonalInfomationViewController.h"
#import "EditTableViewController.h"
#import "BaseHeader.h"
@interface PersonalInfomationViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSArray *keys;
}
@property (strong,nonatomic) IBOutletCollection(UITableViewCell)NSArray *cells;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@end

@implementation PersonalInfomationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
    //tableview group样式 section之间的高度调整
    self.tableView.sectionHeaderHeight  = 0;
    self.tableView.sectionFooterHeight = 20;
    self.tableView.contentInset = UIEdgeInsetsMake(20 - 35, 0, 0, 0);
    keys = [NSArray arrayWithObjects:@"USER_ICON",@"USER_NAME",@"USER_SEX",@"age",@"phoneNumber",@"address", nil];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [self setRoundHeadPortrait:self.headImageView];
    for (int i = 0;i<[keys count];i++)
    {
        UITableViewCell *cell = [self.cells objectAtIndex:i];
        UIView * valueView = [cell viewWithTag:2];
        if([valueView isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)valueView;

            if ([userDefault objectForKey:keys[i]])
            {
                label.text = [userDefault objectForKey:keys[i]];
            }
        }
        else if ([valueView isKindOfClass:[UIImageView class]])
        {
            UIImageView *headerImageView = (UIImageView *)valueView;
            if ([userDefault objectForKey:keys[i]])
            {
                headerImageView.image = [UIImage imageWithData:[userDefault objectForKey:@"USER_ICON"]];
            }
        }
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //导航栏
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"个人信息";
    
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0X65B8F3);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [[self.navigationController navigationBar]setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0XFFFFFF)}];
    self.navigationItem.rightBarButtonItem.tintColor = UIColorFromHex(0xFFFFFF);
    self.navigationItem.leftBarButtonItem.tintColor = UIColorFromHex(0xFFFFFF);
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 5;
    }
    else if(section == 1)
    {
        return 2;
    }
    else
    {
        return 0;
    }
}
#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        //按钮：拍照，类型：UIAlertActionStyleDefault
        [alert addAction:[UIAlertAction actionWithTitle:@"拍照"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action){
            /**
             其实和从相册选择一样，只是获取方式不同，前面是通过相册，而现在，我们要通过相机的方式
             */
            UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
            //获取方式:通过相机
            PickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
            PickerImage.allowsEditing = YES;
            PickerImage.delegate = self;
            [self presentViewController:PickerImage animated:YES completion:nil];
        }]];
        
        //按钮：从相册选择，类型：UIAlertActionStyleDefault
        [alert addAction:[UIAlertAction actionWithTitle:@"从相册选择"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *pickerImage = [[UIImagePickerController alloc]init];
            pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerImage.allowsEditing = YES;
            pickerImage.delegate = self;
            [self presentViewController:pickerImage animated:YES completion:nil];
        }]];

        
        //按钮：取消，类型：UIAlertActionStyleCancel
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else if (indexPath.section == 0 && indexPath.row == 2){
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        UITableViewCell *cell = [self.cells objectAtIndex:2];
        UILabel * label = (UILabel *)[cell viewWithTag:2];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            NSLog(@"点击取消");
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [userDefault setObject:@"男" forKey:@"USER_SEX"];
            [userDefault synchronize];
            label.text = @"男";
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [userDefault setObject:@"女" forKey:@"USER_SEX"];
            [userDefault synchronize];
            label.text = @"女";
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if(indexPath.section == 1 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"EditTreatArea" sender:nil];
    }
    else if (( indexPath.section == 0 && indexPath.row != 0)||(indexPath.section == 1 && indexPath.row ==1)){
         [self performSegueWithIdentifier:@"EditInfomation" sender:indexPath];
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *newPhoto = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.headImageView.image = newPhoto;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //保存新头像
    NSData *imageData = UIImagePNGRepresentation(newPhoto);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:imageData forKey:@"USER_ICON"];
}
#pragma mark - prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditInfomation"])
    {
        EditTableViewController *vc = (EditTableViewController *)segue.destinationViewController;
        
        NSIndexPath *index = (NSIndexPath *)sender;
        UITableViewCell *cell;
        if (index.section ==1)
        {
            cell = [self.cells objectAtIndex:index.row+index.section *5];
        }else
        {
            cell = [self.cells objectAtIndex:index.row];
        }

        UILabel *keyLabel = [cell viewWithTag:1];
        UILabel *valueLabel = [cell viewWithTag:2];
        vc.editKey =keyLabel.text;
        vc.editValue = valueLabel.text;
        vc.selectedRow = index.section *5 + index.row;
        vc.returnBlock = ^(NSInteger changedRow,NSString *newValue)
        {
            UITableViewCell *cell = [self.cells objectAtIndex:changedRow];
            UIView * valueView = [cell viewWithTag:2];
            if([valueView isKindOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel *)valueView;

                label.text = newValue;
            }
        };
    }
}
#pragma mark - private method
-(void)setRoundHeadPortrait:(UIImageView *)imageView{
    //  把头像设置成圆形
    imageView.layer.cornerRadius=imageView.frame.size.width/2;//裁成圆角
    imageView.layer.masksToBounds=YES;//隐藏裁剪掉的部分
    //  给头像加一个圆形边框
    imageView.layer.borderWidth = 1.5f;//宽度
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;//颜色
}
@end
