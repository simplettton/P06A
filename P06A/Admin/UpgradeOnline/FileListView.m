//
//  FileListView.m
//  UpdateOnline
//
//  Created by Binger Zeng on 2018/6/21.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "FileListView.h"
#import "FileItemCell.h"
#import "FileModel.h"
#import "Masonry.h"
@interface FileListView()
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong,nonatomic)FileModel *selectedFile;

@end
@implementation FileListView
- (IBAction)close:(id)sender {
    [self removeFromSuperview];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    self.backgroundView.layer.cornerRadius = 5.0f;
    self.titleView.layer.cornerRadius = 5.0f;
    self.contentView.layer.cornerRadius = 5.0f;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self setBorderWithView:self.titleView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0xf4f4f4) borderWidth:1];
    
    [self setNeedsLayout];
}
-(void)layoutIfNeeded{
    //根据数据多少动态改变弹窗大小
//    CGRect frame = self.backgroundView.frame;
//    self.backgroundView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, [self.fileArray count]*80 + 40);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.fileArray count];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    FileItemCell *cell = [tableView.visibleCells objectAtIndex:indexPath.row];
//    for (FileItemCell *cell in tableView.visibleCells) {
//        cell.selectedView.image = [UIImage imageNamed:@"unselected"];
//    }
//    cell.selectedView.image = [UIImage imageNamed:@"selected"];
    
    FileModel *file = [self.fileArray objectAtIndex:indexPath.row];
    self.selectedFile = file;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FileItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FileItemCell"];

    if (!cell) {
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"FileListView" owner:self options:nil];
        cell = (FileItemCell *)array.lastObject;
    }
    //define selected background color
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = UIColorFromHex(0xebebeb);
    FileModel *file = [self.fileArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",file.name,file.showName];
    cell.noteLabel.text = [NSString stringWithFormat:@"版本:%@",file.note];
    cell.timeLabel.text = [self stringFromTimeIntervalString:[NSString stringWithFormat:@"%@",file.updateTime] dateFormat:@"yyyy.MM.dd HH:mm:ss"];
    cell.sizeLabel.text = [self transformedValue:file.size];
    cell.updateButton.tag = indexPath.row;
    [cell.updateButton addTarget:self action:@selector(update:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
-(void)update:(UIButton *)button{
    FileModel *file = [self.fileArray objectAtIndex:[button tag]];
    self.returnEvent(file);
    [self removeFromSuperview];
}
+(void)showAboveIn:(UIViewController *)controller withData:(NSMutableArray *)data returnBlock:(returnBlock)returnEvent{
    FileListView *view = [[NSBundle mainBundle]loadNibNamed:@"FileListView" owner:nil options:nil][0];
    view.frame = CGRectMake(0, 0,kScreenW , kScreenH);
    view.returnEvent = returnEvent;
    view.fileArray = data;
    [controller.view addSubview:view];
    
    [view.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([data count] * 80);
    }];
    [view.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([data count] * 80 + 40 + 30);
    }];
    
    view.backgroundView.alpha = 0;
    
    [UIView animateWithDuration:0.3 delay:0.1 usingSpringWithDamping:1 initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
        view.backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
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
//时间戳字符串转化为日期或时间
- (NSString *)stringFromTimeIntervalString:(NSString *)timeString dateFormat:(NSString*)dateFormat
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone: [NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateFormat];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}
//文件大小转换
- (id)transformedValue:(id)value
{
    
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB", @"ZB", @"YB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}
@end
