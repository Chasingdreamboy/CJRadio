//
//  RadioButtons.m
//  RadioButtonsDemo
//
//  Created by lichq on 7/8/15.
//  Copyright (c) 2015 ciyouzen. All rights reserved.
//

#import "RadioButtons.h"

#define kDefaultMaxShowCount 5


@interface RadioButtons () {
    BOOL _haveArrowButton;
    UIButton *_leftArrowButton; /**< 左侧箭头 */
    UIButton *_rightArrowButton;/**< 右侧箭头 */
    CGFloat _arrowImageWidth;   /**< 箭头宽度 */
}
@property (nonatomic, assign) NSInteger maxShowViewCount;

@end


@implementation RadioButtons
@synthesize sv;
//@synthesize arrowImageWidth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initizalScrollView];
    }
    return self;
}

- (void)awakeFromNib{
    [self initizalScrollView];
}

- (void)initizalScrollView{
#pragma mark - 当scrollView位于第一个子视图时，其会对内容自动调整。如果你不想让scrollView的内容自动调整，可采取如下两种方法中的任一一种(这里采用第一种)。方法一：取消添加lab，以使得scrollView不是第一个子视图，从而达到取消scrollView的自动调整效果方法二：automaticallyAdjustsScrollViewInsets：如果你不想让scrollView的内容自动调整，将这个属性设为NO（默认值YES）。详细情况可参考evernote笔记中的UIStatusBar笔记内容
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectZero];
    [self addSubview:lab];
    
    [self addScrollViewForTab];
}

- (void)addScrollViewForTab{
    sv = [[UIScrollView alloc]initWithFrame:CGRectZero];
    sv.showsVerticalScrollIndicator = NO;
    sv.showsHorizontalScrollIndicator = NO;
    sv.delegate = self;
    sv.bounces = NO;
    sv.backgroundColor = [UIColor orangeColor];
    
    [self addSubview:sv];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat totalHeight = CGRectGetHeight(self.frame);
    CGFloat totalWidth = CGRectGetWidth(self.frame);
    
    NSInteger showViewCount = MIN(radioButtons.count, self.maxShowViewCount);
    CGFloat sectionWidth = totalWidth/showViewCount;
    sectionWidth = ceilf(sectionWidth); //重点注意：这里为了避免计算出来的值受除后，余数太多(eg:102.66666666666667)，而造成的之后在通过左右箭头点击来寻找”要找的按钮“的时候，计算出现问题（”要找的按钮“需与“左右侧箭头的最左最右侧值”进行精确的比较），所以这里我们需要一个整数值，故我们这边选择向上取整。
    
    [sv setFrame:CGRectMake(0, 0, totalWidth, totalHeight)];
    [sv setContentSize:CGSizeMake(sectionWidth * radioButtons.count, totalHeight)]; //设置sv.contentSize
    
    for (NSInteger i = 0; i < radioButtons.count; i++) {
        RadioButton *radioButton = [radioButtons objectAtIndex:i];
        
        CGRect rect_radioButton = CGRectMake(sectionWidth*i, 0, sectionWidth, self.frame.size.height);
        [radioButton setFrame:rect_radioButton];
        
        if (i == self.index_cur && self.shouldMoveScrollViewToSelectItem) {
            [self shouldMoveScrollViewToSelectItem:radioButton];//改名addAnimation
        }
    }
    
    for (NSInteger i = 0; i < lineViews.count; i++) {
        UIView *lineView = [lineViews objectAtIndex:i];
        CGRect rect_line = CGRectMake(sectionWidth*(i+1), 5, 1, self.frame.size.height - 10);
        [lineView setFrame:rect_line];
    }
    
    /* 如果有左右箭头 */
    if (_haveArrowButton) {
        CGFloat leftArrowButtonHeight = totalHeight;
        CGFloat leftArrowButtonY = 0;
        CGFloat leftArrowButtonWidth = _arrowImageWidth;
        CGFloat leftArrowButtonX = 0;
        [_leftArrowButton setFrame:CGRectMake(leftArrowButtonX,
                                             leftArrowButtonY,
                                             leftArrowButtonWidth,
                                             leftArrowButtonHeight)];
        
        
        CGFloat rightArrowButtonHeight = totalHeight;
        CGFloat rightArrowButtonY = 0;
        CGFloat rightArrowButtonWidth = _arrowImageWidth;
        CGFloat rightArrowButtonX = totalWidth - rightArrowButtonWidth;
        [_rightArrowButton setFrame:CGRectMake(rightArrowButtonX,
                                              rightArrowButtonY,
                                              rightArrowButtonWidth,
                                              rightArrowButtonHeight)];
    }
}

