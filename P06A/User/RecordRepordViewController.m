//
//  RecordRepordViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/3/1.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "RecordRepordViewController.h"
#import "UIWebView+ConverToPDF.h"

@interface RecordRepordViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)save:(id)sender;

@end

@implementation RecordRepordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"治疗报告";
    
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self.webView setOpaque:NO];
    [self.webView loadHTMLString:@"<p style=\"text-align:left;\"><br /></p><p style=\"text-align:center;\"><span style=\"font-size:16px;\">便携负压-</span><span style=\"font-size:16px;\">治疗报告 &nbsp; &nbsp;<span style=\"color:#999999;font-size:10px;\">2017-12-08 15</span><span style=\"color:#999999;font-size:10px;\">：</span><span style=\"color:#999999;font-size:10px;\">07</span></span></p><hr /><p><br /></p><p><br /></p>" baseURL:nil];
}


//点击保存进行调用上面的方法
- (void)savePDF
{
    NSData *data = [_webView converToPDF];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/testFile.pdf"]];
    BOOL result = [data writeToFile:path atomically:YES];
//    [MBProgressHUD hideHUD];
//
//    if (result) {
//        "保存成功"
//    }else{
//        "保存失败";
//    }
    //从本地获取路径进行显示PDF
    NSURL *pdfURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:pdfURL];
    [self.webView setScalesPageToFit:YES];
    [self.webView loadRequest:request];
}

- (IBAction)save:(id)sender {
    [self savePDF];
}
@end
