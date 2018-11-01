//
//  RecordRepordViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/3/1.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "RecordRepordViewController.h"

@interface RecordRepordViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIWebViewDelegate>
@property (nonatomic, strong) UIImagePickerController *picker;
@property (strong,nonatomic)NSString *HTMLContent;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong,nonatomic)UIImage *image;
- (IBAction)share:(id)sender;

@end

@implementation RecordRepordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = BEGetStringWithKeyFromTable(@"治疗报告", @"P06A");

    
    [self.webView setBackgroundColor:[UIColor clearColor]];
    self.webView.scalesPageToFit = YES;
    [self.webView setOpaque:NO];
    self.webView.delegate = self;

    if (self.hasAlertMessage) {
        [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/Data/ListWarning"]
                                      params:@{
                                                    @"recordid":self.recordId
                                               }
                                    hasToken:YES
                                     success:^(HttpResponse *responseObject) {
                                         if([responseObject.result integerValue] == 1){
                                             NSArray *dataArray = responseObject.content;
                                             if ([dataArray count]>0) {

                                                 NSMutableDictionary *htmlDic = [[NSMutableDictionary alloc]initWithDictionary:self.dic];
                                                 [htmlDic setObject:dataArray forKey:@"alertArray"];

                                                 self.dic = (NSDictionary *)htmlDic;
                                                 //加载html页面
                                                 ReportComposer *reportComposer = [[ReportComposer alloc]init];
                                                 NSString *HTMLContent = [reportComposer renderReportWith:self.dic];

                                                 self.HTMLContent = HTMLContent;
                                                 [self.webView loadHTMLString:HTMLContent baseURL:nil];
                                             }

                                         }else{
                                             [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                         }
                                     }
                                     failure:nil];
    } else {
        //加载html页面
        ReportComposer *reportComposer = [[ReportComposer alloc]init];
        NSString *HTMLContent = [reportComposer renderReportWith:self.dic];
        self.HTMLContent = HTMLContent;
        [self.webView loadHTMLString:HTMLContent baseURL:nil];
    }
    if (self.hasImage) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager] ;
        NSString *token = [UserDefault objectForKey:@"Token"];
        NSString *api = [HTTPServerURLString stringByAppendingString:[NSString stringWithFormat:@"Api/Data/GetImgFromTreatRecord?token=%@&recordid=%@",token,self.recordId]];

        [[manager imageDownloader]downloadImageWithURL:[NSURL URLWithString:api] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {

            float currentProgress = (float)receivedSize/(float)expectedSize;

            [SVProgressHUD showProgress:currentProgress status:BEGetStringWithKeyFromTable(@"正在加载中...", @"P06A")];

        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {

            [SVProgressHUD dismiss];
            if (error) {
                NSLog(@"error = %@",error.localizedDescription);
            }

            if (image) {
                self.image = image;
                [self presentImage:image];
            }else{
                [SVProgressHUD showErrorWithStatus:BEGetStringWithKeyFromTable(@"图片格式错误", @"P06A")];
            }
        }];
    }

    //UIImagePickerController对象调用系统相机或者相册
    self.picker = [[UIImagePickerController alloc]init];
    self.picker.delegate = self;
}

-(void)previewPDFWithHTMLContent:(NSString *)HTMLContent {
    ReportComposer *reportComposer = [[ReportComposer alloc]init];
    NSString *path = [reportComposer exportHTMLContentToPDF:HTMLContent completed:nil];
    NSURL *pdfURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:pdfURL];
    [self.webView loadRequest:request];
}


- (IBAction)save:(id)sender {
    [self savePDF];
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
    [self.webView loadRequest:request];
}
- (IBAction)addPhoto:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //按钮：拍照，类型：UIAlertActionStyleDefault
    [alert addAction:[UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"拍照", @"P06A")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action){
                                                self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                [self presentViewController:self.picker animated:YES completion:nil];
                                                
                                            }]];
    
    //按钮：从相册选择，类型：UIAlertActionStyleDefault
    [alert addAction:[UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"从相册选择", @"P06A")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {

                                                self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

                                                [self presentViewController:self.picker animated:YES completion:nil];
                                            }]];
    
    
    //按钮：取消，类型：UIAlertActionStyleCancel
    [alert addAction:[UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"取消", @"P06A") style:UIAlertActionStyleCancel handler:nil]];
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

- (void)uploadImage:(id)sender {
    if(self.image){
        NSString *token = [UserDefault objectForKey:@"Token"];
        NSString *api = [HTTPServerURLString stringByAppendingString:[NSString stringWithFormat:@"Api/Data/AddImageToTreatRecordAsync?token=%@&recordid=%@",token,self.recordId]];
        
        [[NetWorkTool sharedNetWorkTool]POST:api
                                       image:self.image success:^(HttpResponse *responseObject) {
                                           if ([responseObject.result intValue] == 1) {
                                               [SVProgressHUD showSuccessWithStatus:BEGetStringWithKeyFromTable(@"治疗照片已保存", @"P06A")];
                                           }else{
                                               [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                           }
                                           self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(addPhoto:)];
                                       } failure:nil];
    }
}

#pragma mark - delegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.picker dismissViewControllerAnimated:YES completion:NULL];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    //获取图片
    //取info中编辑后的图
//    UIImage *image = [[info objectForKey:UIImagePickerControllerEditedImage]fixOrientation];
    UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage]fixOrientation];
    //压缩图片为3MB=3*1024*1024*6byte
    self.image = [image compressImageWithMaxLenth:3*1024*1024*8];
    [self.picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        //导航栏按钮改为保存按钮
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:BEGetStringWithKeyFromTable(@"保存", @"P06A") style:UIBarButtonItemStylePlain target:self action:@selector(uploadImage:)];
        [self presentImage:self.image];
    });
}

//页面显示图片
-(void)presentImage:(UIImage *)image{
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.dic];
    [dic setValue:imageData forKey:@"imageData"];
    ReportComposer *reportComposer = [[ReportComposer alloc]init];
    NSString *HTMLContent = [reportComposer renderReportWith:dic];
    self.HTMLContent = HTMLContent;
    [self.webView loadHTMLString:HTMLContent baseURL:nil];
}

- (IBAction)share:(id)sender {
    [self share];
}
@end
