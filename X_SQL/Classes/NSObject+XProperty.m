//
//  NSObject+XProperty.m
//  AigoClient
//
//  Created by 项正强 on 2021/1/6.
//

#import "NSObject+XProperty.h"
#import <objc/runtime.h>

static NSString *key_argumentPropertyName = @"key_argumentPropertyName";


@implementation NSObject (XProperty)

- (void)setArgumentPropertyName:(NSString *)argumentPropertyName {
    objc_setAssociatedObject(self, &key_argumentPropertyName, argumentPropertyName, OBJC_ASSOCIATION_COPY);
}

- (NSString *)argumentPropertyName {
    return objc_getAssociatedObject(self, &key_argumentPropertyName);
}

/// 获取当前对象正在赋值的属性/属性值
- (NSDictionary<NSString *,id> *) argumentPropertyInfo {
    if ([self.argumentPropertyName isEqualToString:@""] || self.argumentPropertyName == nil) {
        return [self getInitPropertyInfo];
    }
    NSString *format = self.argumentPropertyName;
    format = [format stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    format = [format stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray<NSString *> *propertyNames = [format componentsSeparatedByString:@","];
    NSMutableDictionary<NSString *,id> * propertyInfo = @{}.mutableCopy;
    [propertyNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = [self getInitPropertyInfo][obj];
        if (value) [propertyInfo setValue:value forKey:obj];
    }];
    return propertyInfo.copy;
}
/// 获取对象被（赋值/初始化）过的所有属性,属性值  ⚠️：对象的属性如果没有进行初始化，则会忽略该属性
-(NSDictionary<NSString *,id> *) getInitPropertyInfo {
    NSMutableDictionary *keyValue = [NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i <count; i++) {
        const char *char_f = property_getName(properties[i]);
        NSString *propertyKey = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:propertyKey];
        if (propertyValue) [keyValue setObject:propertyValue forKey:propertyKey];
//        NSLog(@"类【%@】的属性【%@】值为【%@】",NSStringFromClass([self class]),propertyKey,propertyValue);
    }
    free(properties);
    return keyValue;
}

/// 获取对象所有属性名
- (NSArray<NSString *> *) getAllPropertyNames {
    NSMutableArray *names = @[].mutableCopy;
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (NSUInteger i = 0 ; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        [names addObject:name];
    }
    free(properties);
    return names;
}
@end
