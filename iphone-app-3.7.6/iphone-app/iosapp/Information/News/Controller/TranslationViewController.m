//
//  TranslationViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TranslationViewController.h"
#import "TitleInfoTableViewCell.h"
#import "webAndAbsTableViewCell.h"
#import "RecommandBlogTableViewCell.h"
#import "ContentWebViewCell.h"
#import "NewCommentCell.h"
#import "RelatedSoftWareCell.h"
#import "UIColor+Util.h"
#import "OSCAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCBlogDetail.h"
#import "Utils.h"
#import "Config.h"
#import "OSCBlog.h"
#import "OSCSoftware.h"
#import "DetailsViewController.h"
#import "OSCNewHotBlogDetails.h"
#import "OSCInformationDetails.h"
#import "CommentsBottomBarViewController.h"
#import "NewLoginViewController.h"
#import "AppDelegate.h"
#import "NewCommentListViewController.h"//新评论列表
#import "OSCInformationHeaderView.h"

#import <MJExtension.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "UMSocial.h"
#import "CommentTextView.h"
#import "OSCPopInputView.h"
#import "OSCModelHandler.h"
#import "TweetFriendsListViewController.h"
#import "JDStatusBarNotification.h"

static NSString *titleInfoReuseIdentifier = @"TitleInfoTableViewCell";
static NSString *recommandBlogReuseIdentifier = @"RecommandBlogTableViewCell";
static NSString *abstractReuseIdentifier = @"abstractTableViewCell";
static NSString *contentWebReuseIdentifier = @"contentWebTableViewCell";
static NSString *newCommentReuseIdentifier = @"NewCommentCell";
static NSString *relatedSoftWareReuseIdentifier = @"RelatedSoftWareCell";


#define Large_Frame  (CGRect){{0,0},{40,25}}
#define Medium_Frame (CGRect){{0,0},{30,25}}
#define Small_Frame  (CGRect){{0,0},{25,25}}

@interface TranslationViewController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate,CommentTextViewDelegate,OSCPopInputViewDelegate,OSCInformationHeaderViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet CommentTextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@property (nonatomic, strong) OSCInformationDetails *translationDetails;
@property (nonatomic, strong) NSMutableArray *translationDetailComments;
@property (nonatomic) BOOL isExistRelatedTranslation;      //存在相关软件的信息

//被评论的某条评论的信息
@property (nonatomic) NSInteger beRepliedCommentAuthorId;
@property (nonatomic) NSInteger beRepliedCommentId;

@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, strong) MBProgressHUD *hud;
//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic,strong) OSCNewHotBlogDetails *detail;
@property (nonatomic, copy) NSString *mURL;
@property (nonatomic, assign) BOOL isReply;
@property (nonatomic, assign) NSInteger selectIndexPath;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIButton *rightBarBtn;

@property (nonatomic,assign) BOOL isReboundTop;
@property (nonatomic,assign) CGPoint readingOffest;

@property (nonatomic,strong) OSCPopInputView *inputView;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) NSString *beforeATStr;   //储存@人之前的string

@property (nonatomic,strong) OSCInformationHeaderView *headerView;

@end

@implementation TranslationViewController

- (void)showHubView {
    UIView *coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height)];
    coverView.backgroundColor = [UIColor whiteColor];
    coverView.tag = 10;
    [self.view addSubview:coverView];
    _hud = [[MBProgressHUD alloc] initWithView:coverView];
    _hud.center = coverView.center;
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

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideHubView];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _headerView = [[OSCInformationHeaderView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _headerView.delegate = self;
    
    self.title = @"翻译详情";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.commentTextView.commentTextViewDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TitleInfoTableViewCell" bundle:nil] forCellReuseIdentifier:titleInfoReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"webAndAbsTableViewCell" bundle:nil] forCellReuseIdentifier:abstractReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ContentWebViewCell" bundle:nil] forCellReuseIdentifier:contentWebReuseIdentifier];
    [self.tableView registerClass:[NewCommentCell class] forCellReuseIdentifier:newCommentReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RelatedSoftWareCell" bundle:nil] forCellReuseIdentifier:relatedSoftWareReuseIdentifier];
    
    self.tableView.tableFooterView = [UIView new];
    
    // 添加等待动画
    [self showHubView];
    
    [self getTranslationData];
//    [self getTranslationComments];
    
    _rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarBtn.userInteractionEnabled = YES;
    _rightBarBtn.frame  = CGRectMake(0, 0, 27, 20);
    _rightBarBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _rightBarBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_rightBarBtn addTarget:self action:@selector(rightBarButtonScrollToCommitSection) forControlEvents:UIControlEventTouchUpInside];
    _rightBarBtn.titleEdgeInsets = UIEdgeInsetsMake(-3, 0, 0, 0);
    
    
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

