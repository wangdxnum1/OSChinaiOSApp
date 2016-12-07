//
//  ActivityDetailsWithBarViewController.m
//  iosapp
//
//  Created by ChanAetern on 3/14/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

/* 弃用 */
#import "ActivityDetailsWithBarViewController.h"
#import "ActivityDetailsViewController.h"
#import "OSCAPI.h"
#import "CommentsBottomBarViewController.h"
#import "UMSocial.h"
#import "Config.h"
#import "Utils.h"
#import "OSCActivity.h"
#import "OSCPostDetails.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

@interface ActivityDetailsWithBarViewController () <UITextViewDelegate>

@property (nonatomic, strong) ActivityDetailsViewController *activityDetailsVC;

@property (nonatomic, assign) int64_t activityID;
@property (nonatomic, copy) NSString *activityTitle;
@property (nonatomic, assign) BOOL isStarred;
@property (nonatomic, copy) NSString *mURL;
@property (nonatomic, copy) NSString *URL;

@end

@implementation ActivityDetailsWithBarViewController

- (instancetype)initWithActivityID:(int64_t)activityID
{
    self = [super initWithModeSwitchButton:YES];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.title     = @"活动详情";
        
        _activityID = activityID;
        _activityDetailsVC = [[ActivityDetailsViewController alloc] initWithActivityID:activityID];
        _activityDetailsVC.bottomBarVC = self;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setLayout];
    self.operationBar.items = [self.operationBar.items subarrayWithRange:NSMakeRange(0, 12)];
    [self.editingBar.modeSwitchButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self setBlockForOperationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)setLayout
{
    [self.view addSubview:_activityDetailsVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"detailsView": _activityDetailsVC.view, @"editingBar": self.editingBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[detailsView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailsView][editingBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
}


- (void)setBlockForOperationBar
{
    __weak ActivityDetailsWithBarViewController *weakSelf = self;
    
    /********* 收藏 **********/
    
    self.operationBar.toggleStar = ^ {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        NSString *API = weakSelf.isStarred? OSCAPI_FAVORITE_DELETE: OSCAPI_FAVORITE_ADD;
        [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, API]
           parameters:@{
                        @"uid":   @([Config getOwnID]),
                        @"objid": @(weakSelf.activityID),
                        @"type":  @(2)
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
                  
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  if (errorCode == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.label.text = weakSelf.isStarred? @"删除收藏成功": @"添加收藏成功";
                      weakSelf.isStarred = !weakSelf.isStarred;
                      weakSelf.operationBar.isStarred = weakSelf.isStarred;
                  } else {
//                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                      HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  }
                  
                  [HUD hideAnimated:YES afterDelay:1];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
//                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.label.text = @"网络异常，操作失败";
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    };
    
    
    /********** 显示回复 ***********/
    
    self.operationBar.showComments = ^ {
        CommentsBottomBarViewController *commentsBVC = [[CommentsBottomBarViewController alloc] initWithCommentType:CommentTypePost andObjectID:weakSelf.activityID];
        [weakSelf.navigationController pushViewController:commentsBVC animated:YES];
    };
    
    
    /********** 分享设置 ***********/
    
    self.operationBar.share = ^ {
        NSString *title = weakSelf.activityDetailsVC.postDetails.title;
        NSString *URL   = weakSelf.activityDetailsVC.postDetails.url.absoluteString;
        
        // 微信相关设置
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
        [UMSocialData defaultData].extConfig.wechatSessionData.url = URL;
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = URL;
        [UMSocialData defaultData].extConfig.title = title;
        
        // 手机QQ相关设置
        [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
        [UMSocialData defaultData].extConfig.qqData.title = title;
        [UMSocialData defaultData].extConfig.qqData.url = URL;
        
        // 新浪微博相关设置
        [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:weakSelf.activityDetailsVC.postDetails.url.absoluteString];
        
        // 复制链接        
        [UMSocialSnsService presentSnsIconSheetView:weakSelf
                                             appKey:@"54c9a412fd98c5779c000752"
                                          shareText:[NSString stringWithFormat:@"《%@》，分享来自 %@", title, URL]
                                         shareImage:[UIImage imageNamed:@"logo"]
                                    shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                           delegate:nil];
    };
    
    
    _didScroll = ^ {
            [weakSelf.editingBar.editView resignFirstResponder];
            [weakSelf hideEmojiPageView];
    };
}

- (NSString *)mURL
{
    if (_mURL) {
        return _mURL;
    } else {
        _mURL = [NSString stringWithFormat:@"http://m.oschina.net/question/%lld_%lld", _activityDetailsVC.postDetails.authorID, _activityID];
        
        return _mURL;
    }
}



- (void)sendContent
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.label.text = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *URL;
    NSDictionary *parameters;
    
    URL = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_COMMENT_PUB];
    parameters = @{
                   @"catalog": @(2),
                   @"id": @(_activityID),
                   @"uid": @([Config getOwnID]),
                   @"content": [Utils convertRichTextToRawText:self.editingBar.editView],
                   @"isPostToMyZone": @(0)
                   };
    
    [manager POST:URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
              ONOXMLElement *result = [responseDocument.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
              
              HUD.mode = MBProgressHUDModeCustomView;
              
              if (errorCode == 1) {
                  self.editingBar.editView.text = @"";
                  [self updateInputBarHeight];
                  
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.label.text = @"评论发表成功";
              } else {
//                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
              }
              
              [HUD hideAnimated:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              HUD.mode = MBProgressHUDModeCustomView;
//              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.label.text = @"网络异常，动弹发送失败";
              
              [HUD hideAnimated:YES afterDelay:1];
          }];
}



#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString: @"\n"]) {
        [self sendContent];
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(PlaceholderTextView *)textView
{
    self.navigationItem.rightBarButtonItem.enabled = [textView hasText];
}

- (void)textViewDidChange:(PlaceholderTextView *)textView
{
    self.navigationItem.rightBarButtonItem.enabled = [textView hasText];
}


@end
