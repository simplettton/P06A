//
//  DeviceListView.m
//  P06A
//
//  Created by Binger Zeng on 2018/8/29.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DeviceListView.h"
#import "DeviceItemCell.h"
@interface DeviceListView()
@property (nonatomic,assign)NSInteger selectedIndex;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic,strong)NSDictionary *selectedData;
@end
@implementation DeviceListView
- (IBAction)cancel:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)confirm:(id)sender {
    
    [self removeFromSuperview];
    self.returnEvent(self.selectedData);
}

-(void)awakeFromNib{
    
    [super awakeFromNib];
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
    self.backgroundView.layer.cornerRadius = 5.0f;
    self.titleView.layer.cornerRadius = 5.0f;
    self.contentView.layer.cornerRadius = 5.0f;
    self.footerView.layer.cornerRadius = 5.0f;
    self.tableView.tableFooterView = [[UIView alloc]init];

    
    [self setNeedsLayout];
}
//-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    NSString *serialNum = [UserDefault objectForKey:@"SerialNum"];
//    for (NSDictionary *dataDic in self.DeviceArray) {
//        if ([serialNum isEqualToString:[dataDic objectForKey:@"serialnum"]]) {
//            NSInteger cellIndex = [self.DeviceArray indexOfObject:dataDic];
//            DeviceItemCell *cell = [[self.tableView visibleCells]objectAtIndex:cellIndex];
//            cell.selectedView.image = [UIImage imageNamed:@"selected"];
//        }
//    }
//    
//}

-(void)layoutIfNeeded{
    //设置按钮边框
    [self setBorderWithView:self.tableView top:YES left:NO bottom:NO right:NO borderColor:UIColorFromHex(0xCDCDCD) borderWidth:1.0f];
}

+(void)showAboveIn:(UIViewController *)controller withData:(NSMutableArray *)data returnBlock:(returnBlock)returnEvent{
    
    DeviceListView *view = [[NSBundle mainBundle]loadNibNamed:@"DeviceListView" owner:nil options:nil][0];
    view.frame = CGRectMake(0, 0, kScreenW, kScreenH);
    view.returnEvent = returnEvent;
    view.DeviceArray = data;
    [controller.view addSubview:view];
    view.backgroundView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0.1 usingSpringWithDamping:1 initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
        view.backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - tableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.DeviceArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DeviceItemCell"];
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"DeviceListView" owner:self options:nil];
        cell = (DeviceItemCell *)array.lastObject;
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = UIColorFromHex(0xebebeb);
    NSDictionary *dataDic = [self.DeviceArray objectAtIndex:indexPath.row];
    cell.serialNumLabel.text = [dataDic objectForKey:@"serialnum"];
    cell.hospitalLabel.text = [dataDic objectForKey:@"from"];
    
    NSString *savedSerialNum = [UserDefault objectForKey:@"SerialNum"];
    if ([[dataDic objectForKey:@"serialnum"]isEqualToString:savedSerialNum]) {
        cell.selectedView.image = [UIImage imageNamed:@"selected"];
        NSDictionary *dataDic = [self.DeviceArray objectAtIndex:indexPath.row];
        self.selectedData = dataDic;
    }else{
        [UIImage imageNamed:@"selected"];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    DeviceItemCell *cell = [tableView.visibleCells objectAtIndex:indexPath.row];
    for (DeviceItemCell *cell in tableView.visibleCells) {
        cell.selectedView.image = [UIImage imageNamed:@"unselected"];
    }
    cell.selectedView.image = [UIImage imageNamed:@"selected"];
    self.selectedIndex = indexPath.row;
    NSDictionary *dataDic = [self.DeviceArray objectAtIndex:indexPath.row];
    self.selectedData = dataDic;
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
@end
