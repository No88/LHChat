//
//  LHPhotoPreviewCell.h
//  LHChatUI
//
//  Created by liuhao on 2016/12/28.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHPhotoPreviewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, copy) void (^singleTapGestureBlock)(CGRect imageRect);
@property (nonatomic, copy) void (^longPressGestureBlock)(UIImage *image);

- (void)recoverSubviews;

@end
