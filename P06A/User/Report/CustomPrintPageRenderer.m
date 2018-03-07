//
//  CustomPrintPageRenderer.m
//  P06A
//
//  Created by Binger Zeng on 2018/3/6.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "CustomPrintPageRenderer.h"

@implementation CustomPrintPageRenderer
-(instancetype)init{
    self = [super init];
    CGFloat A4PageWidth = 595.2;
    
    CGFloat A4PageHeight = 841.8;
    
    CGRect pageFrame = CGRectMake(0, 0, A4PageWidth, A4PageWidth);
    
     CGRect printable=CGRectInset(pageFrame, 10, 10 );
    
    [self setValue:[NSValue valueWithCGRect:pageFrame] forKey:@"paperRect"];
    
    [self setValue:[NSValue valueWithCGRect:printable] forKey:@"printableRect"];
    
    return self;
}
@end