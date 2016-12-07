//
//  NewBlogDetailController.m
//  iosapp
//
//  Created by 李萍 on 2016/11/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewBlogDetailController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Config.h"
#import "UIDevice+SystemInfo.h"

#import "OSCAPI.h"
#import "OSCBlogDetail.h"
#import "BlogDetailHeadView.h"
#import "RecommandBlogTableViewCell.h"
#import "NewLoginViewController.h"
#import "QuesAnsDetailViewController.h"
#import "SoftWareViewController.h"
#import "TranslationViewController.h"
#import "ActivityDetailViewController.h"
#import "NewCommentListViewController.h"
#import "OSCInformationDetailController.h"
#import "NewBlogDetailController.h"
#import "TweetFriendsListViewController.h"
#import "OSCPopInputView.h"
#import "OSCModelHandler.h"
#import "IMYWebView.h"
#import "OSCPushTypeControllerHelper.h"

#import "UMSocial.h"
#import <MBProgressHUD.h>
#import <MJExtension.h>
#import <WebKit/WebKit.h>

static NSString *reuseIdentifierHeadView = @"BlogDetailHeadView";
static NSString *recommandBlogReuseIdentifier = @"RecommandBlogTableViewCell";
//static NSString *newCommentReuseIdentifier = @"NewCommentCell";

#define Large_Frame  (CGRect){{0,0},{40,25}}
#define Medium_Frame (CGRect){{0,0},{30,25}}
#define Small_Frame  (CGRect){{0,0},{25,25}}
#define screen_width [UIScreen mainScreen].bounds.size.width

@interface NewBlogDetailController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, IMYWebViewDelegate,OSCPopInputViewDelegate,CommentTextViewDelegate>
{
    CGFloat _headViewHeight;
}

@property (nonatomic, strong) OSCBlogDetail *blogDetail;
@property (nonatomic, strong) NSMutableArray *blogDetailRecommends;
@property (nonatomic, assign) NSInteger blogId;

@property (nonatomic, strong) UIButton *rightBarBtn;
@property (nonatomic,assign) BOOL isReboundTop;
@property (nonatomic,assign) CGPoint readingOffest;

@property (nonatomic, strong) BlogDetailHeadView *blogHeadView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, assign) CGFloat userInfoHeight;
@property (nonatomic, assign) CGFloat webViewHeight;

//被评论的某条评论的信息
@property (nonatomic) NSInteger beRepliedCommentAuthorId;
@property (nonatomic) NSInteger beRepliedCommentId;

@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong)OSCPopInputView *inputView;
@property (nonatomic,strong) NSString *beforeATStr;

@end

@implementation NewBlogDetailController

- (instancetype)initWithBlogId:(NSInteger)blogID
{
    self = [super init];
    if (self) {
        self.blogId = blogID;
        [self getBlogData];
        _blogDetailRecommends = [NSMutableArray new];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateRightButton:_blogDetail.commentCount];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"博客详情";
    
    [self layoutUI];
//    _headViewHeight = CGRectGetWidth(self.view.frame);

    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogReuseIdentifier];
 
    _blogHeadView = [[BlogDetailHeadView alloc] initWithFrame:CGRectMake(0, 0, screen_width, _headViewHeight)];
    [_blogHeadView.relationButton addTarget:self action:@selector(favSelected) forControlEvents:UIControlEventTouchUpInside];
    
    [self showHubView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideHubView:0];
}

- (void)layoutUI{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = [UIColor separatorColor];
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _commentTextView.commentTextViewDelegate = self;
}

#pragma mark - MBProgressHUD
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
- (void)hideHubView:(NSTimeInterval)timeInterval{
    [_hud hideAnimated:YES afterDelay:timeInterval];
    [[self.view viewWithTag:10] removeFromSuperview];
}


