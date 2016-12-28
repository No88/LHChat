

#import <Foundation/Foundation.h>
#import "Single.h"

@class XSBrowserAnimateDelegate;
@protocol XSBrowserDelegate <NSObject>

@required
/** 获取一个和被点击cell一模一样的UIImageView */
- (UIImageView *)XSBrowserDelegate:(XSBrowserAnimateDelegate *)browserDelegate imageViewForRowAtIndex:(NSInteger)index;

/** 获取被点击cell相对于keywindow的frame */
- (CGRect)XSBrowserDelegate:(XSBrowserAnimateDelegate *)browserDelegate fromRectForRowAtIndex:(NSInteger)index;

/** 获取被点击cell中的图片, 将来在图片浏览器中显示的尺寸 */
- (CGRect)XSBrowserDelegate:(XSBrowserAnimateDelegate *)browserDelegate toRectForRowAtIndex:(NSInteger)index;

/** 是否在可视区域 */
- (BOOL)XSBrowserDelegate:(XSBrowserAnimateDelegate *)browserDelegate isVisibleForRowAtIndex:(NSInteger)index;

@end

@interface XSBrowserAnimateDelegate : NSObject <UIViewControllerTransitioningDelegate>
SingleH(Instance)
/** 代理 */
@property (nonatomic, strong) id<XSBrowserDelegate> delegate;
/** 索引 */
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign, getter=isIm) BOOL im;
@property (nonatomic, assign) CGRect currentFrame;
@end
