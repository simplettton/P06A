//
//  UIWebView+ConverToPDF.m
//  P06A
//
//  Created by Binger Zeng on 2018/3/1.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "UIWebView+ConverToPDF.h"
#import "CustomPrintPageRenderer.h"

@implementation UIWebView (ConverToPDF)
- (NSData *)converToPDF {
    
    CGFloat A4PageWidth = 612;
    
    CGFloat A4PageHeight = 792;
    
    UIViewPrintFormatter *fmt = [self viewPrintFormatter];

    CustomPrintPageRenderer *render = [[CustomPrintPageRenderer alloc]init];
    
    [render addPrintFormatter:fmt startingAtPageAtIndex:0];
    
    CGRect page;
    
    page.origin.x = 0;
    
    page.origin.y = 0;
    
    page.size.width = A4PageWidth;
    
    page.size.height = A4PageHeight;
    
    CGRect printable = CGRectInset( page, 0, 0 );
    
    [render setValue:[NSValue valueWithCGRect:page] forKey:@"paperRect"];
    
    [render setValue:[NSValue valueWithCGRect:printable] forKey:@"printableRect"];
    
    NSMutableData * pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData( pdfData, CGRectZero, nil );
    
    for (NSInteger i = 0; i < [render numberOfPages]; i++)
    {
        
        UIGraphicsBeginPDFPage();
        
        CGRect bounds = UIGraphicsGetPDFContextBounds();
        
        [render drawPageAtIndex:i inRect:bounds];
        
    }
    
    UIGraphicsEndPDFContext();
    
    return pdfData;
    
}
@end
