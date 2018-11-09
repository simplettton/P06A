//
//  CustomPrintPageRenderer.m
//  P06A
//
//  Created by Binger Zeng on 2018/3/6.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "CustomPrintPageRenderer.h"

@implementation CustomPrintPageRenderer
-(instancetype)init {
    self = [super init];
    CGFloat A4PageWidth = 600;
//    CGFloat A4PageWidth = 595.2;
    CGFloat A4PageHeight = 612;
//    CGFloat A4PageHeight = 841.8;
    self.footerHeight = 1;
    
    self.headerHeight = 0;
    
    CGRect pageFrame = CGRectMake(0, 0, A4PageWidth, A4PageHeight);
    
    CGRect printable = CGRectInset(pageFrame, 0, 0 );
    
    [self setValue:[NSValue valueWithCGRect:pageFrame] forKey:@"paperRect"];
    
    [self setValue:[NSValue valueWithCGRect:printable] forKey:@"printableRect"];
    
    return self;
}
@end