- (void)setTitles:(NSArray *)titles radioButtonNidName:(NSString *)nibName {
    [self setTitles:titles radioButtonNidName:nibName andShowIndex:-1 withMaxShowViewCount:kDefaultMaxShowCount];
}

- (void)setTitles:(NSArray *)titles radioButtonNidName:(NSString *)nibName withMaxShowViewCount:(NSInteger)maxShowViewCount {
    [self setTitles:titles radioButtonNidName:nibName andShowIndex:-1 withMaxShowViewCount:maxShowViewCount];
}

- (void)setTitles:(NSArray *)titles radioButtonNidName:(NSString *)nibName andShowIndex:(NSInteger)showIndex withMaxShowViewCount:(NSInteger)maxShowViewCount {
    NSAssert(titles.count >= 3, @"the min count of the titles is 3");
    NSAssert(nibName != nil, @"radioButton的nibName未设置，请检查");
    
    
    self.maxShowViewCount = maxShowViewCount;
    
    NSInteger sectionNum = [titles count];
    if (sectionNum == 0) {
        NSLog(@"error: [titles count] == 0");
    }
    countTitles = sectionNum;
    
    self.index_cur = showIndex; //如果self.index_cur = -1，则代表未有任何radioButton选中
    
    //添加radioButton到sv中
    radioButtons = [[NSMutableArray alloc] init];
    lineViews = [[NSMutableArray alloc] init];
    for (int i = 0; i <sectionNum; i++) {
        NSArray *radioButtonNib = [[NSBundle mainBundle]loadNibNamed:nibName owner:nil options:nil];
        RadioButton *radioButton = [radioButtonNib lastObject];
        
        radioButton.index = i;
        [radioButton setTitle:titles[i]];
        radioButton.delegate = self;
        radioButton.tag = RadioButton_TAG_BEGIN + i;
        if (i == showIndex) {
            [radioButton setSelected:YES];
        }else{
            [radioButton setSelected:NO];
        }
        [self.sv addSubview:radioButton];
        [radioButtons addObject:radioButton];
        
        if (i < sectionNum && i != 0) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
            lineView.backgroundColor = [UIColor lightGrayColor];
            [self.sv addSubview:lineView];
            [lineViews addObject:lineView];
        }
    }
}

//注意radioButton_cur经常有未选中的状态，即经常会有self.index_cur == -1的情况
- (void)radioButtonClick:(RadioButton *)radioButton_cur{
    
    NSInteger index_old = self.index_cur;
    self.index_cur = radioButton_cur.tag - RadioButton_TAG_BEGIN;
    
    BOOL isSameIndex = self.index_cur == index_old ? YES : NO;
    //NSLog(@"index_cur = %zd, index_old = %zd, isSameIndex= %@", self.index_cur,index_old,isSameIndex?@"YES":@"NO");
    
    if (index_old == -1) {//如果当前没有radioButton是被选中。
        
    }else{  //index_old != -1，即表示如果当前有radioButton是被选中。
        if (index_old == self.index_cur) {
            isSameIndex = YES;
            
        }else{
            //如果有选中,且点击不同index的话，则还需要把之前的那个按钮的状态也改变掉。
            RadioButton *radioButton_old = (RadioButton *)[self viewWithTag:RadioButton_TAG_BEGIN + index_old];
            radioButton_old.selected = !radioButton_old.selected;
        }
    }
    
    
    BOOL shouldUpdateCurrentRadioButtonSelected = [self shouldUpdateRadioButtonSelected_WhenClickSameRadioButton];//设默认不可重复点击（YES:可重复点击  NO:不可重复点击）
    if (isSameIndex) {
        if (shouldUpdateCurrentRadioButtonSelected) {
            radioButton_cur.selected = !radioButton_cur.selected;
        }
        
    }else{
        radioButton_cur.selected = !radioButton_cur.selected;
    }
    
    if([self.delegate respondsToSelector:@selector(radioButtons:chooseIndex:oldIndex:)]){
        [self.delegate radioButtons:self chooseIndex:self.index_cur oldIndex:index_old];
        
        if (isSameIndex && shouldUpdateCurrentRadioButtonSelected) { //此条if语句位置待确定
            [self setSelectedNone];
        }
    }
}



