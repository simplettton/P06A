//
//  UIImage+ImageWithColor.h
//  AirWave
//
//  Created by Macmini on 2017/9/7.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(ImageWithColor)
/**
 *  生成的图片的rect默认为100,100
 */
+ (UIImage *)imageWithColor:(UIColor *)color;
+(UIImage *)imageNamed:(NSString *)name withColor:(NSString *)color;
@end
