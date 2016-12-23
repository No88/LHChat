//
//  config.h
//  LHChatUI
//
//  Created by lenhart on 2016/12/22.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#ifndef LHConfig
#define LHConfig

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

#define iOS7LATER ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8LATER ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9LATER ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1LATER ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

// 弱引用
#define LHWeakSelf __weak typeof(self) weakSelf = self;

#define recourcesPath [[NSBundle mainBundle] resourcePath]

#endif /* LHConfig */