- (BOOL)shouldUpdateRadioButtonSelected_WhenClickSameRadioButton{
    switch (self.radioButtonType) {
        case RadioButtonTypeNormal:{
            return NO;
            break;
        }
        case RadioButtonTypeCanDrop:{
            return YES;
            break;
        }
        case RadioButtonTypeCanSlider:{
            return NO;
            break;
        }
        default:{
            return NO;
            break;
        }
    }
    return NO;  //设默认不可重复点击（YES:可重复点击  NO:不可重复点击）
}


//add
- (void)radioButtons_didSelectInExtendView:(NSString *)title {
    RadioButton *radioButton_cur = (RadioButton *)[self viewWithTag:RadioButton_TAG_BEGIN + self.index_cur];
    radioButton_cur.selected = !radioButton_cur.selected;
    [radioButton_cur setTitle:title];
    
    [self cj_hideDropDownExtendView];
    [self setIndex_cur:-1];
}


- (void)changeCurrentRadioButtonStateAndTitle:(NSString *)title{
    RadioButton *radioButton_cur = (RadioButton *)[self viewWithTag:RadioButton_TAG_BEGIN + self.index_cur];
    radioButton_cur.selected = !radioButton_cur.selected;
    [radioButton_cur setTitle:title];
}

- (void)changeCurrentRadioButtonState{
    RadioButton *radioButton_cur = (RadioButton *)[self viewWithTag:RadioButton_TAG_BEGIN + self.index_cur];
    radioButton_cur.selected = !radioButton_cur.selected;
}

- (void)setSelectedNone{
    self.index_cur = -1;
}

#pragma mark - 有左右箭头时候常会用到的方法
/**
 *  滚动到指定的单选按钮 targetRadioButton 上 （当按钮太多显示不全时常需要设置这个为YES）
 *
 *  @param targetRadioButton 要滚动到的指定按钮
 */
- (void)shouldMoveScrollViewToSelectItem:(RadioButton *)targetRadioButton {//滑动scrollView到显示出完整的targetRadioButton
    //该item的距离计算。
    //CGFloat leftX = CGRectGetMinX(targetRadioButton.frame);
    CGFloat rightX = CGRectGetMaxX(targetRadioButton.frame);
    
    if (rightX >= self.frame.size.width - 60) { //如果rightX离self.frame边缘太近(小于40)就要移动,设移动距离为moveOffset
        CGFloat moveOffset = self.frame.size.width/2 + 40;
        CGFloat rightX_new;
        
        if (rightX + moveOffset >= self.sv.contentSize.width) {//如果向左移动moveOffset后，会超出边界，则移动到末尾
            moveOffset = self.frame.size.width;
            rightX_new = self.sv.contentSize.width - moveOffset;
            
            [self.sv setContentOffset:CGPointMake(rightX_new, self.sv.contentOffset.y) animated:YES];
        }else{
            
            rightX_new = rightX - moveOffset;
            
            if (rightX_new > 0) {
                [self.sv setContentOffset:CGPointMake(rightX_new, self.sv.contentOffset.y) animated:YES];
            }
        }
        
    }else{
        [self.sv setContentOffset:CGPointMake(0, self.sv.contentOffset.y) animated:YES];
    }
}

/** 完整的描述请参见文件头部 */
- (void)addLeftArrowImage:(UIImage *)leftArrowImage
          rightArrowImage:(UIImage *)rightArrowImage
      withArrowImageWidth:(CGFloat)arrowImageWidth {
    
    _haveArrowButton = YES;
    _arrowImageWidth = arrowImageWidth;
    
    //创建左滑动箭头
    _leftArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftArrowButton setFrame:CGRectZero];
    [_leftArrowButton setBackgroundImage:leftArrowImage forState:UIControlStateNormal];
    [_leftArrowButton addTarget:self action:@selector(leftArrowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftArrowButton];
    
    //创建右滑动箭头
    _rightArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightArrowButton setFrame:CGRectZero];
    [_rightArrowButton setBackgroundImage:rightArrowImage forState:UIControlStateNormal];
    [_rightArrowButton addTarget:self action:@selector(rightArrowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightArrowButton];
    
    
    //刚开始隐藏左箭头，显示右箭头
    _leftArrowButton.hidden = YES;
    _rightArrowButton.hidden = NO;
}

