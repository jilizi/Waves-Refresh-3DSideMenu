//
//  QRefreshView.m
//  ReactiveCocoaStudy
//
//  Created by daixunry on 15/5/20.
//  Copyright (c) 2015年 daixu. All rights reserved.
//

#import "QRefreshView.h"
#import "UIConfig.h"

@implementation QRefreshView
{
    CALayer *_parLayer;
    CAShapeLayer *_layerArrow1;
    CAShapeLayer *_layerArc1;
    CAShapeLayer *_layerArrow2;
    CAShapeLayer *_layerArc2;
    
    UIBezierPath *_startArrowPath1;
    UIBezierPath *_startArrowPath2;
    UIBezierPath *_endArrowPath1;
    UIBezierPath *_endArrowPath2;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initLayerAndProperty];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initLayerAndProperty];
    }
    return self;
}

- (void)initLayerAndProperty
{
    self.backgroundColor = [UIColor colorWithRed:34/255.0 green:233/255.0 blue:123/255.0 alpha:1];
    [self setLayers];
    [self setPaths];
}
//设置layer属性
- (void)setLayers
{
    _parLayer = [CALayer layer];
    _parLayer.frame = self.bounds;
    //曲线
    _layerArc1 = [CAShapeLayer layer];
    _layerArc1.fillColor = [UIColor clearColor].CGColor;//封闭图形的填充颜色
    _layerArc1.strokeColor = [UIColor whiteColor].CGColor;//线的颜色
    _layerArc1.lineWidth = 3;//线宽
    _layerArc1.contentsScale = [UIScreen mainScreen].scale;//内容缩放模式
    _layerArc1.lineCap = kCALineCapRound;//绘制线的端点使用的风格（没有端点，方形端点，半圆形端点）

    _layerArc2 = [CAShapeLayer layer];
    _layerArc2.fillColor = [UIColor clearColor].CGColor;
    _layerArc2.strokeColor = [UIColor whiteColor].CGColor;
    _layerArc2.lineWidth = 3;
    _layerArc2.lineCap = kCALineCapRound;
    _layerArc2.contentsScale = [UIScreen mainScreen].scale;
    //箭头
    _layerArrow1 = [CAShapeLayer layer];
    _layerArrow1.fillColor = [UIColor clearColor].CGColor;
    _layerArrow1.strokeColor = [UIColor whiteColor].CGColor;
    _layerArrow1.lineWidth = 3;
    _layerArrow1.lineCap = kCALineCapRound;
    _layerArrow1.contentsScale = [UIScreen mainScreen].scale;

    _layerArrow2 = [CAShapeLayer layer];
    _layerArrow2.fillColor = [UIColor clearColor].CGColor;
    _layerArrow2.strokeColor = [UIColor whiteColor].CGColor;
    _layerArrow2.lineWidth = 3;
    _layerArrow2.lineCap = kCALineCapRound;
    _layerArrow2.contentsScale = [UIScreen mainScreen].scale;
    
    [_parLayer addSublayer:_layerArc1];
    [_parLayer addSublayer:_layerArc2];
    [_parLayer addSublayer:_layerArrow1];
    [_parLayer addSublayer:_layerArrow2];
    [self.layer addSublayer:_parLayer];
}
//绘制图形
- (void)setPaths
{
    //绘制曲线（圆心是视图中心点，0度~157.5度，半径为40，顺时针）
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(UTIL_View_Width(self)/2.0, UTIL_View_Height(self)/2.0) radius:40 startAngle:0 endAngle:M_PI_2*7/4 clockwise:YES];
    _layerArc1.path = path.CGPath;
    //绘制曲线（圆心是视图中心点，180度~337.5度，半径40，顺时针）
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 addArcWithCenter:CGPointMake(UTIL_View_Width(self)/2.0, UTIL_View_Height(self)/2.0) radius:40 startAngle:M_PI endAngle:M_PI*15/8 clockwise:YES];
    _layerArc2.path = path2.CGPath;
    
    //箭尖朝外
    _startArrowPath1 = [UIBezierPath bezierPath];
    [_startArrowPath1 moveToPoint:CGPointMake(80, 54)];
    [_startArrowPath1 addLineToPoint:CGPointMake(90, 50)];//这个点是曲线端点的点
    [_startArrowPath1 addLineToPoint:CGPointMake(99, 56.5)];
    _layerArrow1.path = _startArrowPath1.CGPath;
    
    _startArrowPath2 = [UIBezierPath bezierPath];
    [_startArrowPath2 moveToPoint:CGPointMake(2, 44)];
    [_startArrowPath2 addLineToPoint:CGPointMake(10, 50)];//这个点是曲线端点的点
    [_startArrowPath2 addLineToPoint:CGPointMake(20, 45)];
    _layerArrow2.path = _startArrowPath2.CGPath;
    //箭尖朝内
    _endArrowPath1 = [UIBezierPath bezierPath];
    [_endArrowPath1 moveToPoint:CGPointMake(80, 42.5)];
    [_endArrowPath1 addLineToPoint:CGPointMake(90, 50)];//这个点是曲线端点的点
    [_endArrowPath1 addLineToPoint:CGPointMake(99, 44.5)];

    _endArrowPath2 = [UIBezierPath bezierPath];
    [_endArrowPath2 moveToPoint:CGPointMake(2, 59)];
    [_endArrowPath2 addLineToPoint:CGPointMake(10, 50)];//这个点是曲线端点的点
    [_endArrowPath2 addLineToPoint:CGPointMake(20, 55)];
    
}
//执行动画
- (void)beginAni
{
    //整体绕着Z轴逆时针旋转
    CABasicAnimation *baseAni = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    baseAni.fromValue = @(M_PI*2);
    baseAni.toValue = @(0);
    baseAni.duration = 2;
    baseAni.repeatCount = NSIntegerMax;
    [_parLayer addAnimation:baseAni forKey:@"ro1"];
    
    //几种箭头之间的切换
    CAKeyframeAnimation *aniChangePath1 = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    //设置3个关键帧（其实2个就够）0.45 的时候箭头向内， 0.75 的时候箭头向外， 0.95 的时候箭头向外
    aniChangePath1.values = @[(__bridge id)_startArrowPath1.CGPath,(__bridge id)_endArrowPath1.CGPath,(__bridge id)_endArrowPath1.CGPath];
    aniChangePath1.keyTimes = @[@0.45,@.75,@.95];//关键帧
    aniChangePath1.autoreverses = YES;//动画结束时是否执行逆动画
    aniChangePath1.repeatCount = NSIntegerMax;
    aniChangePath1.duration = 1;
    
    CAKeyframeAnimation *aniChangePath2 = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    aniChangePath2.values = @[(__bridge id)_startArrowPath2.CGPath,(__bridge id)_endArrowPath2.CGPath,(__bridge id)_endArrowPath2.CGPath];
    aniChangePath2.keyTimes = @[@(0.45),@.75,@.95];
    aniChangePath2.autoreverses = YES;
    aniChangePath2.repeatCount = NSIntegerMax;
    aniChangePath2.duration = 1;
    
    [_layerArrow1 addAnimation:aniChangePath1 forKey:@"changePath"];
    [_layerArrow2 addAnimation:aniChangePath2 forKey:@"changePath"];
}

@end
