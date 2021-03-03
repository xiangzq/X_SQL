//
//  AigoSQL.h
//  AigoClient
//
//  Created by 项正强 on 2021/1/4.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
NS_ASSUME_NONNULL_BEGIN

@interface X_SQL : NSObject

@property (nonatomic,strong,readonly) FMDatabaseQueue *dbQueue;

/// 设置数据库名称，默认请传nil
+ (void) setSqlName:(NSString * _Nullable ) name;

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
 *@param keys  字段名数组
 *@param values 字段值数组
 *@param db 数据库对象
 */
+ (BOOL) insertTableName:(NSString *)tableName
                    Keys:(NSArray<NSString *> *) keys
                  values:(NSArray<id> *) values
                      db:(FMDatabase *) db;

/**
 *更新数据
 *@param tableName 表名
 *@param field  条件字段名
 *@param value  条件字段值
 *@param keyValue 需要更新的字段
 *@param db 数据库对象
 */
+ (BOOL) updateTableName:(NSString *)tableName
                   field:(NSString *) field
                   value:(id) value
               KeyValue:(NSDictionary<NSString *,id> *) keyValue
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
 *@param keyValue  字段名:字段值
 */
+ (NSUInteger) getRecordCountByTable:(NSString *) tableName
                            keyValue:(NSDictionary<NSString *,id> *) keyValue;



/**
 *查询表数据（多参数查询为AND）
 *@param tableName 表名
 *@param keyValue 查询参数字段
 *@param db 数据库对象
 */
+ (FMResultSet *) queryTableName:(NSString *) tableName
                        keyValue:(NSDictionary *) keyValue
                              db:(FMDatabase *) db;
@end

NS_ASSUME_NONNULL_END
