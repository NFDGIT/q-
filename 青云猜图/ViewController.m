//
//  ViewController.m
//  青云猜图
//
//  Created by qingyun on 16/2/24.
//  Copyright © 2016年 qingyun. All rights reserved.
//

#import "ViewController.h"
#import "QYQuestion.h"
#import "QYAnswerView.h"
#import "QYOptionView.h"
#import "Common.h"
@interface ViewController ()
{
    NSInteger index;            //每题的下标
}
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *coinBtn;

@property (nonatomic, strong) NSArray *questions;

@property (nonatomic, strong) QYAnswerView *answerView;
@property (nonatomic, strong) QYOptionView *optionView;
@end

@implementation ViewController

//懒加载
-(NSArray *)questions{
    if (_questions == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"questions" ofType:@"plist"];
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        //可变数组，存储转化后的模型
        NSMutableArray *questionModels = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            QYQuestion *question = [QYQuestion questionWithDictionary:dict];
            [questionModels addObject:question];
        }
        _questions = questionModels;
    }
    return _questions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //更新UI
    [self updateUI];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)btnClick:(UIButton *)sender {
    switch (sender.tag) {
        case 101://提示
            [self hint:sender];
            break;
        case 102://大图
            [self bigImage:sender];
            break;
        case 103://帮助
            
            break;
        case 104://下一题
            [self next];
            break;
            
        default:
            break;
    }
}

#pragma mark - 下一题和更新UI
//下一题
-(void)next{
    
    //定义一个bool变量来表示通关
    __block BOOL isPass = YES;
    [self.questions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        QYQuestion *question = (QYQuestion *)obj;
        if (!question.isFinish) {
            isPass = NO;
            *stop = YES;
        }
    }];
    
    //通关
    if (isPass) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"恭喜你通关了，是否再来一次" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.questions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                QYQuestion *question = (QYQuestion *)obj;
                question.isFinish = NO;
            }];
            index = -1;
            [self next];
        }];
        
        [alertController addAction:noAction];
        [alertController addAction:yesAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    //更改索引
    index++;
    //更新UI
    [self updateUI];
}

-(void)updateUI{
    //更改index，确保从数组中取question的时候，不越界
    index = index % self.questions.count;
    
    //获取当前题目对应的模型
    QYQuestion *question = self.questions[index];
    
    //如果index题目已经回答过，跳转下一题
    if (question.isFinish) {
        [self next];
        return;
    }
    
    //更新_numLabel的文本
    _numLabel.text = [NSString stringWithFormat:@"%ld/%ld",index + 1,self.questions.count];
    //更新_titleLabel的文本
    _titleLabel.text = question.title;
    //更新_imageView的图片
    _imageView.image = [UIImage imageNamed:question.icon];
    
    //添加answerView
    [_answerView removeFromSuperview];
    QYAnswerView *answerView = [QYAnswerView answerViewWithAnswerCount:question.answerCount];
    [self.view addSubview:answerView];
    //frame
    answerView.frame = CGRectMake(0, 350, 0, 0);
    _answerView = answerView;
    
    //answerBtn的点击事件
    __weak ViewController *weakSelf = self;
    answerView.answerBtnAction = ^(UIButton *answerBtn){
        [weakSelf answerBtnAction:answerBtn];
    };
    
    //添加optionView
    [_optionView removeFromSuperview];
    QYOptionView *optionView = [QYOptionView optionView];
    [self.view addSubview:optionView];
    //frame
    optionView.frame = CGRectMake(0, 430, 0, 0);
    _optionView = optionView;
    //对btnTitles赋值
    optionView.btnTitles = question.options;
    
    //optionBtn的点击事件
    
    optionView.optionBtnAction = ^(UIButton *optionBtn){
        //处理optionBtn的点击
        [weakSelf optionBtnAction:optionBtn];
    };
}


//提示
-(void)hint:(UIButton *)sender{
    //判断当前金币数是否不小于将要话费的金币
    if ([_coinBtn.currentTitle integerValue] < 1000) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"金币不足，请充值" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self changeCoin:10000];
        }];
        
        [alertController addAction:noAction];
        [alertController addAction:yesAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    //取出当前需要填写的answerBtn对应的正确答案
    QYQuestion *question = self.questions[index];
    NSInteger index1 = [_answerView.answerBtnIndexs.firstObject integerValue];
    NSRange range = NSMakeRange(index1, 1);
    NSString *answerBtnTitle = [question.answer substringWithRange:range];
    
    [_optionView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *optionBtn = (UIButton *)obj;
        if ([optionBtn.currentTitle isEqualToString:answerBtnTitle]) {
            //根据正确答案，模拟optionBtn的点击事件
            [self optionBtnAction:optionBtn];
            //标题提示状态
            question.isHint = YES;
            //减少金币
            [self changeCoin:-1000];
            *stop = YES;
        }
    }];
}


