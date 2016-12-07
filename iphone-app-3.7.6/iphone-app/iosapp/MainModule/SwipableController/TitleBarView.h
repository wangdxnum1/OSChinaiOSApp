//
//  TitleBarView.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-20.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleBarView : UIScrollView

@property (nonatomic, strong) NSMutableArray *titleButtons;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, copy) void (^titleButtonClicked)(NSUInteger index);

- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray*)titles;

-(instancetype)initWithFrame:(CGRect)frame
                   andTitles:(NSArray *)titles
               andNeedScroll:(BOOL)isNeedScroll;

- (void)setTitleButtonsColor;

- (void)scrollToCenterWithIndex:(NSInteger)index;

/**重置所有的btn*/
-(void)reloadAllButtonsOfTitleBarWithTitles:(NSArray *)titles;

@end