-(void)updateRightButton:(NSInteger)commentCount{
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
        NSString* titleStr = [NSString stringWithFormat:@"%ld",(long)commentCount];
        [_rightBarBtn setTitle:titleStr forState:UIControlStateNormal];
    } else{
        _rightBarBtn.frame = Small_Frame;
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_appbar"] forState:UIControlStateNormal];
        NSString* titleStr = [NSString stringWithFormat:@"%ld",(long)commentCount];
        [_rightBarBtn setTitle:titleStr forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
}

#pragma mark - 右导航栏按钮
- (void)rightBarButtonScrollToCommitSection
{
//    if (_translationDetailComments.count > 0) {
//        if (self.isReboundTop == NO) {
//            self.readingOffest = self.tableView.contentOffset;
//            NSIndexPath* lastSectionIndexPath = [NSIndexPath indexPathForRow:0 inSection:(self.tableView.numberOfSections - 1)];
//            [self.tableView scrollToRowAtIndexPath:lastSectionIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        }else{
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        }
//        self.isReboundTop = !self.isReboundTop;
//    }
    
    if (_translationDetails.commentCount > 0) {
        NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:CommentIdTypeForTranslate sourceID:self.translationId];
        [self.navigationController pushViewController:newCommentVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"暂无评论";
        [HUD hideAnimated:YES afterDelay:2];
    }
}
#pragma mark - 获取翻译详情
- (void)getTranslationData {
    NSString *translationDetailUrlStr = [NSString stringWithFormat:@"%@translation?id=%ld", OSCAPI_V2_PREFIX, (long)self.translationId];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:translationDetailUrlStr
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"]integerValue] == 1) {
                _translationDetails = [OSCInformationDetails mj_objectWithKeyValues:responseObject[@"result"]];
                
                NSDictionary *data = @{@"content":  _translationDetails.body};
                _translationDetails.body = [Utils HTMLWithData:data
                                                 usingTemplate:@"blog"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateFavButtonWithIsCollected:_translationDetails.favorite];
                    [self updateRightButton:_translationDetails.commentCount];
                    _headerView.newsModel = _translationDetails;
                });
            }else{
                _hud.hidden = YES;
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.label.text = @"这篇文章找不到了(不存在/已删除)";
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
#pragma mark - 获取翻译详情评论
-(void)getTranslationComments{
    NSString *newsDetailUrlStr = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_COMMENTS_LIST];
    NSInteger fixedTranslastionId = _translationId > 10000000 ? _translationId-10000000:_translationId;
    NSDictionary *paraDic = @{@"pageToken":@"",
                              @"sourceId":@(fixedTranslastionId),
                              @"type":@(4),
                              @"parts":@"refer,reply",
                              };
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:newsDetailUrlStr
     parameters:paraDic
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"]integerValue] == 1) {
                _translationDetailComments = [OSCCommentItem mj_objectArrayWithKeyValuesArray:responseObject[@"result"][@"items"]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}
#pragma mark -- DIY_headerView
- (UIView*)headerViewWithSectionTitle:(NSString*)title {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 32)];
    headerView.backgroundColor = [UIColor colorWithHex:0xf9f9f9];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 100, 16)];
    titleLabel.center = CGPointMake(titleLabel.center.x, headerView.center.y);
    titleLabel.tag = 8;
    titleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = title;
    [headerView addSubview:titleLabel];
    
    return headerView;
}
#pragma mark -- 获取评论cell的高度
- (NSInteger)getCommentCellHeightWithComment:(OSCCommentItem *)comment {
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;

    label.attributedText = [NewCommentCell contentStringFromRawString:comment.content];
    
    CGFloat height = [label sizeThatFits:CGSizeMake(self.tableView.frame.size.width - 32, MAXFLOAT)].height;
    
    height += 7;
    
    if (comment.refer.count > 0) {
        OSCCommentItemRefer *detailRefer = comment.refer[0];
        int i = 0;
        while (comment.refer.count > i) {
            NSMutableAttributedString *replyContent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:\n", detailRefer.author]];
            [replyContent appendAttributedString:[Utils emojiStringFromRawString:[detailRefer.content deleteHTMLTag]]];
            label.attributedText = replyContent;
            height += [label sizeThatFits:CGSizeMake( self.tableView.frame.size.width - 32 - (i+1)*9, MAXFLOAT)].height + 6;
            i++;
            if (i < comment.refer.count) {
                detailRefer = comment.refer[i];
            } else {
                break;
            }
        }
    } else {
        height = height;
    }
    
    return height + 76;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionNumber = 0;
//    if (_translationDetailComments.count > 0) {
//        sectionNumber += 1;
//    }
    return sectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    switch (section) {
//        case 0:
//        {
//            if (_translationDetailComments.count > 0) {
//                return _translationDetailComments.count+1;
//            }
//            break;
//        }
//            
//        default:
//            break;
//    }
    
    return 0;
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        
        if (_translationDetailComments.count > 0) {
            return [self headerViewWithSectionTitle:[NSString stringWithFormat:@"评论(%lu)", (unsigned long)_translationDetails.commentCount]];
        }
        return [self headerViewWithSectionTitle:@"评论"];
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            
            if (_translationDetailComments.count > 0) {
                if (indexPath.row == _translationDetailComments.count) {
                    return 44;
                } else {
                    return [self getCommentCellHeightWithComment:_translationDetailComments[indexPath.row]];
                }
            }
            
            
            break;
        }
        default:
            break;
    }
    
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_translationDetailComments.count > 0) {
        if (indexPath.row == _translationDetailComments.count) {
            UITableViewCell *cell = [UITableViewCell new];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.textLabel.text = @"更多评论";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
            
            return cell;
        } else {
            NewCommentCell *commentNewsCell = [NewCommentCell new];
            commentNewsCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (!commentNewsCell.contentTextView.delegate) {
                commentNewsCell.contentTextView.delegate = self;
            }
            OSCCommentItem *detailComment = _translationDetailComments[indexPath.row];
            commentNewsCell.comment = detailComment;
            
            if (detailComment.refer.count > 0) {
                commentNewsCell.referCommentView.hidden = NO;
            } else {
                commentNewsCell.referCommentView.hidden = YES;
            }
            commentNewsCell.commentButton.tag = indexPath.row;
            [commentNewsCell.commentButton addTarget:self action:@selector(selectedToComment:) forControlEvents:UIControlEventTouchUpInside];
            
            return commentNewsCell;
        }
        
    } else {
        UITableViewCell *cell = [UITableViewCell new];
        cell.textLabel.text = @"还没有评论";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (_translationDetailComments.count > 0 && indexPath.row == _translationDetailComments.count) {
            //评论列表
            NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:CommentIdTypeForTranslate sourceID:_translationDetails.id];
            [self.navigationController pushViewController:newCommentVC animated:YES];
        }
    }
    
    
}

