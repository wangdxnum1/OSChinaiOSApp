//
//  QuesAnsDetailViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuesAnsDetailViewController.h"
#import "QuesAnsDetailHeadCell.h"
#import "NewCommentCell.h"
#import "OSCNewComment.h"
#import "OSCBlogDetail.h"
#import "CommentDetailViewController.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "Config.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "NewLoginViewController.h"
#import "OSCQuesAnsDetailsContentView.h"

#import <MJExtension.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "UMSocial.h"
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MJRefresh.h>

#import "CommentTextView.h"
#import "JDStatusBarNotification.h"
#import "OSCPopInputView.h"
#import "OSCModelHandler.h"
#import "TweetFriendsListViewController.h"

static NSString *quesAnsDetailHeadReuseIdentifier = @"QuesAnsDetailHeadCell";
static NSString *quesAnsCommentHeadReuseIdentifier = @"NewCommentCell";

@interface QuesAnsDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UITextFieldDelegate,CommentTextViewDelegate,OSCPopInputViewDelegate,OSCQuestionAnsDetailDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;

@property (weak, nonatomic) IBOutlet CommentTextView *commendTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;

@property (weak, nonatomic) IBOutlet UIButton *favButton;

@property (nonatomic, strong) OSCQuestion *questionDetail;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, assign) CGFloat webViewHeight;

@property (nonatomic, copy) NSString *nextPageToken;

@property (nonatomic, strong) UITapGestureRecognizer *tap;
//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic,strong) OSCPopInputView *inputView;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) NSString *beforeATStr;   //储存@人之前的string

@property (nonatomic,strong) OSCQuesAnsDetailsContentView *headerView;

@end

@implementation QuesAnsDetailViewController


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self hideHubView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialized];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getCommentsForQuestion:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getCommentsForQuestion:NO];
    }];
    
    

    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(rightBarButtonClicked)];
    [self getCommentsForQuestion:YES];
    [self getDetailForQuestion];
    /* 待调试 */
//    [self.tableView.mj_footer beginRefreshing]; 
	
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
	
	[self showHubView];
}

- (void)didReceiveMemoryWarning{
    [self.navigationController popViewControllerAnimated:YES];

    [super didReceiveMemoryWarning];
}
#pragma mark --- 
-(void)initialized{
    _headerView = [[OSCQuesAnsDetailsContentView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _headerView.delegate = self;
    
    _comments = [NSMutableArray new];
    _nextPageToken = @"";
    
    self.commendTextView.commentTextViewDelegate = self;
    self.commendTextView.placeholder = @"我要回答";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"QuesAnsDetailHeadCell" bundle:nil] forCellReuseIdentifier:quesAnsDetailHeadReuseIdentifier];
    [self.tableView registerClass:[NewCommentCell class] forCellReuseIdentifier:quesAnsCommentHeadReuseIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 250;
}


#pragma mark - 获取数据
- (void)getDetailForQuestion
{
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@question?id=%ld", OSCAPI_V2_PREFIX, (long)self.questionID];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:blogDetailUrlStr
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"]integerValue] == 1) {
                _questionDetail = [OSCQuestion mj_objectWithKeyValues:responseObject[@"result"]];
                NSDictionary *data = @{@"content":  _questionDetail.body};
                _questionDetail.body = [Utils HTMLWithData:data
                                          usingTemplate:@"newTweet"];
                
                self.title = [NSString stringWithFormat:@"%ld个回答",(long)_questionDetail.commentCount];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setFavButtonImage:_questionDetail.favorite];
                    _headerView.question = _questionDetail;
                });
            }else{
                _hud.hidden = YES;
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.label.text = @"这篇帖子找不到了(不存在/已删除)";
                [HUD hideAnimated:YES afterDelay:1];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
    
    
}

