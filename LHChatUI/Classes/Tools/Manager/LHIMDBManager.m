//
//  LHIMDBManager.m
//  LHChatUI
//
//  Created by liuhao on 2016/12/27.
//  Copyright © 2016年 lenhart. All rights reserved.
//

#import "LHIMDBManager.h"
#import "FMDB.h"
#import <objc/runtime.h>

#define ISEXITTABLE(modelClass) \
{NSString *classNameTip = [NSString stringWithFormat:@"%@ 表不存在，请先创建",modelClass]; \
NSAssert([self isExitTable:modelClass autoCloseDB:NO], classNameTip);\
}

@interface LHIMDBManager ()

@property(nonatomic,strong) FMDatabase *dataBase;

@end

@implementation LHIMDBManager
SingleM(Manager)

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - public
- (BOOL)insertModel:(id)model{
    if ([model isKindOfClass:[NSArray class]] || [model isKindOfClass:[NSMutableArray class]]) {
        NSArray *modelArr = (NSArray *)model;
        return [self insertModelArr:modelArr];
    } else {
        return [self insertModel:model autoCloseDB:YES];
    }
}

#pragma mark - private
#pragma mark 创表
- (BOOL)createTable:(Class)modelClass {
    return [self createTable:modelClass autoCloseDB:YES];
}

- (BOOL)createTable:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    if ([self.dataBase open]) {
        // 创表,判断是否已经存在
        if ([self isExitTable:modelClass autoCloseDB:NO]) {
            if (autoCloseDB) {
                [self.dataBase close];
            }
            return YES;
        } else {
            BOOL success = [self.dataBase executeUpdate:[self createTableSQL:modelClass]];
            // 关闭数据库
            if (autoCloseDB) {
                [self.dataBase close];
            }
            return success;
        }
    } else {
        return NO;
    }
}


/**
 *  @author Clarence
 *
 *  指定的表是否存在
 */
- (BOOL)isExitTable:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    if ([self.dataBase open]){
        BOOL success = [self.dataBase executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",modelClass]];
        // 操作完毕是否需要关闭
        if (autoCloseDB) {
            [self.dataBase close];
        }
        return success;
    } else {
        return NO;
    }
}

/**
 *  @author Clarence
 *
 *  创建表的SQL语句
 */
- (NSString *)createTableSQL:(Class)modelClass {
    NSMutableString *sqlPropertyM = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT ",modelClass];
    
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList(modelClass, &outCount);
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
        if ([[key substringToIndex:1] isEqualToString:@"_"]) {
            key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        if ([key isEqualToString:@"id"]) continue;
        [sqlPropertyM appendFormat:@", %@",key];
    }
    [sqlPropertyM appendString:@")"];
    
    return sqlPropertyM;
}

#pragma mark 插入
- (BOOL)insertModelArr:(NSArray *)modelArr{
    BOOL flag = YES;
    for (id model in modelArr) {
        // 处理过程中不关闭数据库
        if (![self insertModel:model autoCloseDB:NO]) {
            flag = NO;
        }
    }
    // 处理完毕关闭数据库
    [self.dataBase close];
    // 全部插入成功才返回YES
    return flag;
}