#pragma --mark OSCInformationHeaderViewDelegate
- (BOOL)contentView:(IMYWebView *)webView
        shouldStart:(NSURLRequest *)request{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL name:nil];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}

-(void)contentViewDidFinishLoadWithHederViewHeight:(float)height{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.headerView.frame = CGRectMake(0, 0, kScreenSize.width - 16 * 2, height);
        self.tableView.tableHeaderView = self.headerView;
        [self hideHubView];
        [self.tableView reloadData];
    });
}


#pragma mark - 回复某条评论
- (void)selectedToComment:(UIButton *)button
{
    OSCCommentItem *comment =  _translationDetailComments[button.tag];
    
    if (_selectIndexPath == button.tag) {
        _isReply = !_isReply;
    } else {
        _isReply = YES;
    }
    _selectIndexPath = button.tag;
    
    if (_isReply) {
        if (comment.author.id > 0) {
            _commentTextView.placeholder = [NSString stringWithFormat:@"@%@", comment.author];
            _beRepliedCommentId = comment.id;
            _beRepliedCommentAuthorId = comment.author.id;
        } else {
            MBProgressHUD *hud = [Utils createHUD];
            hud.mode = MBProgressHUDModeCustomView;
            hud.label.text = @"该用户不存在，不可引用回复";
            [hud hideAnimated:YES afterDelay:1];
        }
        
    } else {
        _commentTextView.placeholder = @"发表评论";
    }
    
    [_commentTextView becomeFirstResponder];
}

