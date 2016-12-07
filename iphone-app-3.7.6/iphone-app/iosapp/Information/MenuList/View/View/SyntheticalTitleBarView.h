//
//  SyntheticalTitleBarView.h
//  iosapp
//
//  Created by 王恒 on 16/10/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleBarView.h"

@protocol SyntheticalTitleBarDelegate <NSObject>

- (void)addBtnClickWithIsBeginEdit:(BOOL)isEdit;

- (void)titleBtnClickWithIndex:(NSInteger)index;

- (void)closeSyntheticalTitleBarView;

@end

@interface SyntheticalTitleBarView : UIView

@property (nonatomic,assign)id<SyntheticalTitleBarDelegate> delegate;

@property (nonatomic,assign)CGRect titleBarFrame;

@property (nonatomic,strong)TitleBarView *titleBar;

- (instancetype)initWithFrame:(CGRect)frame
                   WithTitles:(NSArray *)titleArray;

/**重置所有的btn*/
- (void)reloadAllButtonsOfTitleBarWithTitles:(NSArray *)titles;

- (void)scrollToCenterWithIndex:(NSInteger)index;

- (void)ClickCollectionCellWithIndex:(NSInteger)index;

- (void)endAnimation;

- (void)addClick;

@end
