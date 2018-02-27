//
//  UIImage+ImageWithColor.m
//  AirWave
//
//  Created by Macmini on 2017/9/7.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "UIImage+ImageWithColor.h"

@implementation UIImage(ImageWithColor)

+(UIImage *)imageNamed:(NSString *)name withColor:(NSString *)color
{
    UIImage *image = [[UIImage alloc]init];
    NSMutableString *imageName = [[NSMutableString alloc]initWithCapacity:20];
    if (color!=nil)
    {
        [imageName appendFormat:@"%@_%@",name,color];
    }
    else
    {
        [imageName appendFormat:@"%@",name];
    }
    image = [UIImage imageNamed:imageName];
    
    return  image;
}
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGFloat imageW = 3;
    CGFloat imageH = 3;
    // 1.开启基于位图的图形上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageW, imageH), NO, 0.0);
    // 2.画一个color颜色的矩形框
    [color set];
    UIRectFill(CGRectMake(0, 0, imageW, imageH));
    
    // 3.拿到图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 4.关闭上下文
    UIGraphicsEndImageContext();
    
    return image;
}
@end
