//
//  BELanguageTool.h
//  P06A
//
//  Created by Binger Zeng on 2018/9/30.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#define BEGetStringWithKeyFromTable(key,tbl) [[BELanguageTool sharedInstance] getStringForKey:key withTable:tbl]

#import <Foundation/Foundation.h>

@interface BELanguageTool : NSObject

+(id)sharedInstance;


/**
 *  返回table中指定的key的值
 *
 *  @param key key
 *  @param table table
 *
 *  @return 返回table中指定的key的值
 */
-(NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table;


/**
 *  改变当前语言
 */
-(void)changeNowLanguage;


/**
 *  当前语言
 */
-(NSString *)currentLanguage;


/**
 *  设置新的语言
 *
 *  @param language 新语言
 */
-(void)setNewLanguage:(NSString*)language;

@end
