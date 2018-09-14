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
    
    NSString *pathToReportTemplate = [[NSBundle mainBundle]pathForResource:@"report" ofType:@"html"];
    NSString *HTMLContent = [NSString stringWithContentsOfFile:pathToReportTemplate
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];
    NSInteger mode = [[dic objectForKey:@"mode"]intValue];
    NSString *modeString = [[NSString alloc]init];
    switch (mode) {
        case DynamicMode:
            modeString = @"动态模式";
            break;
        case KeepMode:
            modeString = @"连续模式";
            break;
        case IntervalMode:
            modeString = @"间隔模式";
            break;
        default:
            break;
    }
    

    NSString *pressureString = [NSString stringWithFormat:@"-%@mmHg",[dic objectForKey:@"press"]];
    NSString *minutesString = [NSString stringWithFormat:@"%@分钟",[dic objectForKey:@"dur"]];
    NSString *timeStamp = [dic objectForKey:@"date"];
    NSString *dateString = [self stringFromTimeIntervalString:timeStamp dateFormat:@"yyyy/MM/dd HH:mm"];
    NSData *imageData = [dic objectForKey:@"imageData"];
    
    
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#MODE#" withString:modeString];
    
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#PRESSURE#" withString:pressureString];
    
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#DURATION#" withString:minutesString];
    
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#DATE#" withString:dateString];
    
    if (imageData) {
        
        HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#TREAT_IMAGE#" withString:[self htmlForPNGImage:imageData]];
    }

    
    
    //虚拟数据
    NSString *treatArea = [dic objectForKey:@"treatArea"];
    
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#TREAT_AREA#" withString:treatArea == nil?@"小臂":treatArea];
    
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#NAME#" withString:@"JASPER"];
    
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#GENDER#" withString:@"男"];
    
    HTMLContent = [HTMLContent stringByReplacingOccurrencesOfString:@"#AGE#" withString:@"18"];
    
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
#pragma mark - privateMethod
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
@end
