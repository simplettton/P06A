//
//  AdminHomeViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/4.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AdminHomeViewController.h"
#import "AppDelegate.h"
#import "UIViewController+MMDrawerController.h"
#import "LeftDrawerViewController.h"
#import "UIView+Tap.h"

@interface AdminHomeViewController ()
@property (weak, nonatomic) IBOutlet UIView *upgradeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttomConstraint;
- (IBAction)showMenu:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *AddDeviceView;
@property (weak, nonatomic) IBOutlet UIView *accountView;

@end

@implementation AdminHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    [self.AddDeviceView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"AddDevice" sender:nil];
    }];
    [self.upgradeView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"Upgrade" sender:nil];
    }];
    [self.accountView addTapBlock:^(id obj) {

    }];
//    self.buttomConstraint.constant = self.view.bounds.size.height / 667.0 * 133;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:51/255.0f green:157/255.0f blue:231/255.0f alpha:1];
}

- (IBAction)showMenu:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    LeftDrawerViewController *vc = (LeftDrawerViewController  *)self.mm_drawerController.leftDrawerViewController;
    vc.headerView.nickNameLabel.text =[NSString stringWithFormat:@"%@",[userDefault objectForKey:@"USER_NAME"]];
    if ([userDefault objectForKey:@"USER_ICON"])
    {
        UIImage *image=[UIImage imageWithData:[userDefault objectForKey:@"USER_ICON"]];
        vc.headerView.headerImageView.image =image;
    }
}
@end
