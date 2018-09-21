//
//  NetWorkTool.h
//  P06A
//
//  Created by Binger Zeng on 2018/2/28.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "HttpResponse.h"
@interface NetWorkTool : AFHTTPSessionManager
typedef  void (^HttpSuccessBlock) (id JSON);
typedef  void (^HttpFailureBlock) (NSError *error);
typedef  void (^HttpResponseObject)(HttpResponse* responseObject);

+(instancetype)sharedNetWorkTool;

-(void)POST:(NSString *)address
     params:(id)parameters
   hasToken:(bool)hasToken
    success:(HttpResponseObject)responseBlock
    failure:(HttpFailureBlock)failureBlock;

-(void)DownLoadFile:(NSString *)address
     params:(id)parameters
    success:(HttpResponseObject)responseBlock
    failure:(HttpFailureBlock)failureBlock;

//上传图片
-(void)POST:(NSString *)address
      image:(UIImage *)image
    success:(HttpResponseObject)responseBlock
    failure:(HttpFailureBlock)failureBlock;
@end
