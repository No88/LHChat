//
//  LHPhotoPreviewController.h
//  LHChatUI
//
//  Created by liuhao on 2016/12/28.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHPhotoPreviewController : UIViewController

@property (nonatomic, strong) NSArray *models;
///< Index of the photo user click / 用户点击的图片的索引
@property (nonatomic, assign) NSInteger currentIndex;

@end
