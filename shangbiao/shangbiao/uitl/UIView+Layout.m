//
//  UIView+Layout.m
//  OssIOSDemo
//
//  Created by ganshiren on 2017/7/2.
//  Copyright © 2017年 Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Layout.h"
static const char *hasAddBlurKey = "hasAddBlurKey";
static const char *shouldAddBlurKey = "shouldAddBlurKey";


@implementation UIView (Layout)

@dynamic top;
@dynamic bottom;
@dynamic left;
@dynamic right;

@dynamic width;
@dynamic height;

@dynamic size;

@dynamic x;
@dynamic y;


- (void)my_layoutSubviews
{
    //  [self viewWillAppear:animated];
    if (self.shouldAddBlur) {
        if (!self.hasAddBlur) {
            self.hasAddBlur = YES;
            [self addGrayMohu];
        }
    }
    
    [self my_layoutSubviews];
    
    NSLog(@"%s",__func__);
}

- (void)setShouldAddBlur:(BOOL)shouldAddBlur {
    if (shouldAddBlur) {
        if ([self isKindOfClass:[UITableView class]]) {
            [self addGrayMohuByParent];
        }
    }
}



- (CGFloat)top
{
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top
{
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left
{
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (CGFloat)bottom
{
    return self.frame.size.height + self.frame.origin.y;
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)right
{
    return self.frame.size.width + self.frame.origin.x;
}

- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)value
{
    CGRect frame = self.frame;
    frame.origin.x = value;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)value
{
    CGRect frame = self.frame;
    frame.origin.y = value;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (UIImage *) imageWithView
{
    CGFloat scale = [UIScreen mainScreen].scale;

    CGSize size = CGSizeMake(self.width/scale, self.height/scale);
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, self.opaque, 0.0);
    [self drawViewHierarchyInRect:frame afterScreenUpdates:NO];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage *) imageWithFrame:(CGRect)frame {
    if (CGRectIsEmpty(frame)) {
        return nil;
    }
    CGSize size = CGSizeMake(self.width, self.height);
    UIGraphicsBeginImageContextWithOptions(size, self.opaque, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage *)imageAtFrame:(CGRect)r
{
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(r);
    [self.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  theImage;//[self getImageAreaFromImage:theImage atFrame:r];
}

#pragma mark 生成image
- (UIImage *)makeImageWithView:(UIView *)view withSize:(CGSize)size
{
    
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数 [UIScreen mainScreen].scale。
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGFloat)getTransformAngle {
    CGFloat angle = atan2f(self.transform.b, self.transform.a);
    angle = angle * (180 / M_PI);
    return angle;
}

- (void) addGrayMohu {
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    effectView.frame = CGRectMake(5, 13, self.width - 10, self.height - 13);
    
    effectView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    // 阴影偏移，默认(0, -3)
    effectView.layer.shadowOffset = CGSizeMake(0,4);
    // 阴影透明度，默认0
    effectView.layer.shadowOpacity = 1;
    // 阴影半径，默认3
    effectView.layer.shadowRadius = 3;
    
    [self insertSubview:effectView atIndex:0];
}

- (void) addGrayMohuByParent {
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    
    CGFloat rateWidth = self.width*0.1;
    if (rateWidth > 8) {
        rateWidth = 8;
    }
    
    CGRect newFrame = self.frame;
    CGFloat newWidth = self.width - rateWidth*2;
    CGFloat newX = self.x+ rateWidth;
    CGFloat newY = self.y+ rateWidth;
    CGFloat newHeight = self.height - rateWidth;
    
    newFrame = CGRectMake(newX, newY, newWidth, newHeight);
    
    effectView.frame = newFrame;
    
    // 阴影偏移，默认(0, -3)
    effectView.layer.shadowOffset = CGSizeMake(0,2);
    // 阴影透明度，默认0
    effectView.layer.shadowOpacity = 1;
    // 阴影半径，默认3
    effectView.layer.shadowRadius = 3;
    //    [self.superview addSubview:effectView];
    [self.superview insertSubview:effectView atIndex:0];
}

- (id)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        if ([subView isFirstResponder]) {
            return subView;
        }
    }
    return nil;
}

@end