#pragma mark - refreshHeadView
- (void)refreshHeadView
{
    if (_blogDetail != nil) {
        CGFloat titleHeight = (CGFloat)[_blogDetail.title boundingRectWithSize:(CGSize){(screen_width - 32),MAXFLOAT}
                                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                    attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:22]}
                                                                       context:nil].size.height;
        CGFloat abstractHeight = (CGFloat)[(_blogDetail.abstract.length > 0 ? _blogDetail.abstract : @"无简介") boundingRectWithSize:(CGSize){(screen_width - 32), MAXFLOAT}
                                                                                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                                        attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}
                                                                                                           context:nil].size.height;
        
        CGFloat viewHeight;
        viewHeight += titleHeight;
        viewHeight = abstractHeight > 0 ? viewHeight + abstractHeight + 17 : viewHeight;

        _blogHeadView.blogDetail = _blogDetail;
        _userInfoHeight = 151 + viewHeight;
        
        _blogHeadView.webView.delegate = self;
        [_blogHeadView.webView loadHTMLString:_blogDetail.body baseURL:[NSBundle mainBundle].resourceURL];
    }
}

- (void)updateHeaderViewFrame
{
    _webViewHeight = _webViewHeight + 32;
    _headViewHeight = _userInfoHeight + _webViewHeight;
    _blogHeadView.frame = (CGRect){{0,0},{kScreenSize.width,_headViewHeight}};
}

- (void)didReceiveMemoryWarning {
    [self.navigationController popViewControllerAnimated:YES];
    [super didReceiveMemoryWarning];
}

#pragma mark --- update RightButton
-(void)updateRightButton:(NSInteger)commentCount
{
    _rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarBtn.userInteractionEnabled = YES;
    _rightBarBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_rightBarBtn addTarget:self action:@selector(rightBarButtonScrollToCommitSection) forControlEvents:UIControlEventTouchUpInside];
    [_rightBarBtn setTitle:@"" forState:UIControlStateNormal];
    _rightBarBtn.titleEdgeInsets = UIEdgeInsetsMake(-4, 0, 0, 0);
    [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_appbar"] forState:UIControlStateNormal];
    
    if (commentCount >= 999) {
        _rightBarBtn.frame = Large_Frame;
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_4_appbar"] forState:UIControlStateNormal];
        [_rightBarBtn setTitle:@"999+" forState:UIControlStateNormal];
    } else if (commentCount >= 100){
        _rightBarBtn.frame = Medium_Frame;
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_3_appbar"] forState:UIControlStateNormal];
        NSString* titleStr = [NSString stringWithFormat:@"%ld",(long)_blogDetail.commentCount];
        [_rightBarBtn setTitle:titleStr forState:UIControlStateNormal];
    } else{
        _rightBarBtn.frame = Small_Frame;
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_appbar"] forState:UIControlStateNormal];
        NSString* titleStr = [NSString stringWithFormat:@"%ld",(long)_blogDetail.commentCount];
        [_rightBarBtn setTitle:titleStr forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
}

#pragma mark - 右导航栏按钮
- (void)rightBarButtonScrollToCommitSection
{
    if (_blogDetail.commentCount > 0) {
        NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:CommentIdTypeForBlog sourceID:_blogDetail.id];
        
        [self.navigationController pushViewController:newCommentVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"暂无评论";
        
        [HUD hideAnimated:YES afterDelay:2];
    }
    
}

#pragma mark - fav关注
- (void)favSelected
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    } else {
        
        NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@user_relation_reverse", OSCAPI_V2_PREFIX];
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        [manger POST:blogDetailUrlStr
          parameters:@{
                       @"id"  : @(_blogDetail.authorId),
                       }
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 if ([responseObject[@"code"] integerValue]== 1) {
                     _blogDetail.authorRelation = [responseObject[@"result"][@"relation"] integerValue];
                 }
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self refreshHeadView];
                 });
             } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 NSLog(@"%@",error);
             }];
    }
    
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_blogDetailRecommends.count > 0) {
        RecommandBlogTableViewCell *recommandBlogCell = [tableView dequeueReusableCellWithIdentifier:recommandBlogReuseIdentifier forIndexPath:indexPath];
        
        if (_blogDetailRecommends.count > 0) {
            OSCBlogDetailRecommend *about = _blogDetailRecommends[indexPath.row];
            recommandBlogCell.abouts = about;
            recommandBlogCell.hiddenLine = _blogDetailRecommends.count - 1 == indexPath.row ? YES : NO;
        }
        
        recommandBlogCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        recommandBlogCell.selectedBackgroundView = [[UIView alloc] initWithFrame:recommandBlogCell.frame];
        recommandBlogCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
        return recommandBlogCell;
    }
    
    return [UITableViewCell new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_blogDetailRecommends.count > 0) {
        return _blogDetailRecommends.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _blogDetailRecommends.count ? 1 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_blogDetailRecommends.count > 0) {
        return [self headerViewWithSectionTitle:@"相关文章"];
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 32;
    }
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == _blogDetailRecommends.count-1) {
            return 72;
        } else {
            return 60;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        if (_blogDetailRecommends.count > 0) {
            OSCBlogDetailRecommend *detailRecommend = _blogDetailRecommends[indexPath.row];
            if (detailRecommend.type == 0) { detailRecommend.type = 3; }
            UIViewController* pushViewController = [OSCPushTypeControllerHelper pushControllerGeneralWithType:detailRecommend.type detailContentID:detailRecommend.id];
            if (pushViewController) {
                [self.navigationController pushViewController:pushViewController animated:YES];
            }
        }
    }
}

