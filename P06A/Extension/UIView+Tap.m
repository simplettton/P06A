//
//  UIView+Tap.m
//  P06A
//
//  Created by Binger Zeng on 2018/1/5.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "UIView+Tap.h"
#import <objc/runtime.h>
static const void* tagValue = &tagValue;

@interface UIView ()
@property (nonatomic, copy) void(^tapAction)(id);
@end
@implementation UIView (Tap)
- (void)tap{
    if (self.tapAction) {
        self.tapAction(self);
    }
}
- (void)addTapBlock:(void(^)(id obj))tapAction{
    self.tapAction = tapAction;
    if (![self gestureRecognizers]) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tap];
    }
}

-(void)setTapAction:(void (^)(id))tapAction {
    objc_setAssociatedObject(self, tagValue, tapAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void (^)(id))tapAction {
    return objc_getAssociatedObject(self, tagValue);
}

@end
