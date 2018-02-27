//
//  LeftHeaderView.h
//  AirWave
//
//  Created by Macmini on 2017/11/7.
//  Copyright © 2017年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftHeaderView : UIView
@property(nonatomic,strong) UIButton * myInformationButton;
@property(nonatomic,strong) UIButton * personalSignatureButton;
@property(nonatomic,strong) UIButton * QRCodeButton;
@property(nonatomic,strong) UILabel *nickNameLabel;
@property(nonatomic,strong) UIImageView *headerImageView;
@end
