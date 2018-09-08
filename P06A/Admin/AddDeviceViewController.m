//
//  AddDeviceViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/30.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddDeviceViewController.h"
#import "DistributeEquipmentViewController.h"
#import "AddDeviceCell.h"
#import "MJRefresh.h"
#import "RoundedButton.h"
#import <AVFoundation/AVFoundation.h>
#import "QRCodeReaderViewController.h"
#define MIN_BUTTONWIDTH 75
#define TYPE_ITEM_Height 30
#define TYPE_ITEM_INTERVAL 40
@interface AddDeviceViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,QRCodeReaderDelegate >
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic)NSMutableArray *typeArray;
@property (strong,nonatomic)NSString *selectedType;
@property (strong,nonatomic)NSString *cpuid;
@property (strong,nonatomic)NSString *serialNum;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign,nonatomic) NSInteger selectedRow;
@property (weak, nonatomic) IBOutlet UIView *DeviceTypeView;

//条形码扫描
@property (strong,nonatomic) QRCodeReaderViewController *reader;

@end

@implementation AddDeviceViewController{
    NSMutableArray *datas;
    NSMutableArray *registerArray;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设备入库";
    [self initAll];
//    [datas addObject:@{@"cpuid":@"sdklfjeklj"}];
}
-(void)initAll{

    self.tableView.tableFooterView = [[UIView alloc]init];
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    
    [self setBorderWithView:self.DeviceTypeView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0xf4f4f4) borderWidth:2.0f];
    [self getSupportMachineType];
    self.navigationItem.backBarButtonItem =[ [UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
}
- (IBAction)nextStep:(id)sender {
    if ([datas count] == 0) {
        [SVProgressHUD showSuccessWithStatus:@"无可录入设备"];
    }else {
        if (self.cpuid!=nil && self.serialNum!=nil) {
            [self performSegueWithIdentifier:@"DistributeDevice" sender:nil];
        }else{
            [SVProgressHUD showErrorWithStatus:@"请扫描序列号"];
        }
    }
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
                                             [self initTableHeaderAndFooter];
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
//            btn.backgroundColor = UIColorFromHex(0x37bd9c);
            btn.backgroundColor = UIColorFromHex(0x5da9e9);
            
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            btn.backgroundColor = UIColorFromHex(0xf8f8f8);
            [btn setTitleColor:UIColorFromHex(0x212121) forState:UIControlStateNormal];
        }
    }
    [self getNetworkData];
}
#pragma mark - Refresh
-(void)initTableHeaderAndFooter{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getNetworkData)];
    header.stateLabel.textColor =UIColorFromHex(0xABABAB);
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    self.tableView.mj_header = header;
    [self getNetworkData];
}
-(void)getNetworkData{
    datas = [[NSMutableArray alloc]initWithCapacity:20];

    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Device/ActiveList"]
                                  params:@{
                                               @"type":self.selectedType,
                                               @"registered":@0
                                           }
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result integerValue] == 1) {
                                         NSLog(@"newDevice:%@",responseObject.content);
                                         if ([responseObject.content count]>0) {
                                             self.tableView.tableHeaderView.hidden = NO;
                                             
                                             for (NSDictionary *dataDic in responseObject.content) {
                                                 if (![self ->datas containsObject:dataDic]) {
                                                     [self -> datas addObject:dataDic];
                                                 }
                                             }
                                         }else{
                                             self.tableView.tableHeaderView.hidden = YES;
                                         }
                                         [self.tableView reloadData];
                                     }else{
                                         [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                     }
                                 }
                                 failure:nil];
}
-(void)endRefresh{
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}
#pragma mark - Tableview DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [datas count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[AddDeviceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    if ([datas count]>0) {
        self.tableView.tableHeaderView.hidden = NO;
        NSDictionary *dataDic = [datas objectAtIndex:indexPath.row];
        [cell.ringButton setTitle:[dataDic objectForKey:@"cpuid"] forState:UIControlStateNormal];
        [cell.ringButton addTarget:self action:@selector(ring:) forControlEvents:UIControlEventTouchUpInside];
        [cell.scanButton addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.scanButton.tag = indexPath.row;
        
    }else{
        self.tableView.tableHeaderView.hidden = YES;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AddDeviceCell *cell = [tableView.visibleCells objectAtIndex:indexPath.row];
    for (AddDeviceCell *cell in tableView.visibleCells) {
        cell.selectedView.image = [UIImage imageNamed:@"unselected"];
    }
    cell.selectedView.image = [UIImage imageNamed:@"selected"];
    
    self.cpuid = cell.ringButton.titleLabel.text;
    self.serialNum = cell.serialNumTextField.text;
}

#pragma mark - Action
-(void)ring:(UIButton *)sender{
    AddDeviceCell *cell = (AddDeviceCell *)[[sender superview]superview];
    NSString *cpuid = cell.ringButton.titleLabel.text;
    [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Device/Beep"]
                                  params:@{@"type":self.selectedType,
                                           @"cpuid":cpuid
                                           }
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result integerValue] == 1) {
                                         
                                     }else{
                                         [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                     }
                                 }
                                 failure:nil];
    
}
-(void)scanAction:(UIButton *)button{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"相机启用权限未开启"
                                                                       message:[NSString stringWithFormat:@"请在iPhone的“设置”-“隐私”-“相机”功能中，找到“%@”打开相机访问权限",[[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleDisplayName"]]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                  [[UIApplication sharedApplication] openURL:url];
                                                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"]];
                                                              }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    self.selectedRow = [button tag];
    NSArray *types = @[
                       AVMetadataObjectTypeEAN13Code,
                       AVMetadataObjectTypeEAN8Code,
                       AVMetadataObjectTypeUPCECode,
                       AVMetadataObjectTypeCode39Code,
                       AVMetadataObjectTypeCode39Mod43Code,
                       AVMetadataObjectTypeCode93Code,
                       AVMetadataObjectTypeCode128Code,
                       AVMetadataObjectTypePDF417Code];
    _reader = [QRCodeReaderViewController readerWithMetadataObjectTypes:types];
    _reader.delegate = self;
    
    [self presentViewController:_reader animated:YES completion:NULL];
}

#pragma mark - QRCodeReader Delegate Methods
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (![self checkSerailNum:result]) {
            [SVProgressHUD showErrorWithStatus:@"请扫描有效序列号"];
        }else{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
            
            AddDeviceCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.serialNumTextField.text = result;
            
//            AddDeviceCell *cell = [self.tableView.visibleCells objectAtIndex:indexPath.row];
            for (AddDeviceCell *cell in self.tableView.visibleCells) {
                cell.selectedView.image = [UIImage imageNamed:@"unselected"];
            }
            cell.selectedView.image = [UIImage imageNamed:@"selected"];
            
            self.cpuid = cell.ringButton.titleLabel.text;
            self.serialNum = result;
        }
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Private Method
- (BOOL)checkSerailNum:(NSString *)inputString {
    if (inputString.length == 0) return NO;
    NSString *regex =@"^[A-Z]{1}[A-Z0-9]{3}\\d{2}[A-C1-9]{1}[A-Z0-9]{1}\\d{4}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:inputString];
}

- (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width
{
    
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height - width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width - width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"DistributeDevice"]) {
        DistributeEquipmentViewController *vc = (DistributeEquipmentViewController *)segue.destinationViewController;
        vc.cpuid = self.cpuid;
        vc.serialNum = self.serialNum;
    }
}
@end
