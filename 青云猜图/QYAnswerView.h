//
//  QYAnswerView.h
//  青云猜图
//
//  Created by qingyun on 16/2/24.
//  Copyright © 2016年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYAnswerView : UIView
@property (nonatomic, strong) void (^answerBtnAction)(UIButton *answerBtn);
//声明answerBtnIndexs,用来保存当前题目需要填充的answerBtn的索引（在answerView的subViews中的索引）
@property (nonatomic, strong) NSMutableArray *answerBtnIndexs;

//声明初始化方法
+ (instancetype) answerViewWithAnswerCount:(NSInteger)answerCount;
@end