#pragma mark - 发评论
- (void)sendCommentWithString:(NSString *)commentStr
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        
//        MBProgressHUD *HUD = [Utils createHUD];
//        [HUD showAnimated:YES];
        JDStatusBarView *staute = [JDStatusBarNotification showWithStatus:@"评论发送中.."];
        NSInteger fixedTranslastionId = _translationId > 10000000 ? _translationId-10000000:_translationId;
        NSDictionary *paraDic = @{
                                  @"sourceId":@(fixedTranslastionId),
                                  @"type":@(4),
                                  @"content":commentStr,
                                  @"reAuthorId": @(_beRepliedCommentAuthorId),
                                  @"replyId": @(_beRepliedCommentId)
                                  };
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX,OSCAPI_COMMENT_PUB]
          parameters:paraDic
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 if ([responseObject[@"code"]integerValue] == 1) {
                     staute.textLabel.text = @"评论成功";
                     [JDStatusBarNotification dismissAfter:2];
                     
//                     OSCNewComment *postedComment = [OSCNewComment mj_objectWithKeyValues:responseObject[@"result"]];
//                     [_translationDetailComments insertObject:postedComment atIndex:0];
                     _translationDetails.commentCount ++ ;
                     _commentTextView.text = @"";
                     _commentTextView.placeholder = @"发表评论";
                 }else {
                     staute.textLabel.text = [NSString stringWithFormat:@"错误：%@", responseObject[@"message"]];
                     [JDStatusBarNotification dismissAfter:2];
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [self.tableView reloadData];
                     [self updateRightButton:_translationDetails.commentCount];
                 });
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 staute.textLabel.text = @"网络异常，评论发送失败";
                 [JDStatusBarNotification dismissAfter:2];
                 [_commentTextView handleAttributeWithString:commentStr];
             }];
        
    }
    
}



#pragma mark - 更新收藏状态
- (void)updateFavButtonWithIsCollected:(BOOL)isCollected
{
    if (isCollected) {
        [_favButton setImage:[UIImage imageNamed:@"ic_faved_pressed"] forState:UIControlStateNormal];
    }else {
        [_favButton setImage:[UIImage imageNamed:@"ic_fav_pressed"] forState:UIControlStateNormal];
    }
}
#pragma mark - 收藏
- (IBAction)favClick:(id)sender {
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        
        NSDictionary *parameterDic =@{@"id"     : @(_translationId),
                                      @"type"   : @(4)};
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
                     [self.tableView reloadData];
                 });
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
//                 HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                 HUD.label.text = @"网络异常，操作失败";
                 
                 [HUD hideAnimated:YES afterDelay:1];
             }];
    }
}

#pragma mark - 分享
- (IBAction)shareClick:(id)sender {
    [_commentTextView resignFirstResponder];
    
    NSString *body = _translationDetails.body;
    NSString *href = _translationDetails.href;
    NSString *title = _translationDetails.title;
    
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
    [UMSocialData defaultData].extConfig.qqData.url = href;
    
    // 新浪微博相关设置
    [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:href];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"54c9a412fd98c5779c000752"
                                      shareText:[NSString stringWithFormat:@"%@...分享来自 %@", digest, href]
                                     shareImage:[UIImage imageNamed:@"logo"]
                                shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                       delegate:nil];
}

//#pragma mark - UITextFieldDelegate
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    return YES;
//}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    return YES;
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [self sendComment];
//    
//    [textField resignFirstResponder];
//    
//    return YES;
//}

- (void)keyboardDidShow:(NSNotification *)nsNotification
{
    
    //获取键盘的高度
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    _keyboardHeight = keyboardRect.size.height;
    
//    _bottomConstraint.constant = _keyboardHeight;
    
    [UIView animateWithDuration:1 animations:^{
        self.inputView.frame = CGRectMake(0, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - _keyboardHeight, kScreenSize.width, CGRectGetHeight(self.inputView.frame));
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)];
    [self.view addGestureRecognizer:_tap];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
//    _bottomConstraint.constant = 0;
    [self hideEditView];
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_commentTextView resignFirstResponder];
    [self.view removeGestureRecognizer:_tap];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [self.navigationController popViewControllerAnimated:YES];
    [super didReceiveMemoryWarning];
    
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
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld",_translationId];
    }
    return _inputView;
}
@end
