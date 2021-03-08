//
//  NSObject+XProperty.h
//  AigoClient
//
//  Created by 项正强 on 2021/1/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (XProperty)
/** 示例
 A * a = [A new];
 a.m = m;
 a.n = n;
 [a setArgumentPropertyName:@"m,n"];
 */

/// 当前对象正在赋值的属性属性名,多个属性名用逗号隔开
@property (nonatomic,copy,readwrite) NSString *argumentPropertyName;
/// 获取当前对象正在赋值的属性/属性值
- (NSDictionary<NSString *,id> *) argumentPropertyInfo;
/// 获取对象被（赋值/初始化）过的所有属性,属性值  注意：对象的属性如果没有进行初始化，则会忽略该属性
-(NSDictionary<NSString *,id> *) getInitPropertyInfo;
/// 获取对象所有属性名
- (NSArray<NSString *> *) getAllPropertyNames;
@end

NS_ASSUME_NONNULL_END
