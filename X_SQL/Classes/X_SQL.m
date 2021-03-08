//
//  AigoSQL.m
//  AigoClient
//
//  Created by 项正强 on 2021/1/4.
//

#import "X_SQL.h"
#import "NSObject+XProperty.h"

@interface X_SQL ()
@property (nonatomic,strong) FMDatabaseQueue *dbQueue;
@property (nonatomic,copy) NSString *sqlName;
@end

@implementation X_SQL

/// 设置数据库
+ (X_SQL *) setSqlName:(NSString * _Nullable) name {
    if (name != nil && ![name isEqualToString:@""]) {
        [X_SQL instance].sqlName = name;
    }
    [X_SQL instance].dbQueue = [[FMDatabaseQueue alloc] initWithPath:[X_SQL aigoPath]];
    return [X_SQL instance];
}

//MARK: 初始化
+ (instancetype) instance {
    static X_SQL *until = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /// 因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法,不能再使用alloc方法
        until = [[super allocWithZone:NULL] init];
        until.sqlName = [X_SQL defaultSqlName];
    });
    return until;
}

/// 防止外部调用alloc 或者 new
+ (instancetype) allocWithZone:(struct _NSZone *) zone {
    return [X_SQL instance];
}

/// 防止外部调用copy
- (id) copyWithZone:(nullable NSZone *) zone {
    return [X_SQL instance];
}

/// 数据库路径
+ (NSString *) aigoPath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *databasePath = [documentsPath stringByAppendingPathComponent:@"sqlite"];
    /// 判断数据库是否存在
    bool isExist = [[NSFileManager defaultManager] fileExistsAtPath:databasePath];
    if (!isExist) {
        [[NSFileManager defaultManager] createDirectoryAtPath:databasePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *aigoPath = [[databasePath stringByAppendingPathComponent:[X_SQL instance].sqlName] stringByAppendingPathExtension:@"sqlite"];
    NSLog(@"数据库路径：%@",aigoPath);
    return aigoPath;
}

/// 数据库名称
+ (NSString *) defaultSqlName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    return [NSString stringWithFormat:@"X_SQL_%@",app_Name];
}

/// 通过sql文件获取sql语句
+ (NSArray<NSString *> *) getSqlWithName:(NSString *) name {
    NSString *sql_path = [[NSBundle mainBundle ] pathForResource:name ofType:nil];
    NSError *error;
    NSString *sql_text = [NSString stringWithContentsOfFile:sql_path encoding:NSUTF8StringEncoding error: &error];
    if (error) return nil;
    sql_text = [sql_text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSArray *sqls = [sql_text componentsSeparatedByString:@";"];
    /// 忽略数组中空字符串
    NSArray *results = [sqls filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    return results;
}

+ (NSDictionary<NSString *,id> *) object:(id) object {
    NSDictionary *keyValue;
    if ([object isKindOfClass:[NSObject class]]) {
        keyValue = [object argumentPropertyInfo];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        keyValue = [object copy];
    } else {
        NSAssert(false, @"传入的类型不正确，只能传NSObject对象或者NSDictionary字典");
    }
    return keyValue;
}

//MARK: 增

/// 新增表字段
+ (BOOL) addTableName:(NSString *) tableName
                  key:(NSString *) key
                 type:(NSString *) type
                   db:(FMDatabase *) db {
    BOOL success = false;
    if (![db columnExists:key inTableWithName:tableName]) {
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@",tableName,key,type];
        success = [db executeUpdate:sql];
        NSLog(@"表【%@】新增字段【%@】【%@】",tableName,key,success ? @"成功" : @"失败");
    }
    return success;
}

/// 插入数据
+ (BOOL) insertTableName:(NSString *) tableName
                  object:(id) object
                      db:(FMDatabase *) db {
    NSDictionary *keyValue = [self object:object];
    NSMutableArray *value_marks = [NSMutableArray arrayWithCapacity:keyValue.allKeys.count];
    for (int i = 0; i < keyValue.allKeys.count; i ++) [value_marks addObject:@"?"];
    NSString *value_sql = [value_marks componentsJoinedByString:@","];
    NSString *key_sql = [keyValue.allKeys componentsJoinedByString:@","];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) values(%@)",tableName,key_sql,value_sql];
    BOOL success = [db executeUpdate:sql withArgumentsInArray:keyValue.allValues];
    NSLog(@"表【%@】新增数据【%@】记录【%@】",tableName,keyValue.allKeys ,success ? @"成功" : @"失败");
    return success;
}

//MARK: 改

/// 修改表字段
+ (BOOL) changeTableName:(NSString *) tableName
                  oldKey:(NSString *) oldKey
                  newKey:(NSString *) newKey
                 newType:(NSString *) type
                      db:(FMDatabase *) db {
    BOOL success = false;
    if ([db columnExists:oldKey inTableWithName:tableName]) {
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ CHANGE COLUMN %@ %@ %@",tableName,oldKey,newKey,type];
        success = [db executeUpdate:sql];
        NSLog(@"表【%@】字段【%@】修改为【%@】%@",tableName,oldKey,newKey,success ? @"成功" : @"失败");
    }
    return success;
}

/// 更新数据
+ (BOOL) updateTableName:(NSString *) tableName
                   field:(NSString *) field
                   value:(id) value
                  object:(id) object
                      db:(FMDatabase *) db {
    NSDictionary *keyValue = [self object:object];
    NSMutableString *param = @"".mutableCopy;
    [keyValue.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [param appendFormat:@" %@ = ? %@",obj,(idx == keyValue.allKeys.count - 1) ?  @"" : @","];
    }];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = %@",tableName,param,field,value];
    BOOL success = [db executeUpdate:sql withArgumentsInArray:keyValue.allValues];
    NSLog(@"表【%@】更新数据【%@】记录【%@】",tableName,keyValue ,success ? @"成功" : @"失败");
    return success;
}

