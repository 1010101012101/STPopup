//
//  UIViewController+STPopupController.m
//  Sth4Me
//
//  Created by Kevin Lin on 13/9/15.
//  Copyright (c) 2015 Sth4Me. All rights reserved.
//

#import "UIViewController+STPopupController.h"
#import "STPopupController.h"
#import <objc/runtime.h>

@implementation UIViewController (STPopupController)

@dynamic contentSizeInPopup;
@dynamic landscapeContentSizeInPopup;
@dynamic popupController;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(loadView) toSelector:@selector(st_loadView)];
        [self swizzleSelector:@selector(presentViewController:animated:completion:) toSelector:@selector(st_presentViewController:animated:completion:)];
    });
}

+ (void)swizzleSelector:(SEL)originalSelector toSelector:(SEL)swizzledSelector
{
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)st_loadView
{
    if (CGSizeEqualToSize(self.contentSizeInPopup, CGSizeZero) &&
        CGSizeEqualToSize(self.landscapeContentSizeInPopup, CGSizeZero)) {
        [self st_loadView];
        return;
    }
    
    CGSize contentSizeInPopup = self.contentSizeInPopup;
    
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, contentSizeInPopup.width, contentSizeInPopup.height);
    self.view = view;
}

- (void)st_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    if (!self.popupController) {
        [self st_presentViewController:viewControllerToPresent animated:flag completion:completion];
        return;
    }
    
    [[self.popupController valueForKey:@"containerViewController"] presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)setContentSizeInPopup:(CGSize)contentSizeInPopup
{
    objc_setAssociatedObject(self, @selector(contentSizeInPopup), [NSValue valueWithCGSize:contentSizeInPopup], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)contentSizeInPopup
{
    return [objc_getAssociatedObject(self, @selector(contentSizeInPopup)) CGSizeValue];
}

- (void)setLandscapeContentSizeInPopup:(CGSize)landscapeContentSizeInPopup
{
    objc_setAssociatedObject(self, @selector(landscapeContentSizeInPopup), [NSValue valueWithCGSize:landscapeContentSizeInPopup], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)landscapeContentSizeInPopup
{
    return [objc_getAssociatedObject(self, @selector(landscapeContentSizeInPopup)) CGSizeValue];
}

- (void)setPopupController:(STPopupController *)popupController
{
    objc_setAssociatedObject(self, @selector(popupController), popupController, OBJC_ASSOCIATION_ASSIGN);
}

- (STPopupController *)popupController
{
    return objc_getAssociatedObject(self, @selector(popupController));
}

@end