- (BOOL)insertModel:(id)model autoCloseDB:(BOOL)autoCloseDB {
    NSAssert(![model isKindOfClass:[UIResponder class]], @"必须保证模型是NSObject或者NSObject的子类,同时不响应事件");
    if ([self.dataBase open]) {
        // 没有表的时候，先创建再插入
        
        // 此时有三步操作，第一步处理完不关闭数据库
        if (![self isExitTable:[model class] autoCloseDB:NO]) {
            // 第二步处理完不关闭数据库
            BOOL success = [self createTable:[model class] autoCloseDB:NO];
            if (success) {
                NSString *dbid = [model valueForKey:@"id"];
                id judgeModle = [self searchModel:[model class] byKey:dbid autoCloseDB:NO sqlString:nil];
                
                if ([[judgeModle valueForKey:@"id"] isEqualToString:dbid]) {
                    BOOL updataSuccess = [self modifyModel:model byID:dbid autoCloseDB:NO];
                    if (autoCloseDB) {
                        [self.dataBase close];
                    }
                    return updataSuccess;
                } else {
                    BOOL insertSuccess = [self.dataBase executeUpdate:[self createInsertSQL:model]];
                    // 最后一步操作完毕，询问是否需要关闭
                    if (autoCloseDB) {
                        [self.dataBase close];
                    }
                    return insertSuccess;
                }
                
            } else {
                // 第二步操作失败，询问是否需要关闭,可能是创表失败，或者是已经有表
                if (autoCloseDB) {
                    [self.dataBase close];
                }
                return NO;
            }
        } else {
            // 已经创建有对应的表，直接插入
            NSString *dbid = [model valueForKey:@"id"];
            id judgeModle = [self searchModel:[model class] byKey:dbid autoCloseDB:NO sqlString:nil];
            
            if ([[judgeModle valueForKey:@"id"] isEqualToString:dbid]) {
                BOOL updataSuccess = [self modifyModel:model byID:dbid autoCloseDB:NO];
                if (autoCloseDB) {
                    [self.dataBase close];
                }
                return updataSuccess;
            } else {
                BOOL insertSuccess = [self.dataBase executeUpdate:[self createInsertSQL:model]];
                // 最后一步操作完毕，询问是否需要关闭
                if (autoCloseDB) {
                    [self.dataBase close];
                }
                return insertSuccess;
            }
        }
    } else {
        return NO;
    }
}

/**
 *  @author Clarence
 *
 *  创建插入表的SQL语句
 */
- (NSString *)createInsertSQL:(id)model {
    NSMutableString *sqlValueM = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ (",[model class]];
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList([model class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
        if ([[key substringToIndex:1] isEqualToString:@"_"]) {
            key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        
        if (i == 0) {
            [sqlValueM appendString:key];
        } else {
            [sqlValueM appendFormat:@", %@",key];
        }
    }
    [sqlValueM appendString:@") VALUES ("];
    
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
        if ([[key substringToIndex:1] isEqualToString:@"_"]) {
            key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        
        id value = [model valueForKey:key];
        if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]] || [value isKindOfClass:[NSNull class]]) {
            value = [NSString stringWithFormat:@"%@",value];
        }
        if (i == 0) {
            // sql 语句中字符串需要单引号或者双引号括起来
            [sqlValueM appendFormat:@"%@",[value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value] : value];
        } else {
            [sqlValueM appendFormat:@", %@",[value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value] : value];
        }
    }
    //    [sqlValueM appendFormat:@" WHERE id = '%@'",[model valueForKey:@"id"]];
    [sqlValueM appendString:@");"];
    
    return sqlValueM;
}

