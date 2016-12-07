//
//  BlogRewardAlertView.h
//  iosapp
//
//  Created by 李萍 on 16/10/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BlogRewardAlertViewDelegate <NSObject>

@optional
- (void)rewardAlertView:(id)alertView clickedButtonMoney:(long)money isChange:(BOOL)isChange isReward:(BOOL)isReward;

@end

@interface BlogRewardAlertView : UIView

@property (nonatomic, strong) UIView *rewardAlertView;//整体弹出框

@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *textField; //输入打赏金额
@property (nonatomic, assign) long moneyNum;

@property (nonatomic, assign) id <BlogRewardAlertViewDelegate> delegate;

@end
