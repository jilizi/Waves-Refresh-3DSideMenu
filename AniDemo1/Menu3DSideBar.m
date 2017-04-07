//
//  Menu3DSideBar.m
//  ReactiveCocoaStudy
//
//  Created by daixu on 15/6/1.
//  Copyright (c) 2015年 daixu. All rights reserved.
//

#import "Menu3DSideBar.h"

@implementation Menu3DSideBar
{
    UIView *_containView;
    UIView *_containHelperView;
    BOOL _open;
    CGFloat _rota;
    CAGradientLayer *_gradLayer;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //侧边栏视图
        _containView = [[UIView alloc] initWithFrame:CGRectMake(50, 64, frame.size.width, frame.size.height - 64)];
        //辅助视图
        _containHelperView = [[UIView alloc] initWithFrame:CGRectMake(50, 64, frame.size.width, frame.size.height - 64)];
        [self addSubview:_containView];
        [_containView setBackgroundColor:[UIColor orangeColor]];
        //颜色渐变图层
        _gradLayer = [CAGradientLayer layer];
        _gradLayer.frame = _containView.bounds;
        _gradLayer.colors = @[(id)[[UIColor clearColor] CGColor],(id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor]];
        _gradLayer.startPoint = CGPointMake(0, 0.5);
        _gradLayer.endPoint = CGPointMake(1,0.5);
        _gradLayer.locations = @[@(0.2),@(1)];
        [_containView.layer addSublayer:_gradLayer];
        
        self.backgroundColor = [UIColor blackColor];
        
        [self setInitTrans];
    }
    return self;
}
//初始位置变换
- (void)setInitTrans
{
    CATransform3D tran = CATransform3DIdentity;
    //m34 = -1/z中，当z为正的时候，是我们人眼观察现实世界的效果，即在投影平面上表现出近大远小的效果，z越靠近原点则这种效果越明显，越远离原点则越来越不明显，当z为正无穷大的时候，则失去了近大远小的效果，此时投影线垂直于投影平面，也就是视点在无穷远处，CATransform3D中m34的默认值为0，即视点在无穷远处.
    tran.m34 = -1/500.0;
    
    //contaTran沿Y轴翻转是在tran的基础之上
    CATransform3D contaTran = CATransform3DRotate(tran,-M_PI_2, 0, 1, 0);//围绕Y轴,向屏幕内部旋转90度
    //初始的位置是被折叠起来的，也就是上面的contaTran变换是沿着右侧翻转过去，但是我们需要翻转之后的位置是贴着屏幕左侧，于是需要一个位移
    CATransform3D contaTran2 = CATransform3DMakeTranslation(-self.frame.size.width, 0, 0);//X轴 向X轴负方向移动
    
    //锚点 变换时不变的点
    _containView.layer.anchorPoint = CGPointMake(1, 0.5);
    //两个变换的叠加
    _containView.layer.transform = CATransform3DConcat(contaTran, contaTran2);
    
    _containHelperView.layer.anchorPoint = CGPointMake(1, 0.5);
    _containHelperView.layer.transform = contaTran;//辅助视图应用Y轴旋转变换
}
//rota 范围是（0~3.1415926/2）
- (CGFloat)setRota:(CGFloat)rota
{
    CATransform3D tran = CATransform3DIdentity;
    tran.m34 = -1/500.0;
    
    if (_open == NO) {
        //变换角度的限制
        if (rota <= 0) {
            rota = 0;
        }
        if (rota > M_PI_2) {
            rota = M_PI_2;
        }
        _rota = rota;
        
        self.cshowMenuView.transform = CGAffineTransformMakeRotation(rota);
        //阴影图层
        _gradLayer.colors = @[(id)[[UIColor clearColor] CGColor],(id)[[[UIColor blackColor] colorWithAlphaComponent:((0.5-rota/2.0)>0)?0.5-rota/2.0:0] CGColor]];
        //翻转矩阵
        CATransform3D contaTran = CATransform3DRotate(tran,-M_PI_2 + rota, 0, 1, 0);
        //先应用到辅助视图上面 辅助视图旋转只是为了在旋转的啥时候获得其宽度，从而计算出需要向右移动的距离
        _containHelperView.layer.transform = contaTran;
        //根据辅助视图计算sidebar需要的位移矩阵
        CATransform3D contaTran2 = CATransform3DMakeTranslation(-(self.frame.size.width - _containHelperView.frame.size.width), 0, 0);
        //两个变换的叠加
        _containView.layer.transform = CATransform3DConcat(contaTran, contaTran2);
        
        
        self.containerView.transform = CGAffineTransformMakeTranslation(_containHelperView.frame.size.width, 0);
        
        NSLog(@"x:%f,y:%f,w:%f,H:%f,rota:%f",_containView.frame.origin.x,_containView.frame.origin.y,_containView.frame.size.width,_containView.frame.size.height,rota);
        return _containHelperView.frame.size.width;
    }
    if (_open == YES) {
        if (rota >= 0) {
            rota = 0;
        }
        if (rota < -M_PI_2) {
            rota = -M_PI_2;
        }
        _rota = rota;
        self.cshowMenuView.transform = CGAffineTransformMakeRotation(M_PI_2+rota);
        _gradLayer.colors = @[(id)[[UIColor clearColor] CGColor],(id)[[[UIColor blackColor] colorWithAlphaComponent:((-rota/2.0)<0.5)?-rota/2.0:0.5] CGColor]];
        
        CATransform3D contaTran = CATransform3DRotate(tran, rota, 0, 1, 0);
        _containHelperView.layer.transform = contaTran;
        CATransform3D contaTran2 = CATransform3DMakeTranslation(-(self.frame.size.width - _containHelperView.frame.size.width), 0, 0);
        _containView.layer.transform = CATransform3DConcat(contaTran, contaTran2);
        self.containerView.transform = CGAffineTransformMakeTranslation(_containHelperView.frame.size.width, 0);

        return 0;
    }
    return 0;
}

