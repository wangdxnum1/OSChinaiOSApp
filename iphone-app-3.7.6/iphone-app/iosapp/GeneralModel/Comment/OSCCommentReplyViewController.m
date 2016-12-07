//
//  OSCCommentReplyViewController.m
//  iosapp
//
//  Created by 李萍 on 2016/11/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCCommentReplyViewController.h"
#import "NewCommentCell.h"
#import "CommentDetailViewController.h"
#import "NewLoginViewController.h"

#import "OSCAPI.h"
#import "Utils.h"
#import "OSCCommentItem.h"
#import "Config.h"

#import <MJExtension.h>
#import <MJRefresh.h>
#import <MBProgressHUD.h>

#import "CommentTextView.h"
#import "OSCPopInputView.h"
#import "OSCModelHandler.h"
#import "TweetFriendsListViewController.h"
#import "JDStatusBarNotification.h"

static NSString *newCommentReuseIdentifier = @"NewCommentCell";
@interface OSCCommentReplyViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,OSCPopInputViewDelegate,CommentTextViewDelegate>

@property (nonatomic, assign) CommentIdType commentType;
@property (nonatomic, assign) NSInteger sourceId;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, copy) NSString *nextPageToken;

//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, assign) BOOL isReply;
@property (nonatomic, assign) NSInteger selectIndexPath;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic,strong) OSCPopInputView *inputView;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) NSString *beforeATStr;   //储存@人之前的string
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CommentTextView *commentTextView;

@end

@implementation OSCCommentReplyViewController

- (instancetype)initWithCommentType:(CommentIdType)commentType sourceID:(NSInteger)sourceId
{
    self = [super init];
    
    if (self) {
        _commentType = commentType;
        _sourceId = sourceId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"评论列表";
    _comments = [NSMutableArray new];
    _nextPageToken = @"";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.commentTextView.commentTextViewDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[NewCommentCell class] forCellReuseIdentifier:newCommentReuseIdentifier];
    self.tableView.tableFooterView = [UIView new];
    self.commentTextView.commentTextViewDelegate = self;
    self.commentTextView.placeholder = @"我要评论";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 250;
    [self getCommentData:NO];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //        [self.tableView.mj_header beginRefreshing];
        [self getCommentData:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        //        [self.tableView.mj_header beginRefreshing];
        [self getCommentData:NO];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据
- (void)getCommentData:(BOOL)isRefresh
{
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_COMMENTS_LIST];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    if (isRefresh) {
        _nextPageToken = @"";
    }
    [manger GET:blogDetailUrlStr
     parameters:@{
                  @"sourceId"  : @(self.sourceId),
                  @"type"      : @(self.commentType),
                  @"pageToken" : _nextPageToken,
//                  @"parts"     : @"refer",
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary *result = responseObject[@"result"];
                NSArray *jsonItems = result[@"items"];
                NSArray *array = [OSCCommentItem mj_objectArrayWithKeyValuesArray:jsonItems];
                _nextPageToken = result[@"nextPageToken"];
                
                if (isRefresh) {
                    [_comments removeAllObjects];
                }
                [_comments addObjectsFromArray:array];
                if (isRefresh) {
                    [self.tableView.mj_header endRefreshing];
                }else{
                    [self.tableView.mj_footer endRefreshing];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView reloadData];
                });
            } else {
                MBProgressHUD *hud = [Utils createHUD];
                hud.mode = MBProgressHUDModeCustomView;
                hud.label.text = responseObject[@"message"];
                
                [hud hideAnimated:YES afterDelay:1];
                
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
            NSLog(@"error = %@",error);
        }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_comments.count > 0) {
        return _comments.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:newCommentReuseIdentifier forIndexPath:indexPath];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (_comments.count > indexPath.row) {
            OSCNewComment *comment = _comments[indexPath.row];
            
            CommentDetailViewController *commentDetailVC = [CommentDetailViewController new];
            commentDetailVC.questDetailId = self.sourceId;
            commentDetailVC.commentId = comment.id;
            [self.navigationController pushViewController:commentDetailVC animated:YES];
        }
        
    }
}

