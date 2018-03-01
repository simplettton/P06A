//
//  UIWebView+ConverToPDF.m
//  P06A
//
//  Created by Binger Zeng on 2018/3/1.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "UIWebView+ConverToPDF.h"

@implementation UIWebView (ConverToPDF)
- (NSData *)converToPDF{
    
    UIViewPrintFormatter *fmt = [self viewPrintFormatter];
    
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    
    [render addPrintFormatter:fmt startingAtPageAtIndex:0];
    
    CGRect page;
    
    page.origin.x=0;
    
    page.origin.y=0;
    
    page.size.width=600;
    
    page.size.height=768;
    
    CGRect printable=CGRectInset( page, 50, 50 );
    
    [render setValue:[NSValue valueWithCGRect:page] forKey:@"paperRect"];
    
    [render setValue:[NSValue valueWithCGRect:printable] forKey:@"printableRect"];
    
    NSMutableData * pdfData = [NSMutableData data];
    
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
@end
