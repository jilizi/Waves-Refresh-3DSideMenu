//
//  AniView2-1.m
//  ReactiveCocoaStudy
//
//  Created by daixu on 15/4/29.
//  Copyright (c) 2015年 daixu. All rights reserved.
//

#import "WangYiWave.h"

@implementation WangYiWave
{
    //成员变量
    CADisplayLink *link;
    CGFloat offset;
    CAShapeLayer *layer;
    CAShapeLayer *layer2;
    CGFloat waveWidth;
    CGFloat h;
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
    waveWidth = self.frame.size.width;
    h = 0;
    layer = [CAShapeLayer layer];
    layer.opacity = 0.5;
//    _layer.frame = self.bounds;
    layer.frame = CGRectMake(0, CGRectGetHeight(self.layer.frame)/2, waveWidth, CGRectGetHeight(self.bounds));
    
    layer2 = [CAShapeLayer layer];
//    _layer2.frame = self.bounds;
    layer2.frame = CGRectMake(0, CGRectGetHeight(self.layer.frame)/2, waveWidth, CGRectGetHeight(self.bounds));
    [layer2 setMasksToBounds:NO];
    layer2.opacity = 0.5;
    
    [self.layer addSublayer:layer];
    [self.layer addSublayer:layer2];
}

- (void)wave
{
    link = [CADisplayLink displayLinkWithTarget:self selector:@selector(doAni)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stop
{
    [link invalidate];
    link = nil;
}

- (void)doAni
{
    
    offset += _speed;
//    _offset = 1;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGFloat startY = self.waveHeight*sinf(5*offset*M_PI/waveWidth + M_PI * 3/4);//sin()线的起点
    CGPathMoveToPoint(pathRef, NULL, 0, startY);
    //for循环的最后一个点是sin()线的终点
    for (CGFloat i = 0.0; i < waveWidth; i ++) {
        CGFloat y = 1*self.waveHeight*sinf(2*M_PI*i/waveWidth + 5*offset*M_PI/waveWidth + M_PI * 3/4) + h;
        CGPathAddLineToPoint(pathRef, NULL, i, y);
    }
    //绘制下面两个点构成一个有波浪边的矩形
    CGPathAddLineToPoint(pathRef, NULL, waveWidth, CGRectGetHeight(self.layer.frame)/2);//这个是波浪线终点下面的点
    CGPathAddLineToPoint(pathRef, NULL, 0, CGRectGetHeight(self.layer.frame)/2);//这个是波浪线起点下面的点
    CGPathCloseSubpath(pathRef);//在起点和终点这两个点之间加条直线
    
    layer.path = pathRef;
//    layer.lineWidth = 5;
//    layer.strokeColor = [[UIColor blackColor] CGColor];
//    layer.fillColor = [UIColor clearColor].CGColor;
    layer.fillColor = [UIColor greenColor].CGColor;
    CGPathRelease(pathRef);
    
    
    CGMutablePathRef pathRef2 = CGPathCreateMutable();
    CGFloat startY2 = self.waveHeight*sinf(offset*M_PI/waveWidth + M_PI/4);
    CGPathMoveToPoint(pathRef2, NULL, 0, startY2);
    for (CGFloat i = 0.0; i < waveWidth; i ++) {
        CGFloat y = 1.5*self.waveHeight*sinf(2*M_PI*i/waveWidth + 5*offset*M_PI/waveWidth + M_PI/4) + h;
        
        CGPathAddLineToPoint(pathRef2, NULL, i, y);
    }
    CGPathAddLineToPoint(pathRef2, NULL, waveWidth, CGRectGetHeight(self.layer.frame)/2);//终点
    CGPathAddLineToPoint(pathRef2, NULL, 0, CGRectGetHeight(self.layer.frame)/2);//起始点
    CGPathCloseSubpath(pathRef2);
    
    layer2.path = pathRef2;
    layer2.fillColor = [UIColor orangeColor].CGColor;//设置填充颜色
    CGPathRelease(pathRef2);
    
}


@end
