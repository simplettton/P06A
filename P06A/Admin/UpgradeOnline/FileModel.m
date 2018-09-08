//
//  FileModel.m
//  UpdateOnline
//
//  Created by Binger Zeng on 2018/6/22.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "FileModel.h"

@implementation FileModel

//设置所有属性可为null
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"isOpen":@"isopen",
              @"projectName":@"projectname",
              @"showName":@"name",
              @"fileId":@"id",
              @"updateTime":@"time",
              @"name":@"filename"
              }];
}
@end
