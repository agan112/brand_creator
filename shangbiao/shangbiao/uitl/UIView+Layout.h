//
//  UIView+Layout.h
//  OssIOSDemo
//
//  Created by ganshiren on 2017/7/2.
//  Copyright © 2017年 Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Layout)

@property (assign, nonatomic) CGFloat    top;
@property (assign, nonatomic) CGFloat    bottom;
@property (assign, nonatomic) CGFloat    left;
@property (assign, nonatomic) CGFloat    right;

@property (assign, nonatomic) CGFloat    x;
@property (assign, nonatomic) CGFloat    y;
@property (assign, nonatomic) CGPoint    origin;

@property (assign, nonatomic) CGFloat    centerX;
@property (assign, nonatomic) CGFloat    centerY;

@property (assign, nonatomic) CGFloat    width;
@property (assign, nonatomic) CGFloat    height;
@property (assign, nonatomic) CGSize    size;
@property (assign, nonatomic) BOOL    hasAddBlur;
@property (assign, nonatomic) BOOL    shouldAddBlur;

- (UIImage *) imageWithView;
- (UIImage *) imageWithFrame:(CGRect)frame;
- (UIImage *)imageAtFrame:(CGRect)r;
- (CGFloat)getTransformAngle;
- (void) addGrayMohuByParent;
- (id)findFirstResponder;

@end