#pragma mark - IMYWebView delegate
- (BOOL)webView:(IMYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL name:nil];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}
- (void)webViewDidFinishLoad:(IMYWebView *)webView{
    [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(NSNumber* result, NSError * error) {
        _webViewHeight = [result floatValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateHeaderViewFrame];
            self.tableView.tableHeaderView = _blogHeadView;
            [self.tableView reloadData];
            [self hideHubView:0.5];
        });
    }];
}


#pragma mark -- DIY_headerView
- (UIView*)headerViewWithSectionTitle:(NSString*)title {
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 32)];
    headerView.backgroundColor = [UIColor colorWithHex:0xf9f9f9];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 0.5)];
    topLineView.backgroundColor = [UIColor separatorColor];
    [headerView addSubview:topLineView];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 31, CGRectGetWidth([[UIScreen mainScreen]bounds]), 0.5)];
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


#pragma mark - 获取博客详情
-(void)getBlogData{
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@blog?id=%ld", OSCAPI_V2_PREFIX, (long)_blogId];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:blogDetailUrlStr
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"]integerValue] == 1) {
                _blogDetail = [OSCBlogDetail mj_objectWithKeyValues:responseObject[@"result"]];
                _blogDetailRecommends = [OSCBlogDetailRecommend mj_objectArrayWithKeyValuesArray:_blogDetail.abouts];
                
                NSDictionary *data = @{@"content":  _blogDetail.body};
                _blogDetail.body = [Utils HTMLWithData:data
                                         usingTemplate:@"blog"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateFavButtonWithIsCollected:_blogDetail.favorite];
                    [self updateRightButton:_blogDetail.commentCount];
                    [self refreshHeadView];
                    
                    [self.tableView reloadData];
                });
            }else{
                _hud.hidden = YES;
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.label.text = @"这篇博客找不到了(不存在/已删除)";
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

#pragma mark - favorate action

- (void)updateFavButtonWithIsCollected:(BOOL)isCollected {
    if (isCollected) {
        [_favButton setImage:[UIImage imageNamed:@"ic_faved_pressed"] forState:UIControlStateNormal];
    }else {
        [_favButton setImage:[UIImage imageNamed:@"ic_fav_pressed"] forState:UIControlStateNormal];
    }
}

- (void)favAction:(id)sender {
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        NSDictionary *parameterDic = @{@"id"   : @(_blogDetail.id), @"type" : @(3)};
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        
        [manger POST:[NSString stringWithFormat:@"%@/favorite_reverse", OSCAPI_V2_PREFIX]
          parameters:parameterDic
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 
                 BOOL isCollected = NO;
                 if ([responseObject[@"code"] integerValue]== 1) {
                     isCollected = [responseObject[@"result"][@"favorite"] boolValue];
                 }
                 
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = isCollected? @"收藏成功": @"取消收藏";
                 
                 [HUD hideAnimated:YES afterDelay:1];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self updateFavButtonWithIsCollected:isCollected];
                 });
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"网络异常，操作失败";
                 
                 [HUD hideAnimated:YES afterDelay:1];
             }];
    }
}

