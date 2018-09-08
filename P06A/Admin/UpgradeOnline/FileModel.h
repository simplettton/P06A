//
//  FileModel.h
//  UpdateOnline
//
//  Created by Binger Zeng on 2018/6/22.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//
#import "JSONModel.h"
#import <Foundation/Foundation.h>

@interface FileModel:JSONModel

@property(nonatomic,copy)NSString *projectName;

@property(nonatomic,copy)NSString *showName;

@property(nonatomic,copy)NSString *name;

@property(nonatomic,copy)NSString *key;

@property(nonatomic,copy)NSString *fileId;

@property(nonatomic,copy)NSNumber *version;

@property(nonatomic,copy)NSString *note;

@property(nonatomic,copy)NSString *size;

@property(nonatomic,assign)BOOL isOpen;

@property(nonatomic,strong)NSString *updateTime;

@property(nonatomic,strong)NSDate *time;

@end