#pragma mark - 获取评论数组
- (void)getCommentsForQuestion:(BOOL)isRefresh
{
    
    NSString *qCommentUrlStr = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_COMMENTS_LIST];
    NSMutableDictionary *mutableParamDic = @{
                               @"sourceId"  : @(self.questionID),
                               @"type"      : @(2),
                               @"parts"     : @"refer,reply"
                               }.mutableCopy;
    if (!isRefresh) {//上拉刷新
        [mutableParamDic setValue:_nextPageToken forKey:@"pageToken"];
    }
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:qCommentUrlStr
     parameters:mutableParamDic.copy
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary *result = responseObject[@"result"];
                NSArray *jsonItems = result[@"items"]?:@[];
                NSArray *array;
                if (jsonItems.count > 0) {
                    array = [OSCCommentItem mj_objectArrayWithKeyValuesArray:jsonItems];
                }
                _nextPageToken = result[@"nextPageToken"];
                
                if (isRefresh) {
                    [_comments removeAllObjects];
                }
                [_comments addObjectsFromArray:array];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isRefresh) {
                        [self.tableView.mj_header endRefreshing];
                    }else{
                        if (array.count == 0) {
                            [self.tableView.mj_footer endRefreshingWithNoMoreData];
                        }else{
                            [self.tableView.mj_footer endRefreshing];
                        }
                    }
                    [self.tableView reloadData];
                });
            }else {
                if (isRefresh) {
                    [self.tableView.mj_header endRefreshing];
                }else{
                    [self.tableView.mj_footer endRefreshing];
                }
            }
            
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            if (isRefresh) {
                [self.tableView.mj_header endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshing];
            }
            [self.tableView reloadData];
            NSLog(@"error = %@",error);
        }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_comments.count > 0) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (_comments.count > 0) {
            return _comments.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:quesAnsCommentHeadReuseIdentifier forIndexPath:indexPath];//[NewCommentCell new];//
    if (_comments.count > 0) {
        OSCCommentItem *comment = _comments[indexPath.row];
        
        [commentCell setDataForQuestionComment:comment];
        commentCell.commentButton.enabled = NO;
        commentCell.contentTextView.userInteractionEnabled = NO;
    }
    
    commentCell.contentView.backgroundColor = [UIColor newCellColor];
    commentCell.backgroundColor = [UIColor themeColor];
    commentCell.selectedBackgroundView = [[UIView alloc] initWithFrame:commentCell.frame];
    commentCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return commentCell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (_questionDetail.commentCount > 0) {
            return [self headerViewWithSectionTitle:[NSString stringWithFormat:@"回答(%lu)", (unsigned long)_questionDetail.commentCount]];
        }
        return [self headerViewWithSectionTitle:@"回答"];
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return UITableViewAutomaticDimension;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}
#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (_comments.count > indexPath.row) {
            OSCCommentItem *comment = _comments[indexPath.row];
            
            CommentDetailViewController *commentDetailVC = [CommentDetailViewController new];
            commentDetailVC.questDetailId = self.questionID;
            commentDetailVC.commentId = comment.id;
            [self.navigationController pushViewController:commentDetailVC animated:YES];
        }
        
    }
}

#pragma mark - WebView delegate 
- (BOOL)contentView:(IMYWebView *)webView
        shouldStart:(NSURLRequest *)request{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL name:nil];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}

-(void)contentViewDidFinishLoadWithHederViewHeight:(float)height{
    _hud.hidden = YES;
    [self hideHubView];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.headerView.frame = CGRectMake(0, 0, kScreenSize.width, height);
        self.tableView.tableHeaderView = self.headerView;
        [self.tableView reloadData];
    });
}

#pragma mark -- DIY_headerView
- (UIView*)headerViewWithSectionTitle:(NSString*)title {
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 32)];
    headerView.backgroundColor = [UIColor colorWithHex:0xf9f9f9];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 1)];
    topLineView.backgroundColor = [UIColor separatorColor];
    [headerView addSubview:topLineView];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 31, CGRectGetWidth([[UIScreen mainScreen]bounds]), 1)];
    bottomLineView.backgroundColor = [UIColor separatorColor];
    [headerView addSubview:bottomLineView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 100, 16)];
    titleLabel.center = CGPointMake(titleLabel.center.x, headerView.center.y);
    titleLabel.tag = 8;
    titleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = title;
    [headerView addSubview:titleLabel];
    
    return headerView;
}

#pragma mark - 右导航栏按钮
- (void)rightBarButtonClicked
{
	
	if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
		return;
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"举报"
                                                        message:[NSString stringWithFormat:@"链接地址：%@", _questionDetail.href]
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
		alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
		[alertView textFieldAtIndex:0].placeholder = @"举报原因";
		if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode)
		{
			[alertView textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceDark;
		}
		[alertView show];
	}//end of if
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        /* 新举报接口 */
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        [manger POST:[NSString stringWithFormat:@"%@report", OSCAPI_V2_PREFIX]
          parameters:@{
                       @"sourceId"   : @(self.questionID),
                       @"type"       : @(2),
                       @"href"       : _questionDetail.href,//举报的文章地址
                       @"reason"     : @(1), //0 其他原因 1 广告 2 色情 3 翻墙 4 非IT话题
					   @"memo"		 : ([alertView textFieldAtIndex:0].text)
                       }
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 if ([responseObject[@"code"]integerValue] == 1) {
                     MBProgressHUD *HUD = [Utils createHUD];
                     HUD.mode = MBProgressHUDModeCustomView;
                     HUD.label.text = @"举报完成，感谢亲~";
                     [HUD hideAnimated:YES afterDelay:1];
				 } else {
					 MBProgressHUD *HUD = [Utils createHUD];
					 HUD.mode = MBProgressHUDModeCustomView;
					 HUD.label.text = @"其他未知错误，请稍后再试~";
					 [HUD hideAnimated:YES afterDelay:1];
				 }
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
				 MBProgressHUD *HUD = [Utils createHUD];
				 HUD.mode = MBProgressHUDModeCustomView;
				 HUD.label.text = @"网络请求失败，请稍后再试~~";
				 [HUD hideAnimated:YES afterDelay:1];
             }];
    }//end of if
}

