//
//  CommentDetailViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/17.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "CommentDetailViewController.h"
#import "QuestCommentHeadDetailCell.h"
#import "NewCommentCell.h"
#import "ContentWebViewCell.h"

#import "Utils.h"
#import "OSCAPI.h"
#import "Config.h"
#import "NewLoginViewController.h"

#import <MJExtension.h>
#import <MBProgressHUD.h>

#import "CommentTextView.h"
#import "JDStatusBarNotification.h"
#import "OSCPopInputView.h"
#import "OSCModelHandler.h"
#import "TweetFriendsListViewController.h"

static NSString* const CommentHeadDetailCellIdentifier = @"QuestCommentHeadDetailCell";
static NSString *contentWebReuseIdentifier = @"contentWebTableViewCell";
static NSString * const newCommentReuseIdentifier = @"NewCommentCell";

@interface CommentDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate,UITextFieldDelegate,CommentTextViewDelegate,OSCPopInputViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet CommentTextView *commentTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstrait;


@property (nonatomic, strong) UIView *popUpBoxView;
@property (nonatomic, strong) UIButton *upImageView;
@property (nonatomic, strong) UILabel *upLabel;
@property (nonatomic, strong) UIButton *downImageView;
@property (nonatomic, strong) UILabel *downLabel;

//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, assign) BOOL isReply;
@property (nonatomic, assign) NSInteger selectIndexPath;

@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, copy) OSCNewComment *commentDetail;
@property (nonatomic) NSInteger replyId;
@property (nonatomic) NSInteger reAuthorId;
@property (nonatomic, strong) NSMutableArray *commentReplies;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic,strong) OSCPopInputView *inputView;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) NSString *beforeATStr;   //储存@人之前的string

@end

@implementation CommentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.commentTextView.commentTextViewDelegate = self;
    self.commentTextView.placeholder = @"我要回答";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.estimatedRowHeight = 250;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"QuestCommentHeadDetailCell" bundle:nil] forCellReuseIdentifier:CommentHeadDetailCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ContentWebViewCell" bundle:nil] forCellReuseIdentifier:contentWebReuseIdentifier];
    [self.tableView registerClass:[NewCommentCell class] forCellReuseIdentifier:newCommentReuseIdentifier];
	
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self getDataForCommentDetail];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 获取数据
- (void)getDataForCommentDetail
{
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@comment", OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:blogDetailUrlStr
     parameters:@{
                  @"id"  : @(self.commentId),
                  @"type"      : @(2),
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"] integerValue] == 1) {
                _commentDetail = [OSCNewComment mj_objectWithKeyValues:responseObject[@"result"]];
                _commentReplies = [OSCNewCommentReply mj_objectArrayWithKeyValuesArray:responseObject[@"result"][@"reply"]];
                _replyId = _commentDetail.id;
                _reAuthorId = _commentDetail.authorId;
                NSDictionary *data = @{@"content":  _commentDetail.content};
                _commentDetail.content = [Utils HTMLWithData:data
                                             usingTemplate:@"newTweet"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
            
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"error = %@",error);
        }];
}

#pragma mark - 右导航栏按钮
- (void)rightBarButtonClicked
{
    //
    NSLog(@"右导航栏按钮");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"举报"
                                                        message:@"message"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].placeholder = @"举报原因";
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        /* 新举报接口 */
//        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
//        
//        [manger POST:[NSString stringWithFormat:@"%@report", OSCAPI_V2_PREFIX]
//          parameters:@{
//                       @"sourceId"   : @(self.commentId),
//                       @"type"       : @(2),
//                       //@"href"       : @(),//举报的文章地址
//                       @"reason"     : @(0), //0 其他原因 1 广告 2 色情 3 翻墙 4 非IT话题
//                      // @"memo"       : @(authorID),//当reason为其他原因时，该字段不能为空
//                       }
//             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//                 if ([responseObject[@"code"]integerValue] == 1) {
//                     MBProgressHUD *HUD = [Utils createHUD];
//                     HUD.mode = MBProgressHUDModeCustomView;
//                     HUD.label.text = @"评论成功";
//                     
//                     [HUD hideAnimated:YES afterDelay:1];
//                 }
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     
//                     [self.tableView reloadData];
//                 });
//             }
//             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//                 NSLog(@"%@",error);
//             }];
    }
}