- (void)keyboardDidShow:(NSNotification *)nsNotification
{
    
    //获取键盘的高度
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    _keyboardHeight = keyboardRect.size.height;
    
    [UIView animateWithDuration:1 animations:^{
        self.inputView.frame = CGRectMake(0, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - _keyboardHeight, kScreenSize.width, CGRectGetHeight(self.inputView.frame));
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];
    
    //    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)];
    //    [self.view addGestureRecognizer:_tap];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    //    _bottomConstraint.constant = 0;
    [self hideEditView];
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [self.view removeGestureRecognizer:_tap];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 评论
- (void)selectedToComment:(UIButton *)button
{
    OSCCommentItem *comment = _comments[button.tag];
    
    if (_selectIndexPath == button.tag) {
        _isReply = !_isReply;
    } else {
        _isReply = YES;
    }
    _selectIndexPath = button.tag;
    
    if (_isReply) {
        if (comment.author.id > 0) {
            _commentTextView.placeholder = [NSString stringWithFormat:@"@%@ ", comment.author.name];
        } else {
            MBProgressHUD *hud = [Utils createHUD];
            hud.mode = MBProgressHUDModeCustomView;
            hud.label.text = @"该用户不存在，不可引用回复";
            [hud hideAnimated:YES afterDelay:1];
        }
        
    } else {
        _commentTextView.placeholder = @"我要评论";
    }
    [_commentTextView becomeFirstResponder];
}

#pragma mark - 发评论
- (void)sendComment:(NSInteger)replyID authorID:(NSInteger)authorID withString:(NSString *)commentStr
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    } else {
        
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"评论发送中..."];
        [manger POST:[NSString stringWithFormat:@"%@comment_pub", OSCAPI_V2_PREFIX]
          parameters:@{
                       @"sourceId"   : @(self.sourceId),
                       @"type"       : @(self.commentType),
                       @"content"    : commentStr,
                       @"replyId"    : @(replyID),
                       @"reAuthorId" : @(authorID),
                       }
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 if ([responseObject[@"code"]integerValue] == 1) {
                     stauts.textLabel.text = @"发送成功";
                     [JDStatusBarNotification dismissAfter:2];
                     
                     OSCNewComment *postedComment = [OSCNewComment mj_objectWithKeyValues:responseObject[@"result"]];
                     
                     if (postedComment) {
                         [_comments insertObject:[self commentItemForNewCommentModel:postedComment] atIndex:0];
                     }
                 }else{
                     stauts.textLabel.text = responseObject[@"message"];
                     [JDStatusBarNotification dismissAfter:2];
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [self.tableView reloadData];
                 });
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 stauts.textLabel.text = @"网络错误，发送失败";
                 [JDStatusBarNotification dismissAfter:2];
                 [_commentTextView handleAttributeWithString:commentStr];
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

#pragma CommentTextViewDelegate
- (void)ClickTextViewWithString:(NSString *)string{
    [self showEditView];
    if ((!string || [string isEqualToString:@""]) && ![[_commentTextView getPlace] isEqualToString:@"我要评论"]) {
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
    if (_isReply) {
        OSCCommentItem *comment = _comments[_selectIndexPath];
        if ([Config getOwnID] == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
            NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
            [self presentViewController:loginVC animated:YES completion:nil];
        } else {
            [self sendComment:comment.id authorID:comment.author.id withString:textView.text];
        }
        
    } else {
        if (textView.text > 0) {
            if ([Config getOwnID] == 0) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
                NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
                [self presentViewController:loginVC animated:YES completion:nil];
            } else {
                [self sendComment:0 authorID:0 withString:textView.text];
            }
        } else {
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.label.text = @"评论不能为空";
            
            [HUD hideAnimated:YES afterDelay:1];
        }
    }
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
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld",(long)_sourceId];
    }
    return _inputView;
}

@end
