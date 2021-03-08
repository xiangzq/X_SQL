//
//  AigoSQL.h
//  AigoClient
//
//  Created by 项正强 on 2021/1/4.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
NS_ASSUME_NONNULL_BEGIN

//MARK: object参数介绍
/**
 以下方法中出现的object字段类型只能传NSObject对象，或者NSDictionary
 如果使用NSObject对象，请参照：
 A * a = [A new];
 a.m = m;
 a.n = n;
 [a setArgumentPropertyName:@"m,n"];
 如果使用NSDictionary,请参照：
 NSDictionary *a = @{@"m":m,@"n":n};
 */

@interface X_SQL : NSObject
@property (nonatomic,strong,readonly) FMDatabaseQueue *dbQueue;
/// 设置数据库名称，默认请传nil
+ (X_SQL *) setSqlName:(NSString * _Nullable ) name;

/// 通过sql文件名获取所有sql语句
+ (NSArray<NSString *> *) getSqlWithName:(NSString *) name;

//MARK: 增

/**
 *新增表字段
 *@param tableName 表名
 *@param key 字段名
 *@param type 字段类型
 *@param db 数据库对象
 */
+ (BOOL) addTableName:(NSString *) tableName
                  key:(NSString *) key
                 type:(NSString *) type
                   db:(FMDatabase *) db;

//MARK: 改

/**
 *修改表字段
 *@param tableName 表名
 *@param oldKey 旧字段名
 *@param newKey 新字段名
 *@param type    新字段类型
 *@param db 数据库对象
 */
+ (BOOL) changeTableName:(NSString *) tableName
                  oldKey:(NSString *) oldKey
                  newKey:(NSString *) newKey
                 newType:(NSString *) type
                      db:(FMDatabase *) db;

/**
 *插入数据
 *@param tableName 表名
 *@param object  该字段介绍见顶部代码
 *@param db 数据库对象
 */
+ (BOOL) insertTableName:(NSString *) tableName
                  object:(id) object
                      db:(FMDatabase *) db;

/**
 *更新数据
 *@param tableName 表名
 *@param field  条件字段名
 *@param value  条件字段值
 *@param object  该字段介绍见顶部代码
 *@param db 数据库对象
 */
+ (BOOL) updateTableName:(NSString *) tableName
                   field:(NSString *) field
                   value:(id) value
                  object:(id) object
                      db:(FMDatabase *) db;

//MARK: 查

/**
 *通过一个参数查询表数据的数量
 *@param tableName 表名
 *@param key  字段名
 *@param value 字段值 类型为NSNumber或者NSString
 */
+ (NSUInteger) getRecordCountByTable:(NSString *) tableName
                                 key:(NSString *) key
                               value:(id) value;

/**
 *通过两个参数查询表数据的数量
 *@param tableName 表名
 *@param key1 字段名
 *@param value1 字段值 类型为NSNumber或者NSString
 *@param key2 字段名
 *@param value2 字段值 类型为NSNumber或者NSString
 */
+ (NSUInteger) getRecordCountByTable:(NSString *) tableName
                                key1:(NSString *) key1
                              value1:(id) value1
                                key2:(NSString *) key2
                              value2:(id) value2;

/**
 *通过多个参数查询表数据的数量
 *@param tableName 表名
 *@param object  该字段介绍见顶部代码
 */
+ (NSUInteger) getRecordCountByTable:(NSString *) tableName
                              object:(id) object;



/**
 *查询表数据（多参数查询为AND）
 *@param tableName 表名
 *@param object  该字段介绍见顶部代码
 *@param db 数据库对象
 */
+ (FMResultSet *) queryTableName:(NSString *) tableName
                          object:(id) object
                              db:(FMDatabase *) db;
@end

NS_ASSUME_NONNULL_END