#pragma MARK - 踩/顶
- (void)roteUpOrDown
{
    [self customPopUpBoxView];
}

#pragma mark - 自定义弹出框
- (void)customPopUpBoxView
{
    UIWindow *selfWindow = [UIApplication sharedApplication].keyWindow;
    _popUpBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(selfWindow.frame), CGRectGetHeight(selfWindow.frame))];
    _popUpBoxView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.5];
    _popUpBoxView.userInteractionEnabled = YES;
    [_popUpBoxView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenPopUpBoxView)]];
    [selfWindow addSubview:_popUpBoxView];
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(selfWindow.frame)-240)/2, (CGRectGetHeight(selfWindow.frame)-200)/2, 240, 120)];
    subView.backgroundColor = [UIColor whiteColor];
    [subView setCornerRadius:3.0];
    [_popUpBoxView addSubview:subView];
    
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor newSecondTextColor];
    label.text = @"为这个回答投票";
    [subView addSubview:label];
    
    _upImageView = [UIButton new];
    
    [subView addSubview:_upImageView];
    [_upImageView addTarget:self action:@selector(voteUpQuestions:) forControlEvents:UIControlEventTouchUpInside];
    
    _upLabel = [UILabel new];
    _upLabel.textAlignment = NSTextAlignmentCenter;
    _upLabel.font = [UIFont systemFontOfSize:13];
    _upLabel.textColor = [UIColor newAssistTextColor];
    _upLabel.text = @"顶";
    [subView addSubview:_upLabel];
    
    _downImageView = [UIButton new];
    
    [subView addSubview:_downImageView];
    [_downImageView addTarget:self action:@selector(voteDownQuestions:) forControlEvents:UIControlEventTouchUpInside];
    
    _downLabel = [UILabel new];
    _downLabel.textAlignment = NSTextAlignmentCenter;
    _downLabel.font = [UIFont systemFontOfSize:13];
    _downLabel.textColor = [UIColor newAssistTextColor];
    _downLabel.text = @"踩";
    [subView addSubview:_downLabel];
    
    //按钮状态样式
    [self judgeVoteState];
    
    //布局
    for (UIView *view in subView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(label, _upImageView, _upLabel, _downImageView, _downLabel);
    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label]"
                                                                    options:NSLayoutFormatAlignAllCenterY
                                                                    metrics:nil views:views]];
    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[label]-16-|"
                                                                    options:0
                                                                    metrics:nil views:views]];
    
    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label]-10-[_upImageView(45)]-10-[_upLabel]"
                                                                    options:0
                                                                    metrics:nil views:views]];
    
    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label]-10-[_downImageView(45)]-10-[_downLabel]"
                                                                    options:0
                                                                    metrics:nil views:views]];
    
    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-55-[_upImageView(45)]-40-[_downImageView(45)]"
                                                                             options:0
                                                                             metrics:nil views:views]];
    [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-55-[_upLabel(45)]-40-[_downLabel(45)]"
                                                                    options:0
                                                                    metrics:nil views:views]];
}

