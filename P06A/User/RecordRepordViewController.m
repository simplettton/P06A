//
//  RecordRepordViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/3/1.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "RecordRepordViewController.h"
#import "UIWebView+ConverToPDF.h"

#import "WXApi.h"
#import "WXApiObject.h"

@interface RecordRepordViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)save:(id)sender;
- (IBAction)uploadPicture:(id)sender;

@end

@implementation RecordRepordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"治疗报告";

    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                   target:self
                                   action:@selector(share)
    ];
    
    
    shareButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = shareButton;
    
    
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self.webView setOpaque:NO];
    [self.webView loadHTMLString:@"<p style=\"text-align:left;\"><br /></p><p style=\"text-align:center;\"><span style=\"font-size:16px;\">便携负压-</span><span style=\"font-size:16px;\">治疗报告 &nbsp; &nbsp;<span style=\"color:#999999;font-size:10px;\">2017-12-08 15</span><span style=\"color:#999999;font-size:10px;\">：</span><span style=\"color:#999999;font-size:10px;\">07</span></span></p><hr /><p><br /></p><p><br /></p>" baseURL:nil];
}


//点击保存进行调用上面的方法
- (void)savePDF
{
    NSData *data = [_webView converToPDF];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/治疗报告.pdf"]];
    BOOL result = [data writeToFile:path atomically:YES];
    if (result) {
        NSLog(@"保存成功");
    }else{
        NSLog(@"保存失败");
    }
    //从本地获取路径进行显示PDF
    NSURL *pdfURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:pdfURL];
    [self.webView setScalesPageToFit:YES];
    [self.webView loadRequest:request];
}

- (IBAction)save:(id)sender {
    [self savePDF];
}

- (IBAction)uploadPicture:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    //按钮：拍照，类型：UIAlertActionStyleDefault
    [alert addAction:[UIAlertAction actionWithTitle:@"打开相机"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action){
                                                /**
                                                 其实和从相册选择一样，只是获取方式不同，前面是通过相册，而现在，我们要通过相机的方式
                                                 */
                                                UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
                                                //获取方式:通过相机
                                                PickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                PickerImage.allowsEditing = YES;
                                                PickerImage.delegate = self;
                                                [self presentViewController:PickerImage animated:YES completion:nil];
                                            }]];
    
    //按钮：从相册选择，类型：UIAlertActionStyleDefault
    [alert addAction:[UIAlertAction actionWithTitle:@"打开相册"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                UIImagePickerController *pickerImage = [[UIImagePickerController alloc]init];
                                                pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                pickerImage.allowsEditing = YES;
                                                pickerImage.delegate = self;
                                                [self presentViewController:pickerImage animated:YES completion:nil];
                                            }]];
    
    
    //按钮：取消，类型：UIAlertActionStyleCancel
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)share {
    WXFileObject *fileObject = [WXFileObject object];
    fileObject.fileData = [self.webView converToPDF];
    fileObject.fileExtension = @"pdf";
    
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.mediaObject = fileObject;
    message.title = @"治疗报告.pdf";
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;// 指定发送到会话
    
    
    [WXApi sendReq:req];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
//    UIImage *result = [info objectForKey:@"UIImagePickerControllerEditedImage"];
//    [self dismissViewControllerAnimated:YES completion:nil];
//
//    NSData *imageData = UIImagePNGRepresentation(result);
}

@end
