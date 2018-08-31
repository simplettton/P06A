//
//  AddDeviceViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/30.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddDeviceViewController.h"
#import "RoundedButton.h"
#define MIN_BUTTONWIDTH 75
#define TYPE_ITEM_Height 30
#define TYPE_ITEM_INTERVAL 48
@interface AddDeviceViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic)NSMutableArray *typeArray;
@property (strong,nonatomic)NSString *selectedType;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AddDeviceViewController{
    NSMutableArray *datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设备入库";
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    [self getSupportMachineType];
}
- (IBAction)nextStep:(id)sender {
    
}
-(void)getMachineList{
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Device/ActiveList"]
                                  params:@{@"type":self.selectedType,
                                           @"registered":@2
                                           }
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result integerValue] == 1)
                                        {
                                            NSArray *content = responseObject.content;
                                            if (content) {
                                                for (NSDictionary *dic in content)
                                                {
                                                    NSLog(@"device:%@",dic);
                                                    [self->datas addObject:dic];
                                                }
                                                [self.tableView reloadData];
                                            }
                                        }
                                    }
                                 failure:nil];
}
-(void)getSupportMachineType {
    self.typeArray = [NSMutableArray arrayWithCapacity:20];
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Device/GetSupportMachineType"]
                                  params:@{@"":@""}
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result integerValue] == 1) {
                                         NSArray *dataArray = responseObject.content;
                                         if ([dataArray count]>0) {
                                             for (NSString *type in responseObject.content) {
                                                 [self.typeArray addObject:type];
                                             }
                                         }
                                         if ([self.typeArray count]>0) {
                                             self.selectedType = self.typeArray[0];
                                             [self initScrollView];
                                         }
//                                         [self initTableHeaderAndFooter];
                                     }else{
                                         [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                     }
                                 }
                                 failure:nil];
}
-(void)initScrollView {
    if ([self.typeArray count] > 0) {
        
        CGFloat contentsizeWidth = 20;

        for (NSString *type in self.typeArray) {
            CGFloat buttonWidth = [self getButtonWidthWithTitle:type fontSize:15];
            contentsizeWidth += buttonWidth + TYPE_ITEM_INTERVAL;
        }
        self.scrollView.contentSize = CGSizeMake(contentsizeWidth, self.scrollView.bounds.size.height);
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        //设置scrollView 滚动的减速速率
        self.scrollView.decelerationRate = 0.95f;
        
        CGFloat buttonYPositon = self.scrollView.bounds.size.height/2 - TYPE_ITEM_Height/2;
        CGFloat XPostion = 20.0f;
        
        for (int i = 0 ; i < [self.typeArray count]; i++) {
            
            NSString *type = self.typeArray[i];
            CGFloat buttonWidth = [self getButtonWidthWithTitle:type fontSize:15];
            
            RoundedButton *button = [[RoundedButton alloc]initWithFrame:CGRectMake(XPostion, buttonYPositon, buttonWidth, TYPE_ITEM_Height)];
            [button setTitle:type forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            [button setTitleColor:UIColorFromHex(0X212121) forState:UIControlStateNormal];
            [button setBackgroundColor:UIColorFromHex(0xf8f8f8)];
            [button addTarget:self action:@selector(selectDevice:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = 1000 + i;
            
            [self.scrollView addSubview:button];
            
            XPostion = button.frame.origin.x + button.frame.size.width + TYPE_ITEM_INTERVAL;
        }
        RoundedButton *firstButton = [self.scrollView viewWithTag:1000];
        [self selectDevice:firstButton];
    }
}

/**
 * 根据按钮title&font返回按钮长度 这里 MIN_BUTTONWIDTH 设置成75
 */
-(CGFloat)getButtonWidthWithTitle:(NSString *)title fontSize:(CGFloat)size{
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:size]};
    CGFloat length = [title boundingRectWithSize:CGSizeMake(552, 74) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
    CGFloat buttonWidth = MAX(length + 20, MIN_BUTTONWIDTH);
    return buttonWidth;
}
-(void)selectDevice:(UIButton *)sender{
    self.selectedType = self.typeArray[([sender tag]-1000)];
    for (int i = 1000; i< 1000 + [self.typeArray count]; i++) {
        UIButton *btn = (UIButton *)[self.scrollView viewWithTag:i];
        //配置选中按钮
        if ([btn tag] == [(UIButton *)sender tag]) {
            btn.backgroundColor = UIColorFromHex(0x37bd9c);
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            btn.backgroundColor = UIColorFromHex(0xf8f8f8);
            [btn setTitleColor:UIColorFromHex(0x212121) forState:UIControlStateNormal];
        }
    }
}

#pragma mark - tableview dataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [datas count];
}


@end
