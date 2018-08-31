//
//  LeftHeaderView.m
//  AirWave
//
//  Created by Macmini on 2017/11/7.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "LeftHeaderView.h"
#import "UIImage+ImageWithColor.h"
#import "BaseHeader.h"

#define tableViewWidth  KScreenWidth - KMainPageDistance

@interface LeftHeaderView()

@end

@implementation LeftHeaderView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame] ;
    if (self) {
        [self addView];
        //背景色
        self.backgroundColor = UIColorFromHex(0X65BBA9);
    }
    return self;
}
//storyboard中加载
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self addView];
//        //背景色
//        self.backgroundColor = UIColorFromHex(0X65BBA9);
    }
    return self;
}
-(void)addView
{
    //加载头像
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50 * KScreenUnit, 130 * KScreenUnit, 100 * KScreenUnit, 100 * KScreenUnit)];
//    headerImageView.layer.cornerRadius = 50 * KScreenUnit;
    
    self.headerImageView.clipsToBounds  = YES;
    [self setRoundHeadPortrait:self.headerImageView];
    if ([UserDefault objectForKey:@"USER_ICON"])
    {
        self.headerImageView.image = [UIImage imageWithData:[UserDefault objectForKey:@"USER_ICON"]];
    }
    else
    {
         self.headerImageView.image = [UIImage imageNamed:@"header"];
    }

    [self addSubview:self.headerImageView];
    //加载昵称
    self.nickNameLabel  = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.headerImageView.frame)+ 40 * KScreenUnit , 150 * KScreenUnit, 300 * KScreenUnit,40 * KScreenUnit)];

    if ([UserDefault objectForKey:@"USER_NAME"]) {
        self.nickNameLabel.text = [NSString stringWithFormat:@"%@",[UserDefault objectForKey:@"USER_NAME"]];
    }else
    {
        self.nickNameLabel.text = @"游客";
    }
    self.nickNameLabel.textColor = [UIColor whiteColor];
    self.nickNameLabel.font = [UIFont systemFontOfSize:35*KScreenUnit];
    [self addSubview:self.nickNameLabel];
    
    //添加点击button
    NSString *identity = [UserDefault objectForKey:@"Identity"];
    
    //判断身份显示不同的界面
    if ([identity isEqualToString:@"admin"]) {
        
    }else{
        self.myInformationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 44, tableViewWidth, 230 * KScreenUnit)];
        self.myInformationButton.tag = 1;
        self.myInformationButton.backgroundColor = [UIColor clearColor];
        [self.myInformationButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBAndAlpha(0Xffffff, 0.3)] forState:UIControlStateHighlighted];
        [self addSubview:self.myInformationButton];
    }

    
    
    //添加二维码button
    self.QRCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(520 * KScreenUnit, 135 * KScreenUnit, 44 * KScreenUnit, 44 * KScreenUnit)];
    [self.QRCodeButton setBackgroundImage:[UIImage imageNamed:@"sidebar_ QRcode_normal"] forState:UIControlStateNormal];
    self.QRCodeButton.tag = 2;
    [self.QRCodeButton setBackgroundImage:[UIImage imageNamed:@"sidebar_ QRcode_press"] forState:UIControlStateHighlighted  ];
    [self addSubview:self.QRCodeButton];
    
    //添加个性签名-图片，文字
    UIImageView * symbolImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50 * KScreenUnit,240 * KScreenUnit , 30 * KScreenUnit, 30 * KScreenUnit)];
    
    symbolImageView.image = [UIImage imageNamed:@"sidebar_signature_nor"];
    [self addSubview:symbolImageView];
    
    UILabel * personalSignature = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(symbolImageView.frame) + 15 * KScreenUnit, 230  * KScreenUnit, 500 * KScreenUnit, 50 * KScreenUnit)];
    personalSignature.font = [UIFont systemFontOfSize:22 * KScreenUnit];
//    personalSignature.text =  @"                    🐑";
    personalSignature.text =  @"                     ";
    personalSignature.textColor = UIColorFromRGBAndAlpha(0x000000, 0.54);
    [self addSubview:personalSignature];
    
    //添加个性签名的button
    self.personalSignatureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 230 * KScreenUnit, tableViewWidth, 50 * KScreenUnit)];
    self.personalSignatureButton.tag = 3;
    self.personalSignatureButton.backgroundColor = [UIColor clearColor];
//    [self.personalSignatureButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBAndAlpha(0xffffff, 0.3)] forState:UIControlStateHighlighted];
    [self addSubview:self.personalSignatureButton];

}
-(void)setRoundHeadPortrait:(UIImageView *)imageView{
    //  把头像设置成圆形
    imageView.layer.cornerRadius=imageView.frame.size.width/2;//裁成圆角
    imageView.layer.masksToBounds=YES;//隐藏裁剪掉的部分
    //  给头像加一个圆形边框
    imageView.layer.borderWidth = 1.5f;//宽度
//    imageView.layer.borderColor = UIColorFromHex(0X65b8f3).CGColor;//颜色
    imageView.layer.borderColor = UIColorFromHex(0Xbbc8f3).CGColor;//颜色
}

@end