// 顶/踩 按钮样式
- (void)judgeVoteState
{
    switch (_commentDetail.voteState) {
        case 0:
        {
            [_upImageView setImage:[UIImage imageNamed:@"ic_vote_up_big_normal"] forState:UIControlStateNormal];
            [_downImageView setImage:[UIImage imageNamed:@"ic_vote_down_big_normal"] forState:UIControlStateNormal];
            break;
        }
        case 1://已顶
        {
//            _downImageView.enabled = NO;
            [_upImageView setImage:[UIImage imageNamed:@"ic_vote_up_big_actived"] forState:UIControlStateNormal];
            [_downImageView setImage:[UIImage imageNamed:@"ic_vote_down_big_normal"] forState:UIControlStateNormal];
            break;
        }
        case 2://已踩
        {
//            _upImageView.enabled = NO;
            [_upImageView setImage:[UIImage imageNamed:@"ic_vote_up_big_normal"] forState:UIControlStateNormal];
            [_downImageView setImage:[UIImage imageNamed:@"ic_vote_down_big_actived"] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

#pragma mark - 顶

- (void)voteUpQuestions:(UIButton *)button
{
    if ([Config getOwnID] == 0) {
        [_popUpBoxView removeFromSuperview];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        if (_commentDetail.voteState == 2) {
            MBProgressHUD *hud = [Utils createHUD];
            hud.mode = MBProgressHUDModeCustomView;
            hud.label.text = @"已经踩过了，不可以同时进行顶哦！";
            [hud hideAnimated:YES afterDelay:1];
        } else {
            [self postToVote:1];
            [_popUpBoxView removeFromSuperview];
        }
    }
}

#pragma mark - 踩
- (void)voteDownQuestions:(UIButton *)button
{
    if ([Config getOwnID] == 0) {
        [_popUpBoxView removeFromSuperview];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    } else {
        if (_commentDetail.voteState == 1) {
            MBProgressHUD *hud = [Utils createHUD];
            hud.mode = MBProgressHUDModeCustomView;
            hud.label.text = @"已经顶过了，不可以同时进行踩哦！";
            [hud hideAnimated:YES afterDelay:1];
        } else {
            [self postToVote:2];
            [_popUpBoxView removeFromSuperview];
        }
    }
}

- (void)hidenPopUpBoxView
{
    [_popUpBoxView removeFromSuperview];
}

- (void)postToVote:(NSInteger)voteType
{
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@question_vote", OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger POST:blogDetailUrlStr
     parameters:@{
                  @"sourceId"   : @(self.questDetailId),
                  @"commmentId" : @(self.commentId),
                  @"voteOpt"    : @(voteType),
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary *result = responseObject[@"result"];
                _commentDetail.voteState = [result[@"voteState"] integerValue];
                _commentDetail.vote = [result[@"vote"] integerValue];
                
                [self judgeVoteState];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            } else {
                MBProgressHUD *hud = [Utils createHUD];
                hud.mode = MBProgressHUDModeCustomView;
                hud.label.text = responseObject[@"message"];
                [hud hideAnimated:YES afterDelay:1];
            }
            
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            
            NSLog(@"error = %@",error);
        }];
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            QuestCommentHeadDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentHeadDetailCellIdentifier forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.downOrUpButton addTarget:self action:@selector(roteUpOrDown) forControlEvents:UIControlEventTouchUpInside];
            
            cell.commentDetail = _commentDetail;
            
            return cell;
        } else {
            ContentWebViewCell *webViewCell = [tableView dequeueReusableCellWithIdentifier:contentWebReuseIdentifier forIndexPath:indexPath];
            webViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            webViewCell.contentWebView.delegate = self;
            [webViewCell.contentWebView loadHTMLString:_commentDetail.content baseURL:[NSBundle mainBundle].resourceURL];
            webViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return webViewCell;
        }
    } else if (indexPath.section == 1) {
        NewCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:newCommentReuseIdentifier forIndexPath:indexPath];
        commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (_commentReplies.count > 0) {
            OSCNewCommentReply *reply = _commentReplies[indexPath.row];
            [commentCell setDataForQuestionCommentReply:reply];
            
            commentCell.commentButton.tag = indexPath.row;
            [commentCell.commentButton addTarget:self action:@selector(selectedToComment:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return commentCell;
    }
    
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 60;
        } else {
            return _webViewHeight+30;
        }
    } else if (indexPath.section == 1) {
//        if (_commentReplies.count > 0) {
//            UILabel *label = [UILabel new];
//            label.font = [UIFont systemFontOfSize:14];
//            label.numberOfLines = 0;
//            label.lineBreakMode = NSLineBreakByWordWrapping;
//            
//            OSCNewCommentReply *quesCommentReply = _commentReplies[indexPath.row];
//            label.attributedText = [NewCommentCell contentStringFromRawString:quesCommentReply.content];
//            
//            CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 32, MAXFLOAT)].height;
//            
//            return height + 71;
//        } else {
//            return 0;
//        }
        
        return UITableViewAutomaticDimension;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_commentReplies.count > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return _commentReplies.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerViewHeight = 0.001;
    if (section != 0) {
        headerViewHeight = 32;
    }
    return headerViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        if (_commentReplies.count > 0) {
            return [self headerViewWithSectionTitle:[NSString stringWithFormat:@"评论(%lu)", (unsigned long)_commentReplies.count]];
        }
        return [self headerViewWithSectionTitle:@"评论"];
    }
    
    return [UIView new];
}

