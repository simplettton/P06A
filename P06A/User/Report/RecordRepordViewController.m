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

@end

@implementation RecordRepordViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = BEGetStringWithKeyFromTable(@"治疗报告", @"P06A");

    
//    shareButton
//    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction
//                                   target:self
//                                   action:@selector(share)
//    ];
//    shareButton.tintColor = [UIColor whiteColor];
//    self.navigationItem.rightBarButtonItems = @[shareButton];
    
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
    }else{
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
    //take photo
    if (!self.picker) {
        self.picker = [[UIImagePickerController alloc]init];
    }
    self.picker.delegate = self;
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
-(void)previewPDFWithHTMLContent:(NSString *)HTMLContent{
    ReportComposer *reportComposer = [[ReportComposer alloc]init];
    NSString *path = [reportComposer exportHTMLContentToPDF:HTMLContent completed:nil];
    NSURL *pdfURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:pdfURL];
    [self.webView loadRequest:request];
}

- (IBAction)test:(id)sender {
    UIImage *image = [UIImage imageNamed:@"checkCodeSuccess"];
    NSString *token = [UserDefault objectForKey:@"Token"];
    NSString *api = [HTTPServerURLString stringByAppendingString:[NSString stringWithFormat:@"Api/Data/AddImageToTreatRecordAsync?token=%@&recordid=%@",token,self.recordId]];
    
    [[NetWorkTool sharedNetWorkTool]POST:api
                                   image:image
                                 success:^(HttpResponse *responseObject) {
                                       if ([responseObject.result intValue] == 1) {
                                           [SVProgressHUD showSuccessWithStatus:@"治疗照片已保存"];
                                       }else{
                                           [SVProgressHUD showErrorWithStatus:responseObject.errorString];
                                       }
                                       self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(addPhoto:)];
                                   }
                                 failure:nil];

    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    //接收类型不一致请替换一致text/html或别的
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
//                                                         @"text/html",
//                                                         @"image/jpeg",
//                                                         @"image/png",
//                                                         @"application/octet-stream",
//                                                         @"text/json",
//                                                         nil];
//
//    NSURLSessionDataTask *task = [manager POST:api parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
//
//        NSData *imageData =UIImageJPEGRepresentation(image,1);
//
//        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//        formatter.dateFormat =@"yyyyMMddHHmmss";
//        NSString *str = [formatter stringFromDate:[NSDate date]];
//        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
//
//        //上传的参数(上传图片，以文件流的格式)
//        [formData appendPartWithFileData:imageData
//                                    name:@"file"
//                                fileName:fileName
//                                mimeType:@"image/jpeg"];
//
//    } progress:^(NSProgress *_Nonnull uploadProgress) {
//        //打印下上传进度
//    } success:^(NSURLSessionDataTask *_Nonnull task,id _Nullable responseObject) {
//
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(addPhoto:)];
//    } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
//        //上传失败
//        NSLog(@"error = %@",error);
//    }];
//    [task resume];

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
                                                /**
                                                 通过相机
                                                 */
                                                UIImagePickerController *PickerImage = [[UIImagePickerController alloc]init];
                                                //获取方式:通过相机
                                                PickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                PickerImage.allowsEditing = YES;
                                                PickerImage.delegate = self;
                                                self.picker = PickerImage;
                                                [self presentViewController:PickerImage animated:YES completion:nil];
                                            }]];
    
    //按钮：从相册选择，类型：UIAlertActionStyleDefault
    [alert addAction:[UIAlertAction actionWithTitle:BEGetStringWithKeyFromTable(@"从相册选择", @"P06A")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                UIImagePickerController *pickerImage = [[UIImagePickerController alloc]init];
                                                pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                pickerImage.allowsEditing = YES;
                                                pickerImage.delegate = self;
                                                self.picker = pickerImage;
                                                [self presentViewController:pickerImage animated:YES completion:nil];
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
    UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage]fixOrientation];
    //压缩图片为3MB=3*1024*1024*6byte
    self.image = [image compressImageWithMaxLenth:3*1024*1024*8];
    [self.picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        //导航栏按钮改为保存按钮
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(uploadImage:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:BEGetStringWithKeyFromTable(@"保存", @"P06A") style:UIBarButtonItemStylePlain target:self action:@selector(uploadImage:)];
        [self presentImage:self.image];
    });
    

//    [reportComposer exportHTMLContentToPDF:HTMLContent completed:^{
//
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/治疗报告.pdf"]];
//    NSURL *pdfURL = [NSURL fileURLWithPath:path];
//    NSURLRequest *request = [NSURLRequest requestWithURL:pdfURL];

//    [self.webView loadRequest:request];
//
//    }];
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

@end
