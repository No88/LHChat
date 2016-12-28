

#import "XSBrowserAnimateDelegate.h"
#import "XSBrowserTransition.h"
#import "LHPhotoPreviewController.h"
#import "SDImageCache.h"

@interface XSBrowserAnimateDelegate () <UIViewControllerAnimatedTransitioning> {
    BOOL isPresented;
    CGRect fromImageRect;
    CGRect toImageRect;
}

@property (nonatomic, strong) XSBrowserTransition *browserTransition;
@end

@implementation XSBrowserAnimateDelegate 
SingleM(Instance)

#pragma mark -
#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (isPresented) {
        [self animateWillPresentedController:transitionContext];
    } else {
        [self animateWillDismissedController:transitionContext];
    }
}



- (void)animateWillPresentedController:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(XSBrowserDelegate:toRectForRowAtIndex:)] &&
        [self.delegate respondsToSelector:@selector(XSBrowserDelegate:fromRectForRowAtIndex:)] &&
        [self.delegate respondsToSelector:@selector(XSBrowserDelegate:imageViewForRowAtIndex:)]) {
        
        [[transitionContext containerView] addSubview:self.browserTransition.coverView];
        UIImageView *imageView = [self.delegate XSBrowserDelegate:self imageViewForRowAtIndex:self.index];
        fromImageRect = [self.delegate XSBrowserDelegate:self fromRectForRowAtIndex:self.index];
        imageView.frame = fromImageRect;
        toImageRect = [self.delegate XSBrowserDelegate:self toRectForRowAtIndex:self.index];
        
        [[transitionContext containerView] addSubview:imageView];
        
        if (toImageRect.origin.y) {
            [UIView animateWithDuration:0.18 animations:^{
                self.browserTransition.coverView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
                imageView.frame = toImageRect;
                [imageView.layer setValue:@(1.01) forKeyPath:@"transform.scale"];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.18 animations:^{
                    [imageView.layer setValue:@(1.0) forKeyPath:@"transform.scale"];
                } completion:^(BOOL finished) {
                    [imageView removeFromSuperview];
                    
                    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
                    [[transitionContext containerView] addSubview:toView];
                    [transitionContext completeTransition:YES];
                }];
            }];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                self.browserTransition.coverView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
                imageView.frame = toImageRect;
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
                
                UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
                [[transitionContext containerView] addSubview:toView];
                [transitionContext completeTransition:YES];
            }];
        }
    }
}
- (void)animateWillDismissedController:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(XSBrowserDelegate:toRectForRowAtIndex:)] &&
        [self.delegate respondsToSelector:@selector(XSBrowserDelegate:imageViewForRowAtIndex:)] &&
        [self.delegate respondsToSelector:@selector(XSBrowserDelegate:isVisibleForRowAtIndex:)]) {
        
        LHPhotoPreviewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        NSInteger index = fromVC.currentIndex;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.currentFrame];
        [SDImageCache.sharedImageCache queryCacheOperationForKey:fromVC.models[index] done:^(UIImage * image, NSData * data, SDImageCacheType cacheType) {
            imageView.image = image;
        }];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        
//        BOOL isOverstep = index > 2 ? 1 : 0;
        BOOL isOverstep = [self.delegate XSBrowserDelegate:self isVisibleForRowAtIndex:index];
        CGRect toRect = [self.delegate XSBrowserDelegate:self fromRectForRowAtIndex:index];
        
        [[transitionContext containerView] addSubview:imageView];
        fromVC.view.alpha = isOverstep ? 1 : 0;
        [UIView animateWithDuration:0.18 animations:^{
            self.browserTransition.coverView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
            if (isOverstep) {
                fromVC.view.alpha = 0.65;
                imageView.image = [self imageByApplyingAlpha:0.45 image:imageView.image];
            } else imageView.frame = toRect;
            if (self.isIm) imageView.layer.cornerRadius = 14;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            [imageView removeFromSuperview];
        }];
    }
}

//设置图片透明度
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha image:(UIImage*)image {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    self.browserTransition = [[XSBrowserTransition alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return self.browserTransition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    isPresented = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    isPresented = NO;
    return self;
}


#pragma mark -
#pragma mark - lazy

@end