- (void)closeFold
{
    _open = NO;
    [UIView animateWithDuration:0.5 animations:^{
        [self setInitTrans];
        self.containerView.layer.transform = CATransform3DIdentity;
    }];
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        self.cshowMenuView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];

}

- (void)doAni
{
    if (_open == NO) {
        if (_rota > M_PI_4) {
            [self openFold];
        } else {
            [self closeFold];
        }
    }
    else {
        if (_rota > -M_PI_4) {
            [self openFold];
        } else {
            [self closeFold];
        }
    }
}

- (void)openFold
{
    _open = YES;
    CATransform3D tran = CATransform3DIdentity;
    tran.m34 = -1/500.0;

    CABasicAnimation *tranAni = [CABasicAnimation animationWithKeyPath:@"transform"];
    tranAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    tranAni.fromValue = [NSValue valueWithCATransform3D:_containView.layer.transform];//_containView.layer.transform 是侧边栏当前transform变换矩阵
    tranAni.toValue = [NSValue valueWithCATransform3D:tran];//侧边栏最终状态的变换矩阵（也就是一开始没有变换的初始矩阵）
    tranAni.duration = .5;
    [_containView.layer addAnimation:tranAni forKey:@"openForContainAni"];
    _containView.layer.transform = tran;
    
    _containHelperView.layer.transform = tran;
    
    CABasicAnimation *tranAni2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    tranAni2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    tranAni2.fromValue = [NSValue valueWithCATransform3D:self.containerView.layer.transform];
    tranAni2.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(100, 0, 0)];
    tranAni2.duration = .5;
    [self.containerView.layer addAnimation:tranAni2 forKey:@"openForContainerAni"];
    self.containerView.layer.transform = CATransform3DMakeTranslation(100, 0, 0);
    
    [UIView animateKeyframesWithDuration:.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        self.cshowMenuView.transform = CGAffineTransformMakeRotation(M_PI_2);
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)doOpenOrNot
{
    if (_open) {
        [self closeFold];
    } else {
        [self openFold];
    }
}

@end
