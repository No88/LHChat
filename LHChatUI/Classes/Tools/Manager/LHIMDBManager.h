//
//  LHIMDBManager.h
//  LHChatUI
//
//  Created by liuhao on 2016/12/27.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Single.h"

@interface LHIMDBManager : NSObject
SingleH(Manager)

/**
 *  @author Clarence
 *
 *  @param model 插入单个模型或者模型数组,如果此时传入的模型对应的FLDBID在表中已经存在，则替换更新旧的
 *  如果没创建表就自动先创建，表名为模型类名
 *  此时执行完毕后自动关闭数据库
 *
 @return YES or NO
 */
- (BOOL)insertModel:(id)model;


/**
 查找指定表中模型数组，执行完毕后自动关闭数据库，如果没有对应表，会有断言

 @param modelClass 表
 @return 模型数组
 */
- (NSArray *)searchModelArr:(Class)modelClass byKey:(NSString *)key;

/**
 *  @author Clarence
 *
 *  查找指定表中指定Key的模型，执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */
- (id)searchModel:(Class)modelClass keyValues:(NSDictionary *)keyValues;

@end