//MARK: 查

/// 通过一个参数查询表数据的数量 value为NSNumber或者NSString
+ (NSUInteger) getRecordCountByTable:(NSString *) tableName
                                 key:(NSString *) key
                               value:(id) value {
    return [self getRecordCountByTable:tableName key1:key value1:value key2:@"" value2:@""];
}

/// 通过两个参数查询表数据的数量 value为NSNumber或者NSString
+ (NSUInteger) getRecordCountByTable:(NSString *) tableName
                                key1:(NSString *) key1
                              value1:(id) value1
                                key2:(NSString *) key2
                              value2:(id) value2 {
    NSMutableDictionary *keyValue = @{}.mutableCopy;
    if (key1 != nil && ![key1  isEqualToString: @""] && value1 != nil && ![value1 isEqual:@""]) {
        [keyValue setObject:value1 forKey:key1];
    }
    if (key2 != nil && ![key2  isEqualToString: @""] && value2 != nil && ![value2 isEqual:@""]) {
        [keyValue setObject:value2 forKey:key2];
    }
    return [self getRecordCountByTable:tableName object:keyValue];
}

/// 通过多个参数查询表数据的数量
+ (NSUInteger) getRecordCountByTable:(NSString *) tableName
                              object:(id) object {
    NSDictionary *keyValue = [self object:object];
    __block NSUInteger count = 0;
    [[X_SQL instance].dbQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            FMResultSet *rs;
            NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT count(*) FROM %@",tableName];
            [keyValue.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                [sql appendFormat:@" %@ %@ = %@", (idx > 0 ? @"AND" : @"WHERE"), key, keyValue[key]];
                NSLog(@"sql:%@",sql);
            }];
            rs = [db executeQuery:sql];
            if ([rs next]) count = [rs intForColumnIndex:0];
        }
    }];
    return count;
}

/// 查询表数据（多参数查询为AND）
+ (FMResultSet *) queryTableName:(NSString *) tableName
                          object:(id) object
                              db:(FMDatabase *) db {
    NSDictionary *keyValue = [self object:object];
    NSMutableString *param = @"".mutableCopy;
    [keyValue.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [param appendFormat:@" %@ = ? %@",obj,(idx == keyValue.allKeys.count - 1) ?  @"" : @"AND"];
    }];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE%@",tableName,param];
    NSLog(@"查询表【%@】数据：【 %@】",tableName,sql);
    FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:keyValue.allValues];
    return rs;
}


@end
