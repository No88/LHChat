//
//  UIViewController+Set.m
//  LHChatUI
//
//  Created by lenhart on 2016/12/22.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "UIViewController+Set.h"




@implementation UIViewController (Set)

- (void)lh_setupConfigWithTitle:(NSString *)title {
    UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W * 0.66f, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont systemFontOfSize:17];
    titleView.textColor = [UIColor whiteColor];
    titleView.userInteractionEnabled = YES;
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.text = title;
    self.navigationItem.titleView = titleView;
    
    if (iOS7LATER) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
}



@end
