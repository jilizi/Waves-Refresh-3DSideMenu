//
//  Menu3DSideBar2.m
//  ReactiveCocoaStudy
//
//  Created by daixu on 15/6/3.
//  Copyright (c) 2015年 daixu. All rights reserved.
//

#import "Menu3DSideBar2.h"

@implementation Menu3DSideBar2
{
    BOOL _open;
    CGFloat _offset;//用来控制当前视图的状态处于动画的什么位置

    UIView *_containView;//侧边栏
    CATransform3D _mainStartTrans;
    CATransform3D _touTrans;
    
    CAGradientLayer *_gradLayer;//颜色梯度图层
    NSArray *_gradOpenColors;
    NSArray *_gradCloseColors;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        
        _containView = [[UIView alloc] initWithFrame:CGRectMake(50, 64, frame.size.width, frame.size.height - 64)];
        [_containView setBackgroundColor:[UIColor orangeColor]];
        [self addSubview:_containView];
        
        [self setGradLayer];
        [self setInitTrans];
    }
    return self;
}
//初始化颜色梯度图层
- (void)setGradLayer
{
    _gradOpenColors = @[(id)[[UIColor clearColor] CGColor],(id)[[UIColor clearColor] CGColor]];
    _gradCloseColors = @[(id)[[UIColor clearColor] CGColor],(id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor]];
    
    _gradLayer = [CAGradientLayer layer];
    _gradLayer.frame = _containView.bounds;
    _gradLayer.colors = _gradCloseColors;
    _gradLayer.startPoint = CGPointMake(0, 0.5);
    _gradLayer.endPoint = CGPointMake(1,0.5);
    _gradLayer.locations = @[@(0.2),@(1)];
    
    [_containView.layer addSublayer:_gradLayer];
}
//初始化变换
- (void)setInitTrans
{
    CATransform3D tran = CATransform3DIdentity;
    tran.m34 = -1/500.0;
    
    _touTrans = tran;
    
    CATransform3D contaTran = CATransform3DRotate(_touTrans,-M_PI_2, 0, 1, 0); //矩阵tran和（-M_PI_2, 0, 1, 0）矩阵相乘
    CATransform3D contaTran2 = CATransform3DMakeTranslation(-self.frame.size.width, 0, 0);
    
    _mainStartTrans = CATransform3DConcat(contaTran, contaTran2);
    _containView.layer.anchorPoint = CGPointMake(1, 0.5);
    _containView.layer.transform = _mainStartTrans;
}
//手势执行过程中执行的方法
- (void)setOffset:(CGFloat)offset
{
    
    if (_open == NO) {
        if (offset <= 0) {
            offset = 0;
        }
    } else {
        if (offset >= 0) {
            offset = 0;
        }
    }
    _offset = MIN(0.999, MAX(0, ABS(offset)));//限制offset的值在 [0，1）区间内
    
    _containView.layer.timeOffset = _offset;
    _gradLayer.timeOffset = _offset;
    
    NSLog(@"*** timeoffset = %f ***",_offset);
    self.cshowMenuView.layer.timeOffset = _offset;
    self.containerView.layer.timeOffset = _offset;
}
//手势结束之后的方法
- (void)aniContinue{
    //一个是手势结束我们需要在设置speed为1的时候，需要获取当前的视图Presentation tree（动态树）的transform，并且更新到model tree（就是指layer）
    _containView.layer.transform = [[_containView.layer.presentationLayer valueForKeyPath:@"transform"] CATransform3DValue];
    self.containerView.layer.transform = [[self.containerView.layer.presentationLayer valueForKeyPath:@"transform"] CATransform3DValue];
    self.cshowMenuView.layer.transform = [[self.cshowMenuView.layer.presentationLayer valueForKeyPath:@"transform"] CATransform3DValue];
    _gradLayer.colors = [_gradLayer.presentationLayer valueForKeyPath:@"colors"];
    
    [self resetLayers];
    
    if (_open == NO) {
        if (_offset > 0.5) {
            _open = YES;
            [self openFold:1];
        } else {
            [self closeFold:1];
        }
    }
    else {
        if (_offset > 0.5) {
            _open = NO;
            [self closeFold:1];
        } else {
            [self openFold:1];
        }
    }
}
//手势开始的时候执行的方法
- (void)doAni
{
    [self resetLayers];
    
    if (_open == NO) {
        _gradLayer.colors = @[(id)[[UIColor clearColor] CGColor],(id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor]];
        [self openFold:0];
    }
    else {
        _gradLayer.colors = @[(id)[[UIColor clearColor] CGColor],(id)[[UIColor clearColor] CGColor]];
        [self closeFold:0];
    }
}

