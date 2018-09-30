//
//  BELanguageTool.m
//  P06A
//
//  Created by Binger Zeng on 2018/9/30.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#define CNS @"zh-Hans-CN"
#define EN @"en"
#define LANGUAGE_SET @"LANGUAGESET"

#import "AppDelegate.h"
#import "BELanguageTool.h"

static BELanguageTool *sharedModel;
@interface BELanguageTool()

@property (nonatomic,strong)NSBundle *bundle;
@property (nonatomic,copy)NSString *language;

@end
@implementation BELanguageTool

+(id)sharedInstance{
    if (!sharedModel) {
        sharedModel = [[BELanguageTool alloc]init];
    }
    return sharedModel;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initLanguage];
    }
    return self;
}

-(void)initLanguage{
    NSString *tmp = [UserDefault objectForKey:LANGUAGE_SET];
    NSString *path;
    //默认是中文
    if (!tmp) {
        tmp = CNS;
    }else{
        tmp = EN;
    }
    self.language = tmp;
    path = [[NSBundle mainBundle]pathForResource:self.language ofType:@"lproj"];
    self.bundle = [NSBundle bundleWithPath:path];
    
}

-(NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table{
    if (self.bundle) {
        return NSLocalizedStringFromTableInBundle(key, table, self.bundle, @"");
    }
    return NSLocalizedStringFromTable(key, table, @"");
}
-(void)changeNowLanguage{
    if ([self.language isEqualToString:EN]) {
        [self setNewLanguage:CNS];
    }else{
        [self setNewLanguage:EN];
    }
}

-(void)setNewLanguage:(NSString *)language{
    if ([language isEqualToString:self.language]) {
        return;
    }
    if ([language isEqualToString:EN]||[language isEqualToString:CNS]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:language ofType:@"lproj"];
        self.bundle = [NSBundle bundleWithPath:path];
    }
    self.language = language;
    [UserDefault setObject:language forKey:LANGUAGE_SET];
    [UserDefault synchronize];
}

@end