#pragma mark 查
- (NSArray *)searchModelArr:(Class)modelClass byKey:(NSString *)key {
    if ([self.dataBase open]) {
        ISEXITTABLE(modelClass);
        // 查询数据
        NSMutableString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",modelClass].mutableCopy;
        if (!key) { // 加载消息
            [sql appendString:[NSString stringWithFormat:@" order by id DESC limit 0,20"]];
        } else {
            // 历史
            [sql appendString:[NSString stringWithFormat:@" where id < %zd order by id DESC limit 0,20", key.integerValue]];
        }
        FMResultSet *rs = [self.dataBase executeQuery:sql];
        NSMutableArray *modelArrM = [NSMutableArray array];
        // 遍历结果集
        while ([rs next]) {
            
            // 创建对象
            id object = [[modelClass class] new];
            
            unsigned int outCount;
            Ivar * ivars = class_copyIvarList(modelClass, &outCount);
            for (int i = 0; i < outCount; i ++) {
                Ivar ivar = ivars[i];
                NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
                if([[key substringToIndex:1] isEqualToString:@"_"]){
                    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                
                id value = [rs objectForColumnName:key];
                if ([value isKindOfClass:[NSString class]]) {
                    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if ([result isKindOfClass:[NSDictionary class]] || [result isKindOfClass:[NSMutableDictionary class]] || [result isKindOfClass:[NSArray class]] || [result isKindOfClass:[NSMutableArray class]]) {
                        [object setValue:result forKey:key];
                    }
                    else{
                        [object setValue:value forKey:key];
                    }
                }
                else{
                    [object setValue:value forKey:key];
                }
            }
            
            // 添加
            [modelArrM addObject:object];
        }
        [self.dataBase close];
        return modelArrM.copy;
    } else {
        return nil;
    }
}

- (id)searchModel:(Class)modelClass keyValues:(NSDictionary *)keyValues {
    NSArray *values = keyValues.allValues;
    NSArray *keys = keyValues.allKeys;
    NSMutableString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ", modelClass].mutableCopy;
    [values enumerateObjectsUsingBlock:^(NSString *value, NSUInteger idx, BOOL * stop) {
        if (!idx) {
            [sql appendFormat:@"%@ = %@ ", keys[idx], [value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'", value] : value];
        } else {
            [sql appendFormat:@" and %@ = %@", keys[idx], [value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'", value] : value];
        }
    }];
    [sql appendString:@";"];
    return [self searchModel:modelClass byKey:nil autoCloseDB:YES sqlString:sql];
}

- (id)searchModel:(Class)modelClass byKey:(NSString *)key autoCloseDB:(BOOL)autoCloseDB sqlString:(NSString *)sql {
    if ([self.dataBase open]) {
        ISEXITTABLE(modelClass);
        // 查询数据
        FMResultSet *rs = [self.dataBase executeQuery:sql ? sql : [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id = '%@';", modelClass, key]];
        // 创建对象
        id object = [[modelClass class] new];
        // 遍历结果集
        while ([rs next]) {
            
            unsigned int outCount;
            Ivar * ivars = class_copyIvarList(modelClass, &outCount);
            for (int i = 0; i < outCount; i ++) {
                Ivar ivar = ivars[i];
                NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
                if([[key substringToIndex:1] isEqualToString:@"_"]){
                    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                
                id value = [rs objectForColumnName:key];
                if ([value isKindOfClass:[NSString class]]) {
                    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if ([result isKindOfClass:[NSDictionary class]] || [result isKindOfClass:[NSMutableDictionary class]] || [result isKindOfClass:[NSArray class]] || [result isKindOfClass:[NSMutableArray class]]) {
                        [object setValue:result forKey:key];
                    } else {
                        [object setValue:value forKey:key];
                    }
                } else {
                    [object setValue:value forKey:key];
                }
            }
        }
        if (autoCloseDB) {
            [self.dataBase close];
        }
        return object;
    } else {
        return nil;
    }
}

#pragma mark 改
- (BOOL)modifyModel:(id)model byID:(NSString *)ID autoCloseDB:(BOOL)autoCloseDB {
    if ([self.dataBase open]) {
        ISEXITTABLE([model class]);
        // 修改数据@"UPDATE t_student SET name = 'liwx' WHERE age > 12 AND age < 15;"
        NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",[model class]];
        unsigned int outCount;
        Ivar * ivars = class_copyIvarList([model class], &outCount);
        for (int i = 0; i < outCount; i ++) {
            Ivar ivar = ivars[i];
            NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
            if ([[key substringToIndex:1] isEqualToString:@"_"]) {
                key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            id value = [model valueForKey:key];
            if (i == 0) {
                [sql appendFormat:@"%@ = %@",key,([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]) || [NSNull class] ? [NSString stringWithFormat:@"'%@'",value] : value];
            } else {
                [sql appendFormat:@",%@ = %@",key,([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]) || [NSNull class] ? [NSString stringWithFormat:@"'%@'",value] : value];
            }
        }
        
        [sql appendFormat:@" WHERE id = '%@';",ID];
        BOOL success = [self.dataBase executeUpdate:sql];
        if (autoCloseDB) {
            [self.dataBase close];
        }
        return success;
    } else {
        return NO;
    }
}


+ (NSString *)getDbPath {
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/com.liuhao.LHChatUI"];
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NULL]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [filePath stringByAppendingPathComponent:@"LHChat.db"];
}

#pragma mark - lazy
- (FMDatabase *)dataBase {
    if (!_dataBase) {
        _dataBase = [[FMDatabase alloc] initWithPath:[LHIMDBManager getDbPath]];
        if (![_dataBase open]) {
            return nil;
        }
    }
    return _dataBase;
}

@end
