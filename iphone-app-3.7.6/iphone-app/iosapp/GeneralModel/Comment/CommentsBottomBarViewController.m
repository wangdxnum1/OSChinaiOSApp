//
//  CommentsBottomBarViewController.m
//  iosapp
//
//  Created by ChanAetern on 1/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "CommentsBottomBarViewController.h"
#import "CommentsViewController.h"
#import "OSCComment.h"
#import "Config.h"
#import <MBProgressHUD.h>

@interface CommentsBottomBarViewController ()

@property (nonatomic, strong) CommentsViewController *commentsVC;
@property (nonatomic, assign) int64_t objectID;
@property (nonatomic, assign) int64_t replyID;
@property (nonatomic, assign) int64_t replyUID;
@property (nonatomic, assign) CommentType commentType;

@end

@implementation CommentsBottomBarViewController


- (instancetype)initWithCommentType:(CommentType)commentType andObjectID:(int64_t)objectID
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _objectID = objectID;
        _commentType = commentType;
        
        _commentsVC = [[CommentsViewController alloc] initWithCommentType:commentType andObjectID:objectID];
        [self addChildViewController:_commentsVC];
        
        [self setUpBlock];
    }
    
    return self;
}

- (void)setUpBlock
{
    __weak CommentsBottomBarViewController *weakSelf = self;
    
    _commentsVC.didCommentSelected = ^(OSCComment *comment) {
        if (weakSelf.replyID == comment.commentID) {
            weakSelf.replyID = 0;
            weakSelf.replyUID = 0;
            [weakSelf.editingBar.editView setPlaceholder:@"说点什么"];
        } else {
            weakSelf.replyID = comment.commentID;
            weakSelf.replyUID = comment.authorID;
            weakSelf.editingBar.editView.placeholder = [NSString stringWithFormat:@"回复%@：", comment.author];
            [weakSelf.editingBar.editView becomeFirstResponder];
        }
    };
    
    _commentsVC.didScroll = ^ {
        [weakSelf.editingBar.editView resignFirstResponder];
        [weakSelf hideEmojiPageView];
    };
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setLayout
{
    [self.view addSubview:_commentsVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"tableView": _commentsVC.view, @"editingBar": self.editingBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView][editingBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
}


- (void)sendContent
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.label.text = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *URL;
    if (_commentType == CommentTypeBlog) {
        URL = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_BLOGCOMMENT_PUB];
    } else if (_replyID == 0) {
        URL = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_COMMENT_PUB];
    } else {
        URL = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_COMMENT_REPLY];
    }
    
    NSDictionary *parameters = _commentType == CommentTypeBlog?
                                @{
                                  @"blog": @(_objectID),
                                  @"uid": @([Config getOwnID]),
                                  @"reply_id": @(_replyID),
                                  @"objuid": @(_replyUID),
                                  @"content": [Utils convertRichTextToRawText:self.editingBar.editView],
                                  }:
                                @{
                                  @"catalog": @(_commentType),
                                  @"id": @(_objectID),
                                  @"uid": @([Config getOwnID]),
                                  @"replyid": @(_replyID),
                                  @"authorid": @(_replyUID),
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
              
              [_commentsVC.tableView setContentOffset:CGPointZero animated:NO];
              [_commentsVC refresh];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              HUD.mode = MBProgressHUDModeCustomView;
//              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.label.text = @"网络异常，动弹发送失败";
              
              [HUD hideAnimated:YES afterDelay:1];
          }];
}





@end