- (void)keyboardDidShow:(NSNotification *)nsNotification
{
    
    //获取键盘的高度
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    _keyboardHeight = keyboardRect.size.height;
    
//    _bottomLayoutConstraint.constant = _keyboardHeight;
    [UIView animateWithDuration:1 animations:^{
        self.inputView.frame = CGRectMake(0, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - _keyboardHeight, kScreenSize.width, CGRectGetHeight(self.inputView.frame));
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)];
    [self.view addGestureRecognizer:_tap];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
//    _bottomLayoutConstraint.constant = 0;
    [self hideEditView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - sendMessage
- (void)sendMessageWithString:(NSString *)commentStr
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }else{
        JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"评论发送中.."];
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        
        [manger POST:[NSString stringWithFormat:@"%@comment_pub", OSCAPI_V2_PREFIX]
          parameters:@{
                       @"sourceId"   : @(self.questionID),
                       @"type"       : @(2),
                       @"content"    : commentStr,
                       //                  @"replyId"    : @(0),
                       //                  @"reAuthorId" : @(0),
                       }
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 if ([responseObject[@"code"]integerValue] == 1) {
                     //                MBProgressHUD *HUD = [Utils createHUD];
                     //                HUD.mode = MBProgressHUDModeCustomView;
                     //                HUD.label.text = @"评论成功";
                     stauts.textLabel.text = @"评论成功";
                     [JDStatusBarNotification dismissAfter:2];
                     
                     OSCNewComment *postedComment = [OSCNewComment mj_objectWithKeyValues:responseObject[@"result"]];
                     
                     if (postedComment) {
                         [_comments insertObject:[self commentItemForNewCommentModel:postedComment] atIndex:0];
                     }
                     
                     _commendTextView.text = @"";
                     //                [HUD hideAnimated:YES afterDelay:1];
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [self.tableView reloadData];
                 });
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 stauts.textLabel.text = @"网络异常，评论发送失败";
                 [JDStatusBarNotification dismissAfter:2];
                 [_commendTextView handleAttributeWithString:commentStr];
             }];
    }
}

#pragma mark - OSCNewComment 转化 OSCCommentItem
- (OSCCommentItem *)commentItemForNewCommentModel:(OSCNewComment *)newCommet
{
    OSCCommentItem *commentItem = [OSCCommentItem new];
    
    commentItem.appClient = (int)newCommet.appClient;
    commentItem.content = newCommet.content;
    commentItem.id = newCommet.id;
    commentItem.voteState = newCommet.voteState;
    commentItem.pubDate = newCommet.pubDate;
    commentItem.best = newCommet.best;
    commentItem.vote = newCommet.vote;
    
    OSCUserItem *user = [OSCUserItem new];
    
    user.id = newCommet.authorId;
    user.name = newCommet.author;
    user.portrait = newCommet.authorPortrait;
    commentItem.author = user;
    
    return commentItem;
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_commendTextView resignFirstResponder];
    [self.view removeGestureRecognizer:_tap];
}

#pragma mark - 按钮功能
- (IBAction)buttonClick:(UIButton *)sender {
    
    if (sender.tag == 2) {
        [self shareForOthers];
    }
    //先判断是否登录
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        if (sender.tag == 1) {
            [self favOrNoFavType];
        }
    }
    
}

- (void)favOrNoFavType
{
    //收藏
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@favorite_reverse", OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger POST:blogDetailUrlStr
     parameters:@{
                  @"id"  : @(self.questionID),
                  @"type"      : @(2),
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue]== 1) {
                _questionDetail.favorite = [responseObject[@"result"][@"favorite"] boolValue];
                
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.label.text = _questionDetail.favorite? @"收藏成功": @"取消收藏";
                
                [HUD hideAnimated:YES afterDelay:1];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setFavButtonImage:_questionDetail.favorite];

                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

