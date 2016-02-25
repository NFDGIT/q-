//
//  QYOptionView.m
//  青云猜图
//
//  Created by qingyun on 16/2/24.
//  Copyright © 2016年 qingyun. All rights reserved.
//

#import "QYOptionView.h"

@implementation QYOptionView

+(instancetype)optionView{
    //从xib文件加载optionView
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"QYOptionView" owner:self options:nil];
    return views[0];
}

//重写btnTitles setter方法
-(void)setBtnTitles:(NSArray *)btnTitles{
    _btnTitles = btnTitles;
    
    //遍历optionView中optionBtn，然后设置标题，设置高亮状态下背景图片、添加事件监听（点击事件）
    for (int i = 0; i < btnTitles.count; i++) {
        UIButton *optionBtn = self.subviews[i];
        
        [optionBtn setTitle:btnTitles[i] forState:UIControlStateNormal];
        [optionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [optionBtn setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
        [optionBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}


-(void)btnClick:(UIButton *)sender{
    if (_optionBtnAction) {
        _optionBtnAction(sender);
    }
}

-(void)setFrame:(CGRect)frame{
    CGRect originFrame = self.frame;
    originFrame.origin = frame.origin;
    [super setFrame:originFrame];
}

@end
