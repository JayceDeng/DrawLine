//
//  ViewController.m
//  绘制导航路线
//
//  Created by jayceDeng on 16/10/12.
//  Copyright © 2016年 jayceDeng. All rights reserved.
//

#import "ViewController.h"

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<MKMapViewDelegate>
@property (nonatomic, strong) CLGeocoder *geoC;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ViewController


#pragma mark - 懒加载
- (CLGeocoder *)geoC{
    if (!_geoC) {
        _geoC = [[CLGeocoder alloc]init];
    }
    return _geoC;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.geoC geocodeAddressString:@"广州" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error == nil) {
            //广州地标
            CLPlacemark *gzPL = [placemarks firstObject];
            [self.geoC geocodeAddressString:@"上海" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                if (error == nil) {
                    //上海地标
                    CLPlacemark *shPL = [placemarks firstObject];
                    [self getRouteWithBeginCLPL:gzPL endCLPL:shPL];
                }
            }];
        }
    }];
    
}




- (void)getRouteWithBeginCLPL:(CLPlacemark *)bCLPL endCLPL:(CLPlacemark *)eCLPL{
    //创建一个获取导航数据信息的请求
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    
    //设置起点
    CLPlacemark *beginClPL = bCLPL;
    MKPlacemark *beginmkpl = [[MKPlacemark alloc]initWithPlacemark:beginClPL];
    MKMapItem *beginItem = [[MKMapItem alloc]initWithPlacemark:beginmkpl];
    request.source = beginItem;
    
    //设置终点
    CLPlacemark *endClPL = eCLPL;
    MKPlacemark *endmkpl = [[MKPlacemark alloc]initWithPlacemark:endClPL];
    MKMapItem *endItem = [[MKMapItem alloc]initWithPlacemark:endmkpl];
    
    request.destination = endItem;
    
    
    //创建一个获取导航路线的对象
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    //使用导航路线对象,开始请求,获取导航路线信息数据
    
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"成功获取");
            /**
             * MKDirectionsResponse
             routes :路线数组 <MKRoute>
             
             */
            
            /**
             * MKRoute
             name: 路线名称
             advisoryNotices: 警告信息
             distance: 路线距离
             expectedTravelTime: 预期时间
             transportType: 通行方式
             polyline: 几何路线的数据模型
             steps: 行走的步骤<MKRouteStep>
             */
            
            /**
             * MKRouteStep
             * instructions: 行走提示
             * notice: 警告
             * polyline: 几何路线数据模型
             * distance: 距离
             */
            
            [response.routes enumerateObjectsUsingBlock:^(MKRoute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"路线名称--%@  距离---%f",obj.name,obj.distance);
                
                //获取路线数据模型
                [self.mapView addOverlay:obj.polyline];
                
                
                
                [obj.steps enumerateObjectsUsingBlock:^(MKRouteStep * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSLog(@"%@",obj.instructions);
                }];
            }];
            
        }
    }];
    
    
}


#pragma mark - mapViewDelegate

/**
 当我们添加一个覆盖层数据模型时，地图就会调用这个方法，查找对应的图层渲染层

 @param mapView 地图
 @param overlay 覆盖层的数据模型

 @return 覆盖层的渲染图层
 */
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    NSLog(@"11111");
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc]initWithPolyline:overlay];
    render.lineWidth = 10;
    render.strokeColor = [UIColor redColor];
    return render;
}
@end
