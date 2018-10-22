//
//  PersonalInfomationViewController.m
//  AirWave
//
//  Created by Macmini on 2017/11/10.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PersonalInfomationViewController.h"
#import "EditTableViewController.h"
#import "PhonenumViewController.h"

@interface PersonalInfomationViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSArray *keys;
}
@property (strong,nonatomic) IBOutletCollection(UITableViewCell)NSArray *cells;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *treatAreaLabel;

@property (weak, nonatomic) IBOutlet UILabel *headImageTitle;
@property (weak, nonatomic) IBOutlet UILabel *nameTitle;
@property (weak, nonatomic) IBOutlet UILabel *genderTitle;
@property (weak, nonatomic) IBOutlet UILabel *ageTitle;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumTitle;
@property (weak, nonatomic) IBOutlet UILabel *addressTitle;
@end

@implementation PersonalInfomationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //界面标题
    self.title = BEGetStringWithKeyFromTable(@"个人信息", @"P06A");
    self.headImageTitle.text = BEGetStringWithKeyFromTable(@"头像", @"P06A");
    self.nameTitle.text = BEGetStringWithKeyFromTable(@"名字", @"P06A");
    self.genderTitle.text = BEGetStringWithKeyFromTable(@"性别", @"P06A");
    self.ageTitle.text = BEGetStringWithKeyFromTable(@"年龄", @"P06A");
    self.phoneNumTitle.text = BEGetStringWithKeyFromTable(@"手机号", @"P06A");
    self.addressTitle.text = BEGetStringWithKeyFromTable(@"地址", @"P06A");
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    //tableview group样式 section之间的高度调整
    self.tableView.sectionHeaderHeight  = 0;
    self.tableView.sectionFooterHeight = 20;
    self.tableView.contentInset = UIEdgeInsetsMake(20 - 35, 0, 0, 0);
    keys = [NSArray arrayWithObjects:@"USER_ICON",@"USER_NAME",@"USER_GENDER",@"AGE",@"TREAT_AREA",@"PHONE_NUMBER",@"ADDRESS", nil];

    
    [self setRoundHeadPortrait:self.headImageView];
    for (int i = 0;i<[keys count];i++)
    {
        UITableViewCell *cell = [self.cells objectAtIndex:i];
        UIView * valueView = [cell viewWithTag:2];
        if([valueView isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)valueView;

            if ([UserDefault objectForKey:keys[i]])
            {
                if ([keys[i]isEqualToString:@"USER_GENDER"]) {  //翻译男或女
                    label.text = BEGetStringWithKeyFromTable([UserDefault objectForKey:@"USER_GENDER"], @"P06A");
                } else {
                    
                    //label支持换行
                    label.numberOfLines = 0;
                    label.lineBreakMode = NSLineBreakByWordWrapping;
                    
                    label.text = [UserDefault objectForKey:keys[i]];
                }
            }
        }
        else if ([valueView isKindOfClass:[UIImageView class]])
        {
            UIImageView *headerImageView = (UIImageView *)valueView;
            if ([UserDefault objectForKey:keys[i]])
            {
                headerImageView.image = [UIImage imageWithData:[UserDefault objectForKey:@"USER_ICON"]];
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
        return 4;
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
    
    //头像
    if (indexPath.section == 0 && indexPath.row == 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        //按钮：拍照，类型：UIAlertActionStyleDefault
        [alert addAction:[UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"拍照", @"P06A")
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
        [alert addAction:[UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"从相册选择", @"P06A")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *pickerImage = [[UIImagePickerController alloc]init];
            pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerImage.allowsEditing = YES;
            pickerImage.delegate = self;
            [self presentViewController:pickerImage animated:YES completion:nil];
        }]];

        
        //按钮：取消，类型：UIAlertActionStyleCancel
        [alert addAction:[UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"取消", @"P06A") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
//    //性别
//    else if (indexPath.section == 0 && indexPath.row == 2){
//        UITableViewCell *cell = [self.cells objectAtIndex:2];
//        UILabel * label = (UILabel *)[cell viewWithTag:2];
//
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//        [alertController addAction:[UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"取消", @"P06A") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//            NSLog(@"点击取消");
//        }]];
//        [alertController addAction:[UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"男", @"P06A") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [UserDefault setObject:@"男" forKey:@"USER_GENDER"];
//            [UserDefault synchronize];
//            label.text = BEGetStringWithKeyFromTable(@"男", @"P06A");
//
//        }]];
//        [alertController addAction:[UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"女", @"P06A") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [UserDefault setObject:@"女" forKey:@"USER_GENDER"];
//            [UserDefault synchronize];
//            label.text = BEGetStringWithKeyFromTable(@"女", @"P06A");
//        }]];
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
//    else if(indexPath.section == 0 && indexPath.row == 4){
//        [self performSegueWithIdentifier:@"EditTreatArea" sender:nil];
//    }
    //手机号
    else if (indexPath.section == 1 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"EditPhoneNumber" sender:indexPath];
    }
//    //其他信息
//    else {
//         [self performSegueWithIdentifier:@"EditInfomation" sender:indexPath];
//    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *newPhoto = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.headImageView.image = newPhoto;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //保存新头像
    NSData *imageData = UIImagePNGRepresentation(newPhoto);

    [UserDefault setObject:imageData forKey:@"USER_ICON"];
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
    }else if([segue.identifier isEqualToString:@"EditPhoneNumber"]) {
        
        PhonenumViewController *vc = (PhonenumViewController *)segue.destinationViewController;
        
        NSIndexPath *index = (NSIndexPath *)sender;
        UITableViewCell *cell;
        if (index.section ==1)
        {
            cell = [self.cells objectAtIndex:index.row+index.section *5];
        } else {
            cell = [self.cells objectAtIndex:index.row];
        }
        UILabel *valueLabel = [cell viewWithTag:2];
        vc.phoneNumber = valueLabel.text;

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
