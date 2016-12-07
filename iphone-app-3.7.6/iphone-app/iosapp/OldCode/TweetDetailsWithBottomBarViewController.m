//
//  TweetDetailsWithBottomBarViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/14/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TweetDetailsWithBottomBarViewController.h"
#import "TweetDetailsViewController.h"
#import "CommentsViewController.h"
#import "OSCUserHomePageController.h"
#import "ImageViewerController.h"
#import "OSCTweet.h"
#import "OSCCommentItem.h"
#import "TweetDetailsCell.h"
#import "Config.h"
#import "Utils.h"

#import "TweetDetailNewTableViewController.h"

#import <objc/runtime.h>
#import <MBProgressHUD.h>
#import "JDStatusBarNotification.h"
#import "CommentTextView.h"
#import "OSCPopInputView.h"
#import "TweetFriendsListViewController.h"
#import "EmojiPageVC.h"

#define kScreenSize [UIScreen mainScreen].bounds.size
#define backViewHeight 46

@interface TweetDetailsWithBottomBarViewController () <UIWebViewDelegate,OSCPopInputViewDelegate,CommentTextViewDelegate>

@property (nonatomic, strong) TweetDetailNewTableViewController *tweetDetailsNewVC;
@property (nonatomic, assign) int64_t tweetID;
@property (nonatomic, assign) BOOL isReply;

@property (nonatomic,strong) CommentTextView *commentTextView;
@property (nonatomic,strong) OSCPopInputView *inputView;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) NSAttributedString *beforeATStr;   //储存@人之前的string

@property (nonatomic,assign) BOOL isEmojiPageOnScreen;
@property (nonatomic,strong) EmojiPageVC *emojiVC;

@end

@implementation TweetDetailsWithBottomBarViewController

- (instancetype)initWithTweetID:(int64_t)tweetID
{
    self = [super init];
    if (self) {
		
        self.hidesBottomBarWhenPushed = YES;
        _tweetID = tweetID;
        _tweetDetailsNewVC = [[TweetDetailNewTableViewController alloc]init];
        _tweetDetailsNewVC.tweetID = _tweetID;
        [self addChildViewController:_tweetDetailsNewVC];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [self setUpBlock];
    }
    
    return self;
}

- (void)addCommentTextView{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake( 0, kScreenSize.height - 64 - backViewHeight, kScreenSize.width, backViewHeight)];
    bottomView.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1)];
    lineView.backgroundColor = [UIColor colorWithHex:0xd8d8d8];
    [bottomView addSubview:lineView];
    _commentTextView = [[CommentTextView alloc] initWithFrame:CGRectMake(8, 9, kScreenSize.width - 16, backViewHeight - 16) WithPlaceholder:@"发表评论" WithFont:[UIFont systemFontOfSize:15.0]];
    _commentTextView.commentTextViewDelegate = self;
    [bottomView addSubview:_commentTextView];
    [self.view addSubview:bottomView];
}

- (void)setUpBlock
{
    __weak TweetDetailsWithBottomBarViewController *weakSelf = self;

    _tweetDetailsNewVC.didTweetCommentSelected = ^(OSCCommentItem *comment) {
        NSString *authorString = [NSString stringWithFormat:@"@%@ ", comment.author.name];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithAttributedString:weakSelf.commentTextView.attributedText];
        if (attributeStr.length > 0) {
            attributeStr = [[attributeStr attributedSubstringFromRange:NSMakeRange(4, attributeStr.length - 4)] mutableCopy];
        }
        NSMutableAttributedString *authorAttri = [[NSMutableAttributedString alloc] initWithString:authorString];
        [authorAttri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0] range:NSMakeRange(0, authorAttri.length)];
        [attributeStr appendAttributedString:authorAttri];
        [weakSelf ClickTextViewWithAttribute:[attributeStr copy]];
        
//        if ([weakSelf.editingBar.editView.text rangeOfString:authorString].location == NSNotFound) {
//            [weakSelf.editingBar.editView replaceRange:weakSelf.editingBar.editView.selectedTextRange withText:authorString];
//            [weakSelf.editingBar.editView becomeFirstResponder];
//        }
    };

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"动弹详情";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setLayout];
	[self addCommentTextView];
	
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setLayout
{
    [self.view addSubview:_tweetDetailsNewVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    _tweetDetailsNewVC.view.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - backViewHeight);
}


- (void)sendContentWithView:(__kindof UITextView *)inputView
{
//    MBProgressHUD *HUD = [Utils createHUD];
//    HUD.label.text = @"评论发送中";

    JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"评论发送中.."];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_COMMENT_PUB]
       parameters:@{
                    @"catalog": @(3),
                    @"id": @(_tweetID),
                    @"uid": @([Config getOwnID]),
                    @"content": [Utils convertRichTextToRawText:inputView],
                    @"isPostToMyZone": @(0)
                    }
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
              ONOXMLElement *result = [responseDocument.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
              
//              HUD.mode = MBProgressHUDModeCustomView;
              
              if (errorCode == 1) {
                  
//                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
//                  HUD.label.text = @"评论发表成功";
                  
                  stauts.textLabel.text = @"评论发表成功";
                  
                  [_tweetDetailsNewVC.tableView setContentOffset:CGPointZero animated:NO];
                  [_tweetDetailsNewVC reloadCommentList];
                  
              } else {
//                  HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  stauts.textLabel.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
              }
              
//              [HUD hideAnimated:YES afterDelay:1];
              [JDStatusBarNotification dismissAfter:2];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              HUD.mode = MBProgressHUDModeCustomView;
//              HUD.label.text = @"网络异常，动弹发送失败";
//              
//              [HUD hideAnimated:YES afterDelay:1];
              stauts.textLabel.text = @"网络异常，动弹发送失败";
              [JDStatusBarNotification dismissAfter:2];
          }];
}

