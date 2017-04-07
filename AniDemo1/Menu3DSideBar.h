//
//  Menu3DSideBar.h
//  ReactiveCocoaStudy
//
//  Created by daixu on 15/6/1.
//  Copyright (c) 2015年 daixu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Menu3DSideBar : UIView

@property(nonatomic,weak)UIView *containerView;//右侧主视图
@property(nonatomic,weak)UIView *cshowMenuView;//右侧上面菜单按钮

- (CGFloat)setRota:(CGFloat)rota;

- (void)closeFold;

- (void)openFold;

- (void)doAni;

- (void)doOpenOrNot;

@end
