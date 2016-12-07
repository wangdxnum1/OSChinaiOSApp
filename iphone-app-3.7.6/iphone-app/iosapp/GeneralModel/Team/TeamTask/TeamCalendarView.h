//
//  TeamCalendarView.h
//  iosapp
//
//  Created by Holden on 15/5/28.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamCalendarView;
@protocol DatePickViewDelegate <NSObject>
@optional
-(void)removeCalendarView;
-(void)didSelectDate:(NSDate*)date;
-(void)clearSelectedDate;
@end

@interface TeamCalendarView : UIView
@property(nonatomic,strong)UIToolbar *toolbar;
@property(nonatomic,strong)UIDatePicker *datePickView;
@property (nonatomic,strong)NSDate *selectedDate;
@property (nonatomic) id<DatePickViewDelegate> delegate;

-(instancetype)initWithSelectedDate:(NSDate*)date;
@end
