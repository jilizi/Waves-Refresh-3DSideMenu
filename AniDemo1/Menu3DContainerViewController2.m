//
//  Menu3DContainerViewController.m
//  ReactiveCocoaStudy
//
//  Created by daixu on 15/6/1.
//  Copyright (c) 2015年 daixu. All rights reserved.
//

#import "Menu3DContainerViewController2.h"
#import "Menu3DSideBar2.h"
#import "UIConfig.h"

@interface Menu3DContainerViewController2 ()
{
    UIView *_containView;
    UIView *_navView;
    Menu3DSideBar2 *_sideMenu2;
    UIView *_testV;
    CGFloat _rota;
}
@end

@implementation Menu3DContainerViewController2

+ (UIImage *)createImageWithWithFrame:(CGSize)size Path:(UIBezierPath *)path color:(UIColor*)stokeColor backColor:(UIColor*)backColor lineWidth:(CGFloat)lineW
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, path.CGPath);
    CGContextSetStrokeColorWithColor(context, stokeColor.CGColor);
    CGContextSetFillColorWithColor(context, backColor.CGColor);
    CGContextSetLineWidth(context, lineW);
    CGContextStrokePath(context);
    CGContextFillPath(context);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavAndSideMenu];
    [self initGes];
}

- (void)initNavAndSideMenu
{
    _containView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_FULL_WIDTH, 64)];
    _navView.backgroundColor = [UIColor blackColor];
    
    _testV = [[UIView alloc] initWithFrame:self.view.bounds];
    _testV.backgroundColor = LikeGreenColor;
    
    UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, 32, 32)];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(4, 4)];
    [path addLineToPoint:CGPointMake(24, 4)];
    [path moveToPoint:CGPointMake(4, 11)];
    [path addLineToPoint:CGPointMake(24, 11)];
    [path moveToPoint:CGPointMake(4, 18)];
    [path addLineToPoint:CGPointMake(24, 18)];

    [menuBtn setImage:[Menu3DContainerViewController2 createImageWithWithFrame:CGSizeMake(32, 32) Path:path color:[UIColor whiteColor] backColor:[UIColor blackColor] lineWidth:3] forState:UIControlStateNormal];
    [_navView addSubview:menuBtn];
    [menuBtn addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    _sideMenu2 = [[Menu3DSideBar2 alloc] initWithFrame:CGRectMake(0, 0, 100, UI_SCREEN_FULL_HEIGHT)];
    _sideMenu2.containerView = _containView;
    _sideMenu2.cshowMenuView = menuBtn;
    
    [self.view addSubview:_sideMenu2];
    [self.view addSubview:_containView];
    
    [_containView addSubview:_testV];
    [_containView addSubview:_navView];
}

- (void)initGes
{
    UIPanGestureRecognizer *pan  =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(foldMenu:)];
    [self.view addGestureRecognizer:pan];
}

- (void)foldMenu:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateBegan) {
        [_sideMenu2 doAni];
    }
    if (pan.state == UIGestureRecognizerStateChanged) {
        //手势的来回拖动都会计算拖动的像素吗？ 不会
        CGPoint point = [pan translationInView:self.view];//返回在X轴和Y轴坐标上拖动了多少像素
        CGFloat fullH = 160;//手势滑动时候，侧边栏跟着动的手感 （point.x的大小和这个值有关，改变这个值亲自体验一下吧）
        CGFloat rota = point.x/fullH;
        NSLog(@"point.x = %f",point.x);
        [_sideMenu2 setOffset:rota];
    }
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        //手势结束
        [_sideMenu2 aniContinue];
    }
    
}

- (void)openMenu:(id)sender
{
    [_sideMenu2 doOpenOrNot];
}

@end
