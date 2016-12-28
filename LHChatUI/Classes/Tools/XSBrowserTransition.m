

#import "XSBrowserTransition.h"

@interface XSBrowserTransition()

@end

@implementation XSBrowserTransition

#pragma mark - 懒加载
- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _coverView;
}


@end
