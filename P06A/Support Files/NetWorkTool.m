//
//  NetWorkTool.m
//  P06A
//
//  Created by Binger Zeng on 2018/2/28.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "NetWorkTool.h"

@implementation NetWorkTool
static NetWorkTool *_instance;

+(instancetype)sharedNetWorkTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NetWorkTool alloc]initWithBaseURL:nil];
        
        _instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
//
//        _instance.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return _instance;
}
@end
