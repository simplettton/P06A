//
//  UIImage+WLCompress.h
//  P06A
//
//  Created by Binger Zeng on 2018/9/26.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WLCompress)
//压缩图片到指定大小返回UIImage
-(UIImage *)compressImageWithMaxLenth:(NSUInteger)maxLength;
//压缩图片到指定大小返回NSData
-(NSData *)compressWithMaxLength:(NSUInteger)maxLength;
@end
