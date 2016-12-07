//
//  TeamCalendarView.m
//  iosapp
//
//  Created by Holden on 15/5/28.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamCalendarView.h"

#define GDeviceScreenWidth                     ([UIScreen mainScreen].bounds.size.width)
@implementation TeamCalendarView

-(instancetype)initWithSelectedDate:(NSDate*)date{
    
    self=[super init];
    if (self) {
        if (date) {
            _selectedDate = date;
        } else {
            _selectedDate = [NSDate date];
        }
        [self setUpSubViews];
    }
    return self;
}

-(void)setUpSubViews{
    
    UIToolbar *toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, GDeviceScreenWidth,40)];
    
    UIBarButtonItem *leftItem = [self setToolBarWithText:@"取消" action:@selector(remove)];
    UIBarButtonItem *centerLeftSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *midleItem = [self setToolBarWithText:@"清除" action:@selector(clearText)];
    UIBarButtonItem *centerRightSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *rightItem = [self setToolBarWithText:@"确定" action:@selector(didSelectDate)];
    toolbar.items=@[leftItem,centerLeftSpace,midleItem,centerRightSpace,rightItem];
    [self addSubview:toolbar];
    
    UIDatePicker *datePickView = [[UIDatePicker alloc] init];
    datePickView.datePickerMode = UIDatePickerModeDate;
    [datePickView setDate:_selectedDate animated:YES];
    datePickView.backgroundColor=[UIColor lightGrayColor];
    _datePickView=datePickView;
    datePickView.frame=CGRectMake(0, CGRectGetMaxY(toolbar.frame), GDeviceScreenWidth, CGRectGetHeight(datePickView.frame));
    [self addSubview:datePickView];
    
    self.frame = CGRectMake(0, 0, GDeviceScreenWidth, CGRectGetHeight(toolbar.frame)+CGRectGetHeight(_datePickView.frame));

}
-(UIBarButtonItem*)setToolBarWithText:(NSString*)text action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 40);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc]initWithCustomView:button];
    return bbi;
}
#pragma mark --DatePickerViewDelegate
-(void)didSelectDate
{
    if ([self.delegate respondsToSelector:@selector(didSelectDate:)]) {
        [self.delegate didSelectDate:_datePickView.date];
    }
}
-(void)clearText
{
    if ([self.delegate respondsToSelector:@selector(clearSelectedDate)]) {
        [self.delegate clearSelectedDate];
    }
}
-(void)remove
{
    if ([self.delegate respondsToSelector:@selector(removeCalendarView)]) {
        [self.delegate removeCalendarView];
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
