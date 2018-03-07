//
//  ReportComposer.h
//  P06A
//
//  Created by Binger Zeng on 2018/3/6.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^completeBlock)(void);
@interface ReportComposer : NSObject
-(NSString *)renderReportWith:(NSDictionary *)dic;
-(NSString *) exportHTMLContentToPDF:(NSString *)HTMLContent completed:(completeBlock)completion;
@end