//左箭头点击
- (void)leftArrowButtonAction:(UIButton *)sender {
    CGFloat contentOffsetX = self.sv.contentOffset.x;
    
    RadioButton *targetRadioButton = nil;
    for (NSInteger i = 0; i < countTitles; i++) { //从第一个开始找，找到的第一个即是所求
        RadioButton *radioButton = (RadioButton *)[self viewWithTag:RadioButton_TAG_BEGIN + i];
        
        /* 确保”要找的按钮“的左侧至少在显示的“左侧箭头的最右侧值”之左 */
        if (CGRectGetMinX(radioButton.frame) >= contentOffsetX + CGRectGetMaxX(_leftArrowButton.frame)) {
            continue;
        }
        
        /* 同时确保”要找的按钮“的右侧要至少在显示的“左侧箭头的最右侧值”之右 */
        if (CGRectGetMaxX(radioButton.frame) < contentOffsetX + CGRectGetMaxX(_leftArrowButton.frame)) {
            continue;
        }
        
        targetRadioButton = radioButton;
        NSLog(@"left: targetRadioButtonText = %@", targetRadioButton.lab.text);
        break;
    }
    
    /* 移动操作 */
    CGFloat newContentOffsetX;
    BOOL isFirstRadioButton = (targetRadioButton.index == 0) ? YES : NO;
    if (!isFirstRadioButton) {
        newContentOffsetX = CGRectGetMinX(targetRadioButton.frame) - CGRectGetWidth(_leftArrowButton.frame); //注意这里是减
    } else {
        newContentOffsetX = CGRectGetMinX(targetRadioButton.frame);
    }
    
    [self.sv setContentOffset:CGPointMake(newContentOffsetX, self.sv.contentOffset.y) animated:YES];
}

//右箭头点击
- (void)rightArrowButtonAction:(UIButton *)sender {
    CGFloat contentOffsetX = self.sv.contentOffset.x;
    
    RadioButton *targetRadioButton = nil;
    for (NSInteger i = 0; i < countTitles; i++) {   //从最后一个开始找，找到的第一个即是所求
        RadioButton *radioButton = (RadioButton *)[self viewWithTag:RadioButton_TAG_BEGIN + i];
        
        /* 确保”要找的按钮“的左侧至少在显示的“右侧箭头的最左侧值”  显示的屏幕的最左侧之右 */
        if (i == 3) {
            NSLog(@"i = %ld, %.1f, %.1f", i, CGRectGetMinX(radioButton.frame), contentOffsetX);
        }
        if (CGRectGetMinX(radioButton.frame) - contentOffsetX < 0) {
            continue;
        }
        
        /* 同时确保”要找的按钮“的右侧要至少在显示的“右侧箭头的最左侧值”之右 */
        //尤其注意：这里的btnArrowR不是添加在scrollView上的，所以不要忘了要加上contentOffsetX来比较
        if (CGRectGetMaxX(radioButton.frame) <= contentOffsetX + CGRectGetMinX(_rightArrowButton.frame)) {
            continue;
        }
        targetRadioButton = radioButton;
        NSLog(@"right: targetRadioButtonText = %@", targetRadioButton.lab.text);
        
        break;
    }
    
    /* 移动操作 */
    CGFloat rightAddMoveOffset;
    BOOL isLastRadioButton = (targetRadioButton.index == countTitles - 1) ? YES : NO;
    if (!isLastRadioButton) {
        rightAddMoveOffset = CGRectGetMaxX(targetRadioButton.frame) - (contentOffsetX + CGRectGetMinX(_rightArrowButton.frame));
    } else {
        rightAddMoveOffset = CGRectGetMaxX(targetRadioButton.frame) - (contentOffsetX + CGRectGetWidth(self.sv.frame));
    }
    CGFloat newContentOffsetX = self.sv.contentOffset.x + rightAddMoveOffset;
    [self.sv setContentOffset:CGPointMake(newContentOffsetX, self.sv.contentOffset.y) animated:YES];
}

/** 完整的描述请参见文件头部 */
- (void)selectRadioButtonIndex:(NSInteger)index{
    RadioButton *radioButton_old = (RadioButton *)[self viewWithTag:RadioButton_TAG_BEGIN + self.index_cur];
    radioButton_old.selected = NO;
    
    RadioButton *radioButton_cur = (RadioButton *)[self viewWithTag:RadioButton_TAG_BEGIN + index];
    radioButton_cur.selected = YES;
    [self shouldMoveScrollViewToSelectItem:radioButton_cur];
    
    self.index_cur = index;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_haveArrowButton) {
        if (scrollView.contentOffset.x == 0) {
            _leftArrowButton.hidden = YES;
            _rightArrowButton.hidden = NO;
        }else if (scrollView.contentOffset.x+scrollView.frame.size.width == scrollView.contentSize.width) {
            _leftArrowButton.hidden = NO;
            _rightArrowButton.hidden = YES;
        }else {
            _leftArrowButton.hidden = NO;
            _rightArrowButton.hidden = NO;
        }
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
