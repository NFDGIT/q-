//
//  QYOptionView.h
//  青云猜图
//
//  Created by qingyun on 16/2/24.
//  Copyright © 2016年 qingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYOptionView : UIView
@property (nonatomic, strong) void (^optionBtnAction)(UIButton *optionBtn);

//optionView中optionBtn的标题
@property (nonatomic, strong) NSArray *btnTitles;
//声明初始化方法
+(instancetype)optionView;
@end
