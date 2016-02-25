//
//  QYQuestion.h
//  青云猜图
//
//  Created by qingyun on 16/2/24.
//  Copyright © 2016年 qingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYQuestion : NSObject
//声明属性
@property (nonatomic, strong) NSString *answer;     //答案
@property (nonatomic, strong) NSString *icon;       //图片名称
@property (nonatomic, strong) NSString *title;      //提示
@property (nonatomic, strong) NSArray *options;     //题目对应的选项

@property (nonatomic) NSInteger answerCount;        //题目答案的长度
@property (nonatomic) BOOL isFinish;                //当前题目是否答过
@property (nonatomic) BOOL isHint;                  //当前题目是否提示过

//声明初始化方法
-(instancetype)initWithDictionary:(NSDictionary *)dict;
+(instancetype)questionWithDictionary:(NSDictionary *)dict;

@end
