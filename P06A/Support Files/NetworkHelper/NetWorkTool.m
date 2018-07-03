//
//  NetWorkTool.m
//  P06A
//
//  Created by Binger Zeng on 2018/2/28.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "NetWorkTool.h"
#import "AppDelegate.h"
#import <SVProgressHUD.h>
@interface NetWorkTool()

@end

@implementation NetWorkTool
static NetWorkTool *_instance;

+(instancetype)sharedNetWorkTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NetWorkTool alloc]initWithBaseURL:nil];
//
//        _instance.requestSerializer = [AFJSONRequestSerializer serializer];
        [_instance.requestSerializer setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];

        //设置请求的超时时间
        [_instance.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        _instance.requestSerializer.timeoutInterval = 3.f;
        [_instance.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        _instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"application/octet-stream", nil];
        
    });
    return _instance;
}

-(void)POST:(NSString *)address
     params:(id)parameters
   hasToken:(bool)hasToken
    success:(HttpResponseObject)responseBlock
    failure:(HttpFailureBlock)failureBlock{
    
    //服务器返回json格式
    _instance.requestSerializer = [AFJSONRequestSerializer serializer];
    _instance.responseSerializer = [AFJSONResponseSerializer serializer];

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSString *token = [userDefault objectForKey:@"Token"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    
    id params;
    
    //通用token data模板
    if( hasToken )
    {
        [param setValue:token forKey:@"token"];

    }
    [param setValue:parameters forKey:@"data"];
    params = [param copy];

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });

    [self POST:address
    parameters:params
      progress:^(NSProgress * _Nonnull uploadProgress) {

      }
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           //请求结果出现后关闭风火轮
           
           dispatch_async(dispatch_get_main_queue(), ^{
               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
           });
 
           NSDictionary *jsonDict = responseObject;
           if (jsonDict != nil) {

               NSString *result = [jsonDict objectForKey:@"result"];
               NSNumber *count = [jsonDict objectForKey:@"count"];
               
               id content;
               //返回null的content
               if ([[jsonDict objectForKey:@"content"]isEqual:[NSNull null]]) {
                   content = nil;
               }else{
                   content = [jsonDict objectForKey:@"content"];
               }
               NSString *errorString = [jsonDict objectForKey:@"msg"];
               
               //token失效
               if ([errorString isEqualToString:@"无法识别的用户"]) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [SVProgressHUD showErrorWithStatus:@"账号验证过期，即将重新登录"];
                    
                   });
               }else{
                   
                   HttpResponse* responseObject = [[HttpResponse alloc]init];
                   responseObject.result = result;
                   responseObject.content = content;
                   responseObject.errorString = errorString;
                   responseObject.count = count;
                   responseBlock(responseObject);
               }

           }
       }
       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           //请求结果出现后关闭风火轮
           dispatch_async(dispatch_get_main_queue(), ^{
               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
           });
           
           if (failureBlock) {
               failureBlock(error);
           }

           dispatch_async(dispatch_get_main_queue(), ^{
               
               if ([error.localizedDescription hasSuffix:@"。"]) {

                   NSString *string = [error.localizedDescription substringToIndex:[error.localizedDescription length] -1];
                     [SVProgressHUD showErrorWithStatus:string];
               }
               else{
                   [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                   NSLog(@"ERROR = %@",error);
               }
           });
       }];
}

-(void)DownLoadFile:(NSString *)address
     params:(id)parameters
    success:(HttpResponseObject)responseBlock
    failure:(HttpFailureBlock)failureBlock{
    
    //服务器返回字节流格式
    _instance.requestSerializer = [AFHTTPRequestSerializer serializer];
    _instance.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    //下载文件
    /*
     第一个参数:请求对象
     第二个参数:progress 进度回调
     第三个参数:destination 回调(目标位置)
     有返回值
     targetPath:临时文件路径
     response:响应头信息
     第四个参数:completionHandler 下载完成后的回调
     filePath:最终的文件路径
     */
    NSURLSessionDownloadTask *download = [self downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        [SVProgressHUD showProgress:(double)downloadProgress.completedUnitCount / downloadProgress.totalUnitCount status:@"正在下载中…"];
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //保存的文件路径
//        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"app.bin"];
         /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if(error){
            if (failureBlock) {
                failureBlock(error);
            }
        }else{
            [SVProgressHUD showSuccessWithStatus:@"下载成功"];
            NSLog(@"%@",filePath);
            HttpResponse *responseObject = [[HttpResponse alloc]init];
            responseObject = (HttpResponse *)response;
            responseBlock(responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        }
    }];
    //执行task
    [download resume];
    
}

@end
