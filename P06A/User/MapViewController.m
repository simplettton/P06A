//
//  MapViewController.m
//  P06A
//
//  Created by Binger Zeng on 2018/6/28.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MapViewController.h"

//map 框架
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface MapViewController ()<MAMapViewDelegate>
@property (weak, nonatomic) IBOutlet MAMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设备位置";
    _mapView.delegate = self;
    [AMapServices sharedServices].enableHTTPS = YES;
    [self addAnnotation];
    //开启定位
//    _mapView.showsUserLocation = YES;
//    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    _mapView.showsCompass= NO;
    _mapView.showsScale= NO;
    //缩放等级
    [_mapView setZoomLevel:14 animated:YES];

}
-(void)addAnnotation{
    
    //创建一个经纬度点
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    //经纬度
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(22.5669700000, 113.9603000000);
    //设置点的经纬度
    pointAnnotation.coordinate = location;
    pointAnnotation.title = @"龙辉花园";
    pointAnnotation.subtitle = @"龙珠大道32路";
    
    [_mapView addAnnotation:pointAnnotation];
    _mapView.centerCoordinate = location;
}
#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude)];
}
//设置标注样式
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    ////判断是否是自己的定位气泡，如果是自己的定位气泡，不做任何设置，显示为蓝点，如果不是自己的定位气泡，比如大头针就会进入
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = NO;        //设置标注可以拖动，默认为NO
//        annotationView.pinColor = MAPinAnnotationColorPurple;
        //设置大头针显示的图片

//        annotationView.image = [UIImage imageNamed:@"point"];
//
//        //点击大头针显示的左边的视图
//
//        UIImageView *imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"backImage"]];
//
//        annotationView.leftCalloutAccessoryView = imageV;
//
//        //点击大头针显示的右边视图
//
//        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
//
//        rightButton.backgroundColor = [UIColor grayColor];
//
//        [rightButton setTitle:@"导航" forState:UIControlStateNormal];
//
//        annotationView.rightCalloutAccessoryView = rightButton;
        
        //        annotationView.image = [UIImage imageNamed:@"redPin"];

        return annotationView;
    }
    return nil;
}
@end
