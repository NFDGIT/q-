//
//  QYQuestion.m
//  青云猜图
//
//  Created by qingyun on 16/2/24.
//  Copyright © 2016年 qingyun. All rights reserved.
//

#import "QYQuestion.h"

@implementation QYQuestion

-(instancetype)initWithDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        //对属性进行赋值
        [self setValuesForKeysWithDictionary:dict];
        _answerCount = _answer.length;
    }
    return self;
}

+(instancetype)questionWithDictionary:(NSDictionary *)dict{
    return  [[self alloc]initWithDictionary:dict];
}
@end