#pragma mark - share action
- (IBAction)shareAction:(id)sender {
    [_commentTextView resignFirstResponder];
    
    NSString *body = _blogDetail.body;
    NSString *href = _blogDetail.href;
    NSString *title = _blogDetail.title;
    
    NSString *trimmedHTML = [body deleteHTMLTag];
    NSInteger length = trimmedHTML.length < 60 ? trimmedHTML.length : 60;
    NSString *digest = [trimmedHTML substringToIndex:length];
    
    // 微信相关设置
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = href;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = href;
    [UMSocialData defaultData].extConfig.title = title;
    
    // 手机QQ相关设置
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.title = title;
    //[UMSocialData defaultData].extConfig.qqData.shareText = weakSelf.objectTitle;
    [UMSocialData defaultData].extConfig.qqData.url = href;
    
    // 新浪微博相关设置
    [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:href];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UM_APP_KEY
                                      shareText:[NSString stringWithFormat:@"%@...分享来自 %@", digest, href]
                                     shareImage:[UIImage imageNamed:@"logo"]
                                shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                       delegate:nil];
}

CGRect oldFrame;
- (void)keyboardWillShow:(NSNotification *)nsNotification
{
    //获取键盘的高度
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    [UIView animateWithDuration:1 animations:^{
        self.inputView.frame = CGRectMake(0, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - keyboardRect.size.height, kScreenSize.width, CGRectGetHeight(self.inputView.frame));
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [self hideEditView];
}

#pragma mark - 发评论
- (void)sendCommentWithString:(NSString *)commentStr
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        
        MBProgressHUD *HUD = [Utils createHUD];
        [HUD showAnimated:YES];
        //新 发评论
        NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithDictionary:
                                        @{
                                          @"sourceId"   : @(_blogDetail.id),
                                          @"type"       : @(3),
                                          @"content"    : commentStr,
                                          @"reAuthorId" : @(_beRepliedCommentAuthorId),
                                          @"replyId"    : @(_beRepliedCommentId)
                                          }
                                        ];
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX,OSCAPI_COMMENT_PUB]
          parameters:paraDic
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 
                 HUD.mode = MBProgressHUDModeCustomView;
                 
                 if ([responseObject[@"code"]integerValue] == 1) {
                     HUD.mode = MBProgressHUDModeCustomView;
                     HUD.label.text = @"评论成功";
                     
                     _blogDetail.commentCount +=1;
                     
                     [HUD hideAnimated:YES afterDelay:1];
                     _commentTextView.text = @"";
                     _commentTextView.placeholder = @"发表评论";
                 }else {
                     HUD.label.text = [NSString stringWithFormat:@"错误：%@", responseObject[@"message"]];
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self updateRightButton:_blogDetail.commentCount];
                     [self.tableView reloadData];
                 });
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"网络异常，评论发送失败";
                 [HUD hideAnimated:YES afterDelay:1];
             }];
    }
    
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma CommentTextViewDelegate
- (void)ClickTextViewWithString:(NSString *)string{
    [self showEditView];
    if ((!string || [string isEqualToString:@""]) && ![[_commentTextView getPlace] isEqualToString:@"发表评论"]) {
        [self.inputView restoreDraftNote:[_commentTextView getPlace]];
    }else{
        [self.inputView restoreDraftNote:string];
    }
}

#pragma --mark OSCPopInputViewDelegate
- (void)popInputViewDidDismiss:(OSCPopInputView* )popInputView draftNoteStr:(NSString* )draftNoteStr{
    _beforeATStr = draftNoteStr;
    [_commentTextView handleAttributeWithString:draftNoteStr];
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

- (void)popInputViewClickDidSendButton:(OSCPopInputView *)popInputView selectedforwarding:(BOOL)isSelectedForwarding curTextView:(UITextView *)textView{
    _beforeATStr = @"";
    [self sendCommentWithString:textView.text];
    [self.inputView clearDraftNote];
    [self hideEditView];
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
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld",(long)_blogId];
    }
    return _inputView;
}


@end
