//
//  CheckCodeViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/28.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "CheckCodeViewController.h"
#import "CheckCodeResultViewController.h"

@interface CheckCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *checkTitle;
@property (nonatomic,assign)BOOL isSuccess;
@end

@implementation CheckCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = BEGetStringWithKeyFromTable(@"安全检测", @"P06A");
    self.checkTitle.text = BEGetStringWithKeyFromTable(@"正在进行安全检测...", @"P06A");
    self.navigationItem.backBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Users/BindingPhone_CheckAckCode"]
                                  params:@{
                                               @"id":self.codeId,
                                               @"ackcode":self.ackCode
                                           }
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if ([responseObject.result integerValue]==1) {
                                             self.isSuccess = YES;
                                             [UserDefault setObject:self.phoneNumber forKey:@"PHONE_NUMBER"];
                                             [UserDefault synchronize];
                                         }else{
                                             self.isSuccess = NO;
                                         }
                                     [self performSegueWithIdentifier:@"ShowCheckCodeResult" sender:nil];
                                     });

                                     
                                 } failure:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowCheckCodeResult"]) {
        CheckCodeResultViewController *vc = (CheckCodeResultViewController *)segue.destinationViewController;
        vc.isSuccess = self.isSuccess;
    }
}

@end
