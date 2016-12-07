//
//  OSCMessageCenterController.m
//  iosapp
//
//  Created by Graphic-one on 16/8/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCMessageCenterController.h"

#import "OSCAtMeController.h"
#import "OSCCommentsController.h"
#import "OSCMessageController.h"

#import "Config.h"
#import "OSCObjsViewController.h"
#import "EventsViewController.h"
#import "FriendsViewController.h"
#import "MessagesViewController.h"
#import "OSCMessageController.h"
#import "MyTweetLikeListViewController.h"
#import "OSCNotice.h"

#import "UIButton+Badge.h"
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

@interface OSCMessageCenterController ()

@property (nonatomic, strong) NSArray *noticesCount;

@property (nonatomic, strong) NSMutableArray *viewAppeared;
@property (nonatomic, strong) NSMutableArray *viewRefreshed;

@property (nonatomic,strong) NSArray* titles;
@property (nonatomic,strong) NSArray* controllers;

@end

@implementation OSCMessageCenterController

- (instancetype)initWithNoticeCounts:(NSArray *)noticeCounts
{
    self = [super initWithTitle:@"消息中心" andSubTitles:self.titles andControllers:self.controllers underTabbar:NO];
    if (self) {
        _viewAppeared  = [NSMutableArray arrayWithArray:@[@(NO), @(NO), @(NO)]];
        _viewRefreshed = [NSMutableArray arrayWithArray:@[@(NO), @(NO), @(NO)]];
        
        __weak OSCMessageCenterController *weakSelf = self;
        [self.viewPager.controllers enumerateObjectsUsingBlock:^(OSCObjsViewController *vc, NSUInteger idx, BOOL *stop) {
            vc.didRefreshSucceed = ^ {
                UIButton *titleButton = weakSelf.titleBar.titleButtons[idx];
                if ([titleButton.badgeValue isEqualToString:@"0"]) {return;}
                
                weakSelf.viewRefreshed[idx] = @(YES);
                if ([weakSelf.viewAppeared[idx] boolValue] && [weakSelf.viewRefreshed[idx] boolValue]) {
                    [weakSelf markAsReaded:idx];
                }
            };
        }];
        
        self.viewPager.viewDidAppear = ^ (NSInteger index) {
            UIButton *titleButton = weakSelf.titleBar.titleButtons[index];
            if ([titleButton.badgeValue isEqualToString:@"0"]) {return;}
            
            weakSelf.viewAppeared[index] = @(YES);
            if ([weakSelf.viewAppeared[index] boolValue] && [weakSelf.viewRefreshed[index] boolValue]) {
                [weakSelf markAsReaded:index];
            }
        };
        
        [self dealWithNotices:noticeCounts autoScroll:YES];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeUpdateHandler:) name:OSCAPI_USER_NOTICE object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 处理消息通知

#pragma mark 处理badge

- (void)setBadgeValue:(NSString *)badgeValue forButton:(UIButton *)button
{
    if ([badgeValue isEqualToString:@"0"]) {
        [button setTitle:[NSString stringWithFormat:@"%@", [button.titleLabel.text substringToIndex:2]] forState:UIControlStateNormal];
        return;
    }
    
    [button setTitle:[NSString stringWithFormat:@"%@(%@)", [button.titleLabel.text substringToIndex:2], badgeValue] forState:UIControlStateNormal];
}


#pragma mark 处理提示

- (void)dealWithNotices:(NSArray *)noticeCounts autoScroll:(BOOL)needAutoScroll
{
    __block BOOL scrolled = NO;
    __block int sumOfCount = 0;

    [noticeCounts enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL *stop) {
        if (idx < 3) {
            [self setBadgeValue:[number stringValue] forButton:self.titleBar.titleButtons[idx]];
            sumOfCount += [number intValue];
            
            if (needAutoScroll && [number intValue] && !scrolled) {
                [self scrollToViewAtIndex:idx];
                scrolled = YES;
            }
        }
        
    }];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:sumOfCount];
}


#pragma mark 处理系统通知

- (void)noticeUpdateHandler:(NSNotification *)notification
{
    NSArray *noticeCounts = [notification object];
    OSCNotice *oldNotice = [Config getNotice];
    
    [self dealWithNotices:@[@([noticeCounts[0] intValue] + oldNotice.mention), @([noticeCounts[1] intValue] + oldNotice.review),@([noticeCounts[2] intValue] + oldNotice.letter)] autoScroll:NO];
}


- (void)markAsReaded:(NSInteger)idx
{
    OSCNotice *oldNotice = [Config getNotice];
    
    OSCNotice *notice = [OSCNotice new];
    
    notice.fans = oldNotice.fans;
    notice.like = oldNotice.like;

    switch (idx) {
        case 0:
        {
            notice.mention = 0;
            notice.letter = oldNotice.letter;
            notice.review = oldNotice.review;
        }
            break;
        case 1:
        {
            notice.mention = oldNotice.mention;
            notice.letter = oldNotice.letter;
            notice.review = 0;
        }
            break;
        case 2:
        {
            notice.mention = oldNotice.mention;
            notice.letter = 0;
            notice.review = oldNotice.review;
        }
            break;
        default:
            break;
    }
    [Config saveNotice:notice];
    
    UIButton *button = self.titleBar.titleButtons[idx];
    button.badge.hidden = YES;
    
    _viewAppeared[idx] = @(NO);
    _viewRefreshed[idx] = @(NO);
}


#pragma mark --- lazy loading
- (NSArray *)titles {
    if(_titles == nil) {
        _titles = @[@"@我",@"评论",@"私信"];
    }
    return _titles;
}
- (NSArray *)controllers {
    if(_controllers == nil) {
        _controllers = @[
                         [[OSCAtMeController alloc]init],
                         [[OSCCommentsController alloc]init],
                         [[OSCMessageController alloc]init]
                         ];
    }
    return _controllers;
}

@end