- (void)setFavButtonImage:(BOOL)isFav
{
    if (isFav) {
        [_favButton setImage:[UIImage imageNamed:@"ic_faved_pressed"] forState:UIControlStateNormal];
    } else {
        [_favButton setImage:[UIImage imageNamed:@"ic_fav_pressed"] forState:UIControlStateNormal];
    }
}

- (void)shareForOthers
{
    //分享
    [_commendTextView resignFirstResponder];
    
    NSString *trimmedHTML = [_questionDetail.body deleteHTMLTag];
    NSInteger length = trimmedHTML.length < 60 ? trimmedHTML.length : 60;
    NSString *digest = [trimmedHTML substringToIndex:length];
    
    // 微信相关设置
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = _questionDetail.href;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = _questionDetail.href;
    [UMSocialData defaultData].extConfig.title = _questionDetail.title;
    
    // 手机QQ相关设置
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.title = _questionDetail.title;
    //[UMSocialData defaultData].extConfig.qqData.shareText = weakSelf.objectTitle;
    [UMSocialData defaultData].extConfig.qqData.url = _questionDetail.href;
    
    // 新浪微博相关设置
    [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:_questionDetail.href];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"54c9a412fd98c5779c000752"
                                      shareText:[NSString stringWithFormat:@"%@...分享来自 %@", digest, _questionDetail.href]
                                     shareImage:[UIImage imageNamed:@"logo"]
                                shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                       delegate:nil];
}
#pragma mark --- HUD setting
- (void)showHubView {
    UIView *coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height)];
    coverView.backgroundColor = [UIColor whiteColor];
    coverView.tag = 10;
    [self.view addSubview:coverView];
    _hud = [[MBProgressHUD alloc] initWithView:coverView];
    _hud.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    [coverView addSubview:_hud];
    [_hud showAnimated:YES];
    _hud.removeFromSuperViewOnHide = YES;
    _hud.userInteractionEnabled = NO;
}
- (void)hideHubView {
    [_hud hideAnimated:YES];
    [[self.view viewWithTag:10] removeFromSuperview];
}

#pragma CommentTextViewDelegate
- (void)ClickTextViewWithString:(NSString *)string{
    [self showEditView];
    if ((!string || [string isEqualToString:@""]) && ![[_commendTextView getPlace] isEqualToString:@"我要回答"]) {
        [self.inputView restoreDraftNote:[_commendTextView getPlace]];
    }else{
        [self.inputView restoreDraftNote:string];
    }
}

#pragma --mark OSCPopInputViewDelegate
- (void)popInputViewDidDismiss:(OSCPopInputView* )popInputView draftNoteStr:(NSString* )draftNoteStr{
    _beforeATStr = draftNoteStr;
    [_commendTextView handleAttributeWithString:draftNoteStr];
}

- (void)popInputViewClickDidSendButton:(OSCPopInputView *)popInputView selectedforwarding:(BOOL)isSelectedForwarding curTextView:(UITextView *)textView{
    _beforeATStr = @"";
    [self sendMessageWithString:textView.text];
    [self.inputView clearDraftNote];
    [self hideEditView];
}

- (void)popInputViewClickDidAtButton:(OSCPopInputView* )popInputView{
    TweetFriendsListViewController * vc = [TweetFriendsListViewController new];
    [self hideEditView];
    [vc setSelectDone:^(NSString *result) {
        [self showEditView];
        [self.inputView restoreDraftNote:[NSString stringWithFormat:@"%@%@",_beforeATStr,result]];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showEditView{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    _backView = [[UIView alloc] initWithFrame:window.bounds];
    _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [_backView addSubview:self.inputView];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEditView)];
    [_backView addGestureRecognizer:tapGR];
    [self.inputView activateInputView];
    [window addSubview:_backView];
}

- (void)hideEditView{
    [self.inputView freezeInputView];
    [UIView animateWithDuration:0.3 animations:^{
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.inputView.frame = CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) ;
    } completion:^(BOOL finished) {
        [_backView removeFromSuperview];
        _backView = nil;
    }];
}

- (OSCPopInputView *)inputView{
    if(!_inputView){
        _inputView = [OSCPopInputView popInputViewWithFrame:CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) maxStringLenght:160 delegate:self autoSaveDraftNote:YES];
        _inputView.popInputViewType = OSCPopInputViewType_At;
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld",(long)self.questionID];
    }
    return _inputView;
}

@end
