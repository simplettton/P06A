//
//  ReportComposer.m
//  P06A
//
//  Created by Binger Zeng on 2018/3/6.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ReportComposer.h"
#import "CustomPrintPageRenderer.h"
#define KeepMode 0x00
#define IntervalMode 0x01
#define DynamicMode 0x02
@interface ReportComposer()

@end
@implementation ReportComposer

-(NSString *)renderReportWith:(NSDictionary *)dic{

    NSString *pathToReportTemplate = [[NSString alloc]init];
    if ([[[BELanguageTool sharedInstance]currentLanguage]isEqualToString:@"en"]) {
        pathToReportTemplate = [[NSBundle mainBundle]pathForResource:@"report(en)" ofType:@"html"];
    }else{
        pathToReportTemplate = [[NSBundle mainBundle]pathForResource:@"report" ofType:@"html"];
    }
    NSString *HTMLContent = [NSString stringWithContentsOfFile:pathToReportTemplate
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];
    NSInteger mode = [[dic objectForKey:@"mode"]intValue];
    NSString *modeString = [[NSString alloc]init];
    switch (mode) {
        case DynamicMode:
        {
            modeString = BEGetStringWithKeyFromTable(@"MQTT动态模式", @"P06A");
            //生成一行显示时间设置
            NSString *timeSetHtmlString = [NSString stringWithFormat:@"<tr><th>上升时间</th><th>下降时间</th></tr><tr><td>%@分钟</td><td>%@分钟</td></tr>",dic[@"uptime"],dic[@"downtime"]];
            HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#OTHERPARAMETER#" withString:timeSetHtmlString];
            break;
        }
        case KeepMode:
            modeString = BEGetStringWithKeyFromTable(@"MQTT连续模式", @"P06A");
            HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#OTHERPARAMETER#" withString:@""];
            break;
        case IntervalMode:
        {
            modeString = BEGetStringWithKeyFromTable(@"MQTT间隔模式", @"P06A");
            //生成一行显示时间设置
            NSString *timeSetHtmlString = [NSString stringWithFormat:@"<tr><th>工作时间</th><th>间歇时间</th></tr><tr><td>%@分钟</td><td>%@分钟</td></tr>",dic[@"worktime"],dic[@"resttime"]];
            HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#OTHERPARAMETER#" withString:timeSetHtmlString];
            break;
        }
        default:
            break;
    }

    NSString *pressureString = [NSString stringWithFormat:@"-%@mmHg",[dic objectForKey:@"press"]];
    NSString *minutesString = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"duration"],BEGetStringWithKeyFromTable(@"分钟", @"P06A")];
    NSString *timeStamp = [dic objectForKey:@"time"];
    NSString *dateString = [self stringFromTimeIntervalString:timeStamp dateFormat:@"yyyy/MM/dd HH:mm"];
    NSData *imageData = [dic objectForKey:@"imageData"];
    NSArray *alertArray = [dic objectForKey:@"alertArray"];

    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#MODE#" withString:modeString];
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#PRESSURE#" withString:pressureString];
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#DURATION#" withString:minutesString];
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#DATE#" withString:dateString];
    
    if (imageData) {
        HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#TREAT_IMAGE#" withString:[self htmlForPNGImage:imageData]];
    }
    if ([alertArray count] > 0) {
        HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#AlertMessage#" withString:[self alertStringHTML:alertArray]];
    }else{
        HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#AlertMessage#" withString:BEGetStringWithKeyFromTable(@"无", @"P06A")];
    }

    //患者数据
    NSString *treatArea = [dic objectForKey:@"parts"];
    NSString *name = [UserDefault objectForKey:@"USER_NAME"];
    NSString *gender = [UserDefault objectForKey:@"USER_GENDER"];
    NSString *age = [UserDefault objectForKey:@"AGE"];
    
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#TREAT_AREA#" withString:treatArea == nil?BEGetStringWithKeyFromTable(@"未知", @"P06A"):treatArea];
    
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#NAME#" withString:name];
    
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#GENDER#" withString:BEGetStringWithKeyFromTable(gender, @"P06A")];
    
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#AGE#" withString:age];
    
    return HTMLContent;
}

-(NSString *) exportHTMLContentToPDF:(NSString *)HTMLContent completed:(completeBlock)completion{
    
    
    CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
    
    UIMarkupTextPrintFormatter *fmt = [[UIMarkupTextPrintFormatter alloc]initWithMarkupText:HTMLContent];
    
    [printPageRenderer addPrintFormatter:fmt startingAtPageAtIndex:0];
    
    NSData *data = [self drawPDFUsingPrintRenderer:printPageRenderer];
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/治疗报告.pdf"]];
    
    BOOL result = [data writeToFile:path atomically:YES];
    if (result) {
        NSLog(@"保存成功");
        if (completion) {
            completion();
        }
    }else{
        NSLog(@"保存失败");
    }
    
    return path;
    
}

-(NSData *)drawPDFUsingPrintRenderer:(UIPrintPageRenderer *)render{
    
    NSMutableData *pdfData = [[NSMutableData alloc]initWithCapacity:20];
    
    UIGraphicsBeginPDFContextToData( pdfData, CGRectZero, nil );
    
    for (NSInteger i=0; i < [render numberOfPages]; i++)
        
    {
        
        UIGraphicsBeginPDFPage();
        
        CGRect bounds = UIGraphicsGetPDFContextBounds();
        
        [render drawPageAtIndex:i inRect:bounds];
        
    }
    
    UIGraphicsEndPDFContext();
    
    return pdfData;
    
}

#pragma mark - Private Method
//时间戳字符串转化为日期或时间
- (NSString *)stringFromTimeIntervalString:(NSString *)timeString dateFormat:(NSString*)dateFormat
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateFormat];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}
- (NSString *)htmlForPNGImage:(NSData *)imageData
{
    NSString *imageSource = [NSString stringWithFormat:@"data:image/png;base64,%@",[imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]];
    return imageSource;
}
-(NSString *)alertStringHTML:(NSArray *)alertMessageArray{
    NSMutableString *html = [[NSMutableString alloc]initWithCapacity:20];
    
    for (NSDictionary *dataDic in alertMessageArray) {
        
        NSString *timeStamp = [dataDic objectForKey:@"time"];
        
        NSString *dateString = [self stringFromTimeIntervalString:timeStamp dateFormat:@"yyyy/MM/dd HH:mm"];
        
        //显示警告信息（模板：时间  警告信息）
        [html appendFormat:@"<tr><td>%@    %@</td></tr>",dateString,dataDic[@"warnning"]];
    }
    return html;
}
//时间戳字符串转化为日期或时间

@end