#pragma mark -answerBtn和optionBtn点击事件
//answerBtn点击事件
-(void)answerBtnAction:(UIButton *)answerBtn{
    if (answerBtn.currentTitle.length == 0) {
        return;
    }
    //显示optionView上对应的optionBtn
    UIButton *optionBtn = [_optionView viewWithTag:answerBtn.tag];
    optionBtn.hidden = NO;
    optionBtn.tag = answerBtn.tag = 0;
    //清除answerBtn的标题
    [answerBtn setTitle:nil forState:UIControlStateNormal];
    //更改answerBtn的标题的颜色（黑色）
    [self changeAnswerBtnTitleColor:[UIColor blackColor]];
    //把answerBtn在answerView的subViews中对应的索引，添加到answerBtnIndexs中，确保UI界面上需要填写的answerBtn跟answerBtnIndexs一致
    NSInteger answerBtnIndex = [_answerView.subviews indexOfObject:answerBtn];
    [_answerView.answerBtnIndexs addObject:@(answerBtnIndex)];
    //对answerBtnIndexs数组进行排序，确保填写的answerBtnTitle的时候是从左至右的
    NSArray *array = [_answerView.answerBtnIndexs sortedArrayUsingSelector:@selector(compare:)];
    _answerView.answerBtnIndexs = [NSMutableArray arrayWithArray:array];
}

//optionBtn的点击事件
-(void)optionBtnAction:(UIButton *)optionBtn{
    //判断answerBtnIndexs.count > 0
    if (_answerView.answerBtnIndexs.count > 0) {
        //1、隐藏optionBtn
        optionBtn.hidden = YES;
        //2、把optionBtn的标题填写到相应的answerBtn上
        //titleForState:按照不同状态来取标题，currentTitle当前界面显示的标题
        NSString *title = optionBtn.currentTitle;
        //取出需要填写的answerBtn的索引
        NSInteger answerBtnIndex = [_answerView.answerBtnIndexs.firstObject integerValue];
        //根据索引取出answerBtn
        UIButton *answerBtn = _answerView.subviews[answerBtnIndex];
        [answerBtn setTitle:title forState:UIControlStateNormal];
        //3、把answerView中的answerBtnIndexs中对应的索引删除，确保UI界面上需要填写的answerBtn跟answerBtnIndexs一致
        [_answerView.answerBtnIndexs removeObjectAtIndex:0];
        //把optionBtn和answerBtn的tag值设置一致，便于点击answerBtn的时候通过tag值找到optionBtn
        optionBtn.tag = answerBtn.tag = 100 + answerBtnIndex;
    }
    //判断是否填充完毕（把answerView上所有的answerBtn标题填充完整）
    if (_answerView.answerBtnIndexs.count == 0) {
        //判断当前填写的答案是否正确
        
        NSMutableString *answerString = [NSMutableString string];
        //obj 代表当前循环 对象（Button）
        //idx 代表当前循环  对象的下标
        //*stop 为yes的时候跳出循环 类似break
        [_answerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *answerBtn = (UIButton *)obj;
            [answerString appendString:answerBtn.currentTitle];
        }];
        
        //判断答案是否正确
        QYQuestion *question = self.questions[index];
        if ([question.answer isEqualToString:answerString]) {
            //如果正确,字体变绿、加金币、时隔1秒跳转下一题、标记当前题目的答题状态（已经答过）
            [self changeAnswerBtnTitleColor:[UIColor greenColor]];
            
            if (!question.isHint) {
                [self changeCoin:1000];
            }
            
            question.isFinish = YES;
            
            [self performSelector:@selector(next) withObject:nil afterDelay:1];
            
        }else{
           //如果错误，字体变红
            [self changeAnswerBtnTitleColor:[UIColor redColor]];
        }
    }
}

//加减金币
-(void)changeCoin:(NSInteger)num{
    //取出当前金币
    NSString *currentTitle = _coinBtn.currentTitle;
    NSInteger result = [currentTitle integerValue] + num;
    NSString *resultTitle = [NSString stringWithFormat:@"%ld",result];
    [_coinBtn setTitle:resultTitle forState:UIControlStateNormal];
}

//更改answerBtn标题颜色
-(void)changeAnswerBtnTitleColor:(UIColor *)color{
    [_answerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *answerBtn = (UIButton *)obj;
        [answerBtn setTitleColor:color forState:UIControlStateNormal];
    }];
}

#pragma mark - 大图、小图
-(void)bigImage:(UIButton *)sender{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    //设置frame、背景颜色、透明度
    btn.frame = self.view.frame;
    btn.backgroundColor = [UIColor yellowColor];
    btn.alpha = 0;
    
    //添加点击事件
    [btn addTarget:self action:@selector(smallImage:) forControlEvents:UIControlEventTouchUpInside];
    
    //把imageView置顶
    [self.view bringSubviewToFront:_imageView];
    
    //执行动画
    [UIView animateWithDuration:0.5 animations:^{
        _imageView.transform = CGAffineTransformScale(_imageView.transform, 1.5, 1.5);
        btn.alpha = 0.5;
    }];
}


//缩小
-(void)smallImage:(UIButton *)sender{
    [UIView animateWithDuration:0.5 animations:^{
        _imageView.transform = CGAffineTransformIdentity;
        sender.alpha = 0;
    } completion:^(BOOL finished) {
        [sender removeFromSuperview];
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