- (void)keyboardWillShow:(NSNotification *)nsNotification {
    
    //获取键盘的高度
    
    self.emojiVC.view.hidden = YES;
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    float keyboardHeight = keyboardRect.size.height;
    
    [UIView animateWithDuration:1 animations:^{
        self.inputView.frame = CGRectMake(0, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - keyboardHeight, kScreenSize.width, CGRectGetHeight(self.inputView.frame));
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];
    
}

#pragma CommentTextViewDelegate
- (void)ClickTextViewWithAttribute:(NSAttributedString *)attribute{
    [self showEditView];
    [self.inputView restoreDraftNoteWithAttribute:attribute];
}

#pragma --mark OSCPopInputViewDelegate
- (void)popInputViewDidDismiss:(OSCPopInputView* )popInputView draftNoteAttribute:(NSAttributedString *)draftNoteAttribute{
    _beforeATStr = draftNoteAttribute;
    [_commentTextView handleAttributeWithAttribute:draftNoteAttribute];
}

- (void)popInputViewClickDidAtButton:(OSCPopInputView* )popInputView{
    TweetFriendsListViewController * vc = [TweetFriendsListViewController new];
    [self hideEditView];
    [vc setSelectDone:^(NSString *result) {
        [self showEditView];
        NSMutableAttributedString *attribute = [_beforeATStr mutableCopy];
        NSMutableAttributedString *resulAtt = [[NSMutableAttributedString alloc] initWithString:result];
        [resulAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0] range:NSMakeRange(0, result.length)];
        [attribute appendAttributedString:resulAtt];
        [self.inputView restoreDraftNoteWithAttribute:attribute];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)popInputViewClickDidSendButton:(OSCPopInputView *)popInputView selectedforwarding:(BOOL)isSelectedForwarding curTextView:(UITextView *)textView{
    _beforeATStr = nil;
    [self sendContentWithView:textView];
    [self.inputView clearDraftNote];
    [self hideEditView];
}

- (void)popInputViewClickDidEmojiButton:(OSCPopInputView *)popInputView{
    [self showAndHideEmoij];
}

- (void)showEditView{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    _backView = [[UIView alloc] initWithFrame:window.bounds];
    _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 300)];
    tapView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackView:)];
    [tapView addGestureRecognizer:tapGR];
    [_backView addSubview:tapView];
    self.emojiVC = [[EmojiPageVC alloc] initWithTextView:self.inputView];
    self.emojiVC.view.frame = CGRectMake(0, kScreenSize.height - 216, kScreenSize.width, 216);
    self.emojiVC.view.hidden = YES;
    [_backView addSubview:self.emojiVC.view];
    [_backView addSubview:self.inputView];
    [self.inputView activateInputView];
    [window addSubview:_backView];
}

- (void)hideEditView{
    [self.inputView freezeInputView];
    [UIView animateWithDuration:0.3 animations:^{
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.inputView.frame = CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) ;
        self.emojiVC.view.frame = CGRectMake(0, kScreenSize.height, kScreenSize.width, 216);
    } completion:^(BOOL finished) {
        [_backView removeFromSuperview];
        _backView = nil;
    }];
}

- (OSCPopInputView *)inputView{
    if(!_inputView){
        _inputView = [OSCPopInputView popInputViewWithFrame:CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) maxStringLenght:160 delegate:self autoSaveDraftNote:YES];
        _inputView.draftKeyID = [NSString stringWithFormat:@"%lld",_tweetID];
        _inputView.popInputViewType = OSCPopInputViewType_At | OSCPopInputViewType_Emoji;
    }
    return _inputView;
}

- (void)touchBackView:(UITapGestureRecognizer *)tapGR{
    CGPoint point = [tapGR locationInView:_backView];
    CGRect rect = CGRectMake(0, 0, kScreenSize.width, CGRectGetMinY(self.inputView.frame));
    if (CGRectContainsPoint(rect,point)) {
        [self hideEditView];
    }
}

- (void)showAndHideEmoij{
    if (_isEmojiPageOnScreen) {
        self.emojiVC.view.hidden = YES;
        [self.inputView beginEditing];
        _isEmojiPageOnScreen = NO;
    } else {
        [self.inputView endEditing];
        [UIView animateWithDuration:0.2 animations:^{
            self.inputView.frame = CGRectMake( 0, kScreenSize.height - 216 - CGRectGetHeight(self.inputView.frame), kScreenSize.width, CGRectGetHeight(self.inputView.frame));
        }];
        self.emojiVC.view.hidden = NO;
        _isEmojiPageOnScreen = YES;
    }
}


@end