#pragma mark -- DIY_headerView
- (UIView *)headerViewWithSectionTitle:(NSString *)title {
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

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL name:nil];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    if (_webViewHeight == webViewHeight) {return;}
    _webViewHeight = webViewHeight;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
    
//    _bottomConstrait.constant = _keyboardHeight;
    [UIView animateWithDuration:1 animations:^{
        self.inputView.frame = CGRectMake(0, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - _keyboardHeight, kScreenSize.width, CGRectGetHeight(self.inputView.frame));
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)];
    [self.view addGestureRecognizer:_tap];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
//    _bottomConstrait.constant = 0;
    [self hideEditView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_commentTextView resignFirstResponder];
    [self.view removeGestureRecognizer:_tap];
}

#pragma mark - 评论
- (void)selectedToComment:(UIButton *)button
{
    OSCNewCommentReply *reply = _commentReplies[button.tag];
    
    if (_selectIndexPath == button.tag) {
        _isReply = !_isReply;
    } else {
        _isReply = YES;
    }
    _selectIndexPath = button.tag;
    
    if (_isReply) {
//        _replyId = reply.id;
//        _reAuthorId = reply.authorId;
//        _commentField.placeholder = [NSString stringWithFormat:@"@%@", reply.author];
        _commentTextView.text = [NSString stringWithFormat:@"[草稿]回复：@%@ ",reply.author];
    } else {
//        _replyId = _commentDetail.id;
//        _reAuthorId = _commentDetail.authorId;
        _commentTextView.placeholder = @"我要回答";
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
        JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"评论发送中.."];
        NSDictionary *paraDic = @{@"sourceId"   : @(self.questDetailId),
                                  @"type"       : @(2),
                                  @"content"    : commentStr,
                                  @"replyId"    : @(_commentDetail.id),
                                  @"reAuthorId" : @(_commentDetail.authorId)
                                  };

        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        [manger POST:[NSString stringWithFormat:@"%@comment_pub", OSCAPI_V2_PREFIX]
          parameters:paraDic
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 
                 if ([responseObject[@"code"]integerValue] == 1) {
//                     MBProgressHUD *HUD = [Utils createHUD];
//                     HUD.mode = MBProgressHUDModeCustomView;
//                     HUD.label.text = @"评论成功";
                     stauts.textLabel.text = @"评论成功";
                     [JDStatusBarNotification dismissAfter:2];
                     
                     OSCNewCommentReply *postedComment = [OSCNewCommentReply mj_objectWithKeyValues:responseObject[@"result"]];
                     if (postedComment) {
                         [_commentReplies insertObject:postedComment atIndex:0];
                     }
//                     [HUD hideAnimated:YES afterDelay:1];
                     _commentTextView.text = @"";
                     _commentTextView.placeholder = @"我要回答";
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 stauts.textLabel.text = @"网络异常，评论发送失败";
                 [JDStatusBarNotification dismissAfter:2];
                 [_commentTextView handleAttributeWithString:commentStr];
             }];
        
    }
}

#pragma CommentTextViewDelegate
- (void)ClickTextViewWithString:(NSString *)string{
    [self showEditView];
    if ((!string || [string isEqualToString:@""]) && ![[_commentTextView getPlace] isEqualToString:@"我要回答"]) {
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

- (void)popInputViewClickDidSendButton:(OSCPopInputView *)popInputView selectedforwarding:(BOOL)isSelectedForwarding curTextView:(UITextView *)textView{
    _beforeATStr = @"";
    [self sendCommentWithString:textView.text];
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
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld",self.commentId];
    }
    return _inputView;
}

@end