- (void)openFold:(CGFloat)speed{
    [self addBasicTransformAni:_containView.layer
                     fromValue:_containView.layer.transform
                       toValue:_touTrans
                         speed:speed];
    [self addBasicTransformAni:self.containerView.layer
                     fromValue:self.containerView.layer.transform
                       toValue:CATransform3DMakeTranslation(100, 0, 0)
                         speed:speed];
    [self addBasicTransformAni:self.cshowMenuView.layer
                     fromValue:self.cshowMenuView.layer.transform
                       toValue:CATransform3DMakeRotation(M_PI_2, 0, 0, 1)
                         speed:speed];
    [self addBasicAniForLayer:_gradLayer keyPath:@"colors"
                    fromValue:_gradLayer.colors
                      toValue:_gradOpenColors
                        speed:speed];
    //设置动画结束后的 执行动画的layer的变换矩阵
    if (speed == 1) {
        [CATransaction begin];//在当前线程开启新的事务
        //NO 启动隐式动画 YES 关闭隐式动画
        [CATransaction setDisableActions:YES];//我们给model tree赋值的时候，默认会有隐式动画的效果，我们需要禁止这种行为
        
        _containView.layer.transform = _touTrans;
        _gradLayer.colors = _gradOpenColors;
        self.containerView.layer.transform = CATransform3DMakeTranslation(100, 0, 0);
        self.cshowMenuView.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
        
        [CATransaction commit];//提交当前事务的所有改变 ，如果当前事务不存在就会触发异常
    }

    
}

- (void)closeFold:(CGFloat)speed
{
    
    [self addBasicTransformAni:_containView.layer
                     fromValue:_containView.layer.transform
                       toValue:_mainStartTrans
                         speed:speed];
    [self addBasicTransformAni:self.containerView.layer
                     fromValue:self.containerView.layer.transform
                       toValue:CATransform3DIdentity
                         speed:speed];
    [self addBasicTransformAni:self.cshowMenuView.layer
                     fromValue:self.cshowMenuView.layer.transform
                       toValue:CATransform3DIdentity
                         speed:speed];
    [self addBasicAniForLayer:_gradLayer keyPath:@"colors"
                    fromValue:_gradLayer.colors
                      toValue:_gradCloseColors
                        speed:speed];
    //设置动画结束后的 执行动画的layer的变换矩阵
    if (speed == 1) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        _containView.layer.transform = _mainStartTrans;
        _gradLayer.colors = _gradCloseColors;
        self.containerView.layer.transform = CATransform3DIdentity;
        self.cshowMenuView.layer.transform = CATransform3DIdentity;
        
        [CATransaction commit];
    }
    
}
//添加transform的动画
- (void)addBasicTransformAni:(CALayer*)layer fromValue:(CATransform3D)from toValue:(CATransform3D)to speed:(CGFloat)speed
{
    [self addBasicAniForLayer:layer keyPath:@"transform" fromValue:[NSValue valueWithCATransform3D:from] toValue:[NSValue valueWithCATransform3D:to] speed:speed];
}
//添加动画 动画添加即执行
- (void)addBasicAniForLayer:(CALayer*)layer keyPath:(NSString *)key fromValue:(id)from toValue:(id)to speed:(CGFloat)speed
{
    CABasicAnimation *tranAni = [CABasicAnimation animationWithKeyPath:key];
    tranAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    tranAni.fromValue = from;
    tranAni.toValue = to;
    tranAni.duration = (speed == 1)?0.5:1;
    layer.speed = speed;
    [layer addAnimation:tranAni forKey:@"3dMenu"];
}

- (void)resetLayers
{
    _containView.layer.timeOffset = 0;
    [_containView.layer removeAllAnimations];
    
    self.containerView.layer.timeOffset = 0;
    [self.containerView.layer removeAllAnimations];
    
    self.cshowMenuView.layer.timeOffset = 0;
    [self.cshowMenuView.layer removeAllAnimations];
    
    [_gradLayer removeAllAnimations];
    _gradLayer.timeOffset = 0;
}

- (void)doOpenOrNot
{
    if (_open) {
        _gradLayer.colors = @[(id)[[UIColor clearColor] CGColor],(id)[[UIColor clearColor] CGColor]];
        [self closeFold:1];
    } else {
        _gradLayer.colors = @[(id)[[UIColor clearColor] CGColor],(id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor]];
        [self openFold:1];
    }
    _open = !_open;
}

@end
