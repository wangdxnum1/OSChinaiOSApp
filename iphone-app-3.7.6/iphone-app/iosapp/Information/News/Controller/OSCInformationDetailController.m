//
//  OSCInformationDetailController.m
//  iosapp
//
//  Created by Graphic-one on 16/9/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCInformationDetailController.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCAPI.h"
#import "OSCInformationDetails.h"
#import "OSCModelHandler.h"
#import "OSCBlogDetail.h"
#import "Utils.h"
#import "OSCInformationHeaderView.h"
#import "RelatedSoftWareCell.h"
#import "RecommandBlogTableViewCell.h"
#import "NewCommentCell.h"
#import "NewLoginViewController.h"
#import "Config.h"
#import "CommentTextView.h"
#import "OSCPopInputView.h"
#import "JDStatusBarNotification.h"
#import "TweetFriendsListViewController.h"
#import "SoftWareViewController.h"
#import "CommentsBottomBarViewController.h"
#import "NewCommentListViewController.h"
#import "QuesAnsDetailViewController.h"
#import "TranslationViewController.h"
#import "ActivityDetailViewController.h"
#import "OSCPushTypeControllerHelper.h"

#import <UMSocial.h>
#import <MBProgressHUD.h>
#import <MJExtension.h>

#define Large_Frame  (CGRect){{0,0},{40,25}}
#define Medium_Frame (CGRect){{0,0},{30,25}}
#define Small_Frame  (CGRect){{0,0},{25,25}}
#define kBottomHeight 46

static NSString *relatedSoftWareReuseIdentifier = @"RelatedSoftWareCell";
static NSString *recommandBlogReuseIdentifier = @"RecommandBlogTableViewCell";

@interface OSCInformationDetailController () <UITableViewDelegate,UITableViewDataSource,OSCInformationHeaderViewDelegate,CommentTextViewDelegate,OSCPopInputViewDelegate>

@property (nonatomic,assign) NSInteger informationID;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) OSCInformationDetails *newsDetail;
@property (nonatomic,strong) NSMutableArray *newsDetailRecommends;
@property (nonatomic,strong) NSMutableArray *newsDetailComments;
@property (nonatomic,strong) OSCInformationHeaderView *headerView;
@property (nonatomic,strong) UIButton *rightBarBtn;
@property (nonatomic,strong) MBProgressHUD *hud;

//被评论的某条评论的信息
@property (nonatomic) NSInteger beRepliedCommentAuthorId;
@property (nonatomic) NSInteger beRepliedCommentId;
@property (nonatomic, assign) BOOL isReply;
@property (nonatomic, assign) NSInteger selectIndexPath;

@property (nonatomic, strong)UIButton *favButton;

@property (nonatomic, strong)CommentTextView *commentTextView;
@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong)OSCPopInputView *inputView;
@property (nonatomic,strong) NSString *beforeATStr;   //储存@人之前的string

@end

@implementation OSCInformationDetailController

- (instancetype)initWithInformationID:(NSInteger)informationID{
    _informationID = informationID;
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSelf];
    [self addContentView];
    [self addBottmView];
    
//    [self getCommentDetail];
    [self getNewsData];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [self.view addSubview:_hud];
    
    [self updateRightButton:0];
    
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
    [self.navigationController popViewControllerAnimated:YES];
    [super didReceiveMemoryWarning];
}

- (void)setSelf{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"资讯详情";
}

- (void)addContentView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, kScreenSize.height - 64 - kBottomHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.sectionHeaderHeight = 32;
    self.tableView.estimatedRowHeight = 250;
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RelatedSoftWareCell" bundle:nil] forCellReuseIdentifier:relatedSoftWareReuseIdentifier];
    [self.view addSubview:_tableView];
}

- (void)addBottmView{
    UIView *bottomBackView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenSize.height - kBottomHeight, kScreenSize.width, kBottomHeight)];
    bottomBackView.backgroundColor = [UIColor whiteColor];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1)];
    lineView.backgroundColor = [UIColor colorWithHex:0xd8d8d8];
    [bottomBackView addSubview:lineView];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake( kScreenSize.width - 36, 13, 20, 20);
    [shareButton setImage:[UIImage imageNamed:@"ic_share_black_pressed"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackView addSubview:shareButton];
    
    _favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _favButton.frame = CGRectMake( kScreenSize.width - 36 * 2, 13, 20, 20);
    [_favButton setImage:[UIImage imageNamed:@"ic_fav_normal"] forState:UIControlStateNormal];
    [_favButton addTarget:self action:@selector(favClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackView addSubview:_favButton];
    
    _commentTextView = [[CommentTextView alloc] initWithFrame:CGRectMake(8, 8,CGRectGetMinX(_favButton.frame) - 20, 30) WithPlaceholder:@"发表评论" WithFont:[UIFont systemFontOfSize:14.0]];
    _commentTextView.commentTextViewDelegate = self;
    [bottomBackView addSubview:_commentTextView];
    
    [self.view addSubview:bottomBackView];
}

#pragma --mark 网络请求
-(void)getNewsData{
    NSString *newsDetailUrlStr = [NSString stringWithFormat:@"%@news?id=%ld", OSCAPI_V2_PREFIX, (long)_informationID];
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:newsDetailUrlStr
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"]integerValue] == 1) {
                _newsDetail = [OSCInformationDetails osc_modelWithJSON:responseObject[@"result"]];
                _newsDetailRecommends= [[NSArray osc_modelArrayWithClass:[OSCBlogDetailRecommend class] json:_newsDetail.abouts] mutableCopy];
                
                NSDictionary *data = @{@"content":  _newsDetail.body?:@""};
                _newsDetail.body = [Utils HTMLWithData:data
                                          usingTemplate:@"blog"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateFavButtonWithIsCollected:_newsDetail.favorite];
                    [self updateRightButton:_newsDetail.commentCount];
                    self.headerView.newsModel = _newsDetail;
                });
            }else{
                _hud.hidden = YES;
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.label.text = @"这篇资讯找不到了(不存在/已删除)";
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

-(void)getCommentDetail{
    NSString *newsDetailUrlStr = [NSString stringWithFormat:@"%@comment", OSCAPI_V2_PREFIX];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:newsDetailUrlStr
     parameters:@{@"pageToken":@"",
                  @"sourceId":@(self.informationID),
                  @"type":@(6),
                  @"parts":@"refer,reply",
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"]integerValue] == 1) {
                _newsDetailComments = [OSCNewComment mj_objectArrayWithKeyValuesArray:responseObject[@"result"][@"items"]];
            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self updateRightButton:_newsDetailComments.count];
//            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

#pragma --mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0://与资讯有关的软件信息
        {
            NSInteger rows = 0;
            if (_newsDetail.software.allKeys.count > 0) {
                return rows = 1;
            } else if (_newsDetail.abouts.count > 0){
                return rows = _newsDetail.abouts.count;
            } else if (_newsDetailComments.count > 0) {
                if (_newsDetail.commentCount <= 10) {
                    return _newsDetailComments.count;
                } else {
                    return _newsDetailComments.count+1;
                }
            }else{
                return 0;
            }
            break;
        }
        case 1://相关资讯
        {
            if (_newsDetail.software.allKeys.count > 0 && _newsDetail.abouts.count > 0) {
                return _newsDetail.abouts.count;
            } else {
                if (_newsDetailComments.count > 0 && _newsDetail.commentCount <= 10) {
                    return _newsDetailComments.count;
                } else {
                    return _newsDetailComments.count+1;
                }
            }
            break;
        }
        case 2://评论
        {
            if (_newsDetailComments.count > 0 && _newsDetail.commentCount <= 10) {
                return _newsDetailComments.count;
            } else {
                return _newsDetailComments.count+1;
            }
            break;
        }
        default:
            return 0;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger secNumber = 0;
    if (_newsDetail.software.allKeys.count > 0) {
        secNumber ++;
    }
    if (_newsDetail.abouts.count > 0) {
        secNumber ++;
    }
//    if(_newsDetail.commentCount > 0){
//        secNumber ++;
//    }
    return secNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0: {
            if (_newsDetail.software.allKeys.count > 0) {
                RelatedSoftWareCell *softWareCell = [tableView dequeueReusableCellWithIdentifier:relatedSoftWareReuseIdentifier forIndexPath:indexPath];
                softWareCell.titleLabel.text = _newsDetail.software?[_newsDetail.software objectForKey:@"name"]:@"";
                softWareCell.selectionStyle = UITableViewCellSelectionStyleDefault;
                return softWareCell;
            } else if (_newsDetailRecommends.count > 0){
                RecommandBlogTableViewCell *recommandNewsCell = [tableView dequeueReusableCellWithIdentifier:recommandBlogReuseIdentifier forIndexPath:indexPath];
                if (_newsDetailRecommends.count > 0) {
                    OSCBlogDetailRecommend *about = _newsDetailRecommends[indexPath.row];
                    recommandNewsCell.abouts = about;
                    recommandNewsCell.hiddenLine = _newsDetailRecommends.count - 1 == indexPath.row ? YES : NO;
                }
                recommandNewsCell.selectionStyle = UITableViewCellSelectionStyleDefault;
                return recommandNewsCell;
            } else if (_newsDetailComments.count > 0) {
                if (_newsDetailComments.count > 0) {
                    if (_newsDetail.commentCount > 10 && indexPath.row == _newsDetailComments.count) {
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
                        
//                        if (!commentNewsCell.contentTextView.delegate) {
//                            commentNewsCell.contentTextView.delegate = self;
//                        }
                        OSCCommentItem *detailComment = _newsDetailComments[indexPath.row];
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
        }
            break;
        case 1: {
            if (_newsDetail.software.allKeys.count > 0 && _newsDetail.abouts.count > 0) {
                RecommandBlogTableViewCell *recommandNewsCell = [tableView dequeueReusableCellWithIdentifier:recommandBlogReuseIdentifier forIndexPath:indexPath];
                if (indexPath.row < _newsDetailRecommends.count) {
                    OSCBlogDetailRecommend *about = _newsDetailRecommends[indexPath.row];
                    recommandNewsCell.abouts = about;
                    recommandNewsCell.hiddenLine = _newsDetailRecommends.count - 1 == indexPath.row ? YES : NO;
                    
                }
                recommandNewsCell.selectionStyle = UITableViewCellSelectionStyleDefault;
                return recommandNewsCell;
            } else {
                if (_newsDetailComments.count > 0) {
                    if (_newsDetail.commentCount > 10 && indexPath.row == _newsDetailComments.count) {
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
                        
//                        if (!commentNewsCell.contentTextView.delegate) {
//                            commentNewsCell.contentTextView.delegate = self;
//                        }
                        OSCCommentItem *detailComment = _newsDetailComments[indexPath.row];
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
            
        }
            break;
        case 2: {
            if (_newsDetailComments.count > 0) {
                if (_newsDetail.commentCount > 10 && indexPath.row == _newsDetailComments.count) {
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
                    
//                    if (!commentNewsCell.contentTextView.delegate) {
//                        commentNewsCell.contentTextView.delegate = self;
//                    }
                    
                    OSCCommentItem *detailComment = _newsDetailComments[indexPath.row];
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
            break;
        default:
            break;
    }

    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (_newsDetail.software.allKeys.count > 0) {      //相关的软件详情
            SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:[_newsDetail.software[@"id"] integerValue]];
            [detailsViewController setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:detailsViewController animated:YES];
        } else if (_newsDetail.abouts.count > 0) {     //相关推荐的资讯详情
            OSCBlogDetailRecommend *detailRecommend = _newsDetailRecommends[indexPath.row];
            [self pushDetailsVcWithDetailModel:detailRecommend];
            
        } else if (_newsDetailComments.count > 0) {
            //资讯评论列表
            if (_newsDetailComments.count > 0 && indexPath.row == _newsDetailComments.count) {
                CommentsBottomBarViewController *commentsBVC = [[CommentsBottomBarViewController alloc] initWithCommentType:1 andObjectID:_newsDetail.id];
                [self.navigationController pushViewController:commentsBVC animated:YES];
            }
        }
    } else if (indexPath.section == 1) {
        if (_newsDetail.software.allKeys.count > 0 && _newsDetail.abouts.count > 0) {
            OSCBlogDetailRecommend *detailRecommend = _newsDetailRecommends[indexPath.row];
            [self pushDetailsVcWithDetailModel:detailRecommend];
        } else {
            //资讯评论列表
            if (_newsDetailComments.count > 0 && indexPath.row == _newsDetailComments.count) {
                
                //新评论列表
                NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:CommentIdTypeForNews sourceID:self.informationID];
                
                [self.navigationController pushViewController:newCommentVC animated:YES];
                
            }
        }
    } else if (indexPath.section == 2) {
        if (_newsDetailComments.count > 0 && indexPath.row == _newsDetailComments.count) {
            //新评论列表
            NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:CommentIdTypeForNews sourceID:self.informationID];
            [self.navigationController pushViewController:newCommentVC animated:YES];
        }
    }
}

#pragma --mark tableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (_newsDetail.software.allKeys.count > 0) {
            return [self headerViewWithSectionTitle:@"相关软件"];
        } else if (_newsDetail.abouts.count > 0){
            return [self headerViewWithSectionTitle:@"相关资讯"];
        } else if (_newsDetailComments.count > 0) {
            return [self headerViewWithSectionTitle:[NSString stringWithFormat:@"评论(%lu)", (unsigned long)_newsDetail.commentCount]];
        }
    } else if (section == 1) {
        if (_newsDetail.software.allKeys.count > 0 && _newsDetail.abouts.count > 0) {
            return [self headerViewWithSectionTitle:@"相关资讯"];
        } else {
            if (_newsDetailComments.count > 0) {
                return [self headerViewWithSectionTitle:[NSString stringWithFormat:@"评论(%lu)", (unsigned long)_newsDetail.commentCount]];
            }
            return [self headerViewWithSectionTitle:@"评论"];
        }
        
    } else if (section == 2) {
        if (_newsDetailComments.count > 0) {
            return [self headerViewWithSectionTitle:[NSString stringWithFormat:@"评论(%lu)", (unsigned long)_newsDetail.commentCount]];
        }
        return [self headerViewWithSectionTitle:@"评论"];
    }
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            if (_newsDetail.software.allKeys.count > 0) {
                return 45;
            } else if (_newsDetail.abouts.count > 0){
                return indexPath.row == _newsDetail.abouts.count-1 ? 72 : 60;
            } else if (_newsDetailComments.count > 0) {
                if (_newsDetailComments.count > 0) {
                    if (indexPath.row == _newsDetailComments.count) {
                        return 44;
                    } else {
                        return UITableViewAutomaticDimension;
                    }
                }
            }
            
            break;
        }
        case 1:
        {
            if (_newsDetail.software.allKeys.count > 0 && _newsDetail.abouts.count > 0) {
                return indexPath.row == _newsDetail.abouts.count-1 ? 72 : 60;
            } else {
                if (_newsDetailComments.count > 0) {
                    if (indexPath.row == _newsDetailComments.count) {
                        return 44;
                    } else {
                        return UITableViewAutomaticDimension;
                    }
                }
            }
            
            break;
        }
        case 2: {
            if (_newsDetailComments.count > 0) {
                if (indexPath.row == _newsDetailComments.count) {
                    return 44;
                } else {
                    return UITableViewAutomaticDimension;
                }
            }
        }
        default:
            break;
    }
    return 0;
}

#pragma --mark OSCInformationHeaderViewDelegate
- (BOOL)contentView:(IMYWebView *)webView
        shouldStart:(NSURLRequest *)request{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL name:nil];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}

-(void)contentViewDidFinishLoadWithHederViewHeight:(float)height{
    _hud.hidden = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.headerView.frame = CGRectMake(0, 0, kScreenSize.width - 16 * 2, height);
        self.tableView.tableHeaderView = self.headerView;
        [self.tableView reloadData];
    });
}

#pragma --mark 方法实现
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

#pragma mark --- update RightButton
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
//    NSIndexPath* lastSectionIndexPath = [NSIndexPath indexPathForRow:0 inSection:(self.tableView.numberOfSections - 1)];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:lastSectionIndexPath];
//    if (!cell) {
//        [self.tableView scrollToRowAtIndexPath:lastSectionIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }else{
//        [self.tableView setContentOffset:CGPointZero animated:YES];
//    }
    
    if (_newsDetail.commentCount > 0) {
        NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:CommentIdTypeForNews sourceID:self.informationID];
        [self.navigationController pushViewController:newCommentVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"暂无评论";
        [HUD hideAnimated:YES afterDelay:2];
    }
}

#pragma mark - 回复某条评论
- (void)selectedToComment:(UIButton *)button
{
    OSCCommentItem *comment = _newsDetailComments[button.tag];
    
    if (_selectIndexPath == button.tag) {
        _isReply = !_isReply;
    } else {
        _isReply = YES;
    }
    _selectIndexPath = button.tag;
    
    if (_isReply) {
        if (comment.author.id > 0) {
            _commentTextView.placeholder = [NSString stringWithFormat:@"@%@ ", comment.author.name];
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
- (void)favClick{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        
        NSDictionary *parameterDic =@{@"id"     : @(_informationID),
                                      @"type"   : @(6)};
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

#pragma --mark 分享
- (void)share{
    
    NSString *body = _newsDetail.body;
    NSString *href = _newsDetail.href;
    NSString *title = _newsDetail.title;
    
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
                                         appKey:@"54c9a412fd98c5779c000752"
                                      shareText:[NSString stringWithFormat:@"%@...分享来自 %@", digest, href]
                                     shareImage:[UIImage imageNamed:@"logo"]
                                shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                       delegate:nil];
}

#pragma mark - 发评论
- (void)sendCommentWithString:(NSString *)commmentStr
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    } else {
        JDStatusBarView *staute = [JDStatusBarNotification showWithStatus:@"评论发送中.."];
        //新 发评论
        NSInteger sourceId = _newsDetail.id;
        NSInteger type = 6;
        NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithDictionary:
                                        @{
                                          @"sourceId":@(sourceId),
                                          @"type":@(type),
                                          @"content":commmentStr,
                                          @"reAuthorId": @(_beRepliedCommentAuthorId),
                                          @"replyId": @(_beRepliedCommentId)
                                          }
                                        ];
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX,OSCAPI_COMMENT_PUB]
          parameters:paraDic
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 if ([responseObject[@"code"]integerValue] == 1) {
                     staute.textLabel.text = @"评论成功";
                     [JDStatusBarNotification dismissAfter:2];
                     
                     OSCNewComment *postedComment = [OSCNewComment mj_objectWithKeyValues:responseObject[@"result"]];
                    [_newsDetailComments insertObject:postedComment atIndex:0];
                     _newsDetail.commentCount ++ ;
                     _commentTextView.text = @"";
                     _commentTextView.placeholder = @"发表评论";
                 }else {
                     staute.textLabel.text = [NSString stringWithFormat:@"错误：%@", responseObject[@"message"]];
                     [JDStatusBarNotification dismissAfter:2];
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self updateRightButton:(_newsDetail.commentCount)];
                 });
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 staute.textLabel.text = @"网络异常，评论发送失败";
                 [JDStatusBarNotification dismissAfter:2];
                 [_commentTextView handleAttributeWithString:commmentStr];
             }];
    }
    
}

- (void)keyboardDidShow:(NSNotification *)nsNotification {
    
    //获取键盘的高度
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    [UIView animateWithDuration:1 animations:^{
        self.inputView.frame = CGRectMake(0, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - keyboardRect.size.height, kScreenSize.width, CGRectGetHeight(self.inputView.frame));
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];

}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    [self hideEditView];
}

//-(void)pushDetailsVcWithDetailModel:(OSCBlogDetailRecommend*)detailModel {
//    NSInteger pushType = detailModel.type;
//    if (pushType == 0) {
//        pushType = 6;
//    }
//    switch (pushType) {
//        case 1:{        //软件详情
//            SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:detailModel.id];
//            [detailsViewController setHidesBottomBarWhenPushed:YES];
//            [self.navigationController pushViewController:detailsViewController animated:YES];
//        }
//            break;
//        case 2:{
//            //问答
//            QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
//            detailVC.hidesBottomBarWhenPushed = YES;
//            detailVC.questionID = detailModel.id;
//            [self.navigationController pushViewController:detailVC animated:YES];
//        }
//            break;
//        case 3:{        //博客详情
//            
//            NewsBlogDetailTableViewController *newsBlogDetailVc = [[NewsBlogDetailTableViewController alloc]initWithObjectId:detailModel.id
//                                                                                                                isBlogDetail:YES];
//            [self.navigationController pushViewController:newsBlogDetailVc animated:YES];
//        }
//            break;
//        case 4:{
//            //翻译
//            TranslationViewController *translationVc = [TranslationViewController new];
//            translationVc.hidesBottomBarWhenPushed = YES;
//            translationVc.translationId = detailModel.id;
//            [self.navigationController pushViewController:translationVc animated:YES];
//        }
//            break;
//        case 5:{
//            //新活动详情页面
//            ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:detailModel.id];
//            activityDetailCtl.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:activityDetailCtl animated:YES];
//        }
//            break;
//        case 6:{        //资讯详情
//            OSCInformationDetailController *newsBlogDetailVc = [[OSCInformationDetailController alloc] initWithInformationID:detailModel.id];
//            [self.navigationController pushViewController:newsBlogDetailVc animated:YES];
//        }
//            break;
//            
//        default:
//            break;
//    }
//}
-(void)pushDetailsVcWithDetailModel:(OSCBlogDetailRecommend*)detailModel {
    NSInteger pushType = detailModel.type;
    if (pushType == 0) {
        pushType = 6;
    }
    UIViewController *targetVc =[OSCPushTypeControllerHelper pushControllerGeneralWithType:pushType detailContentID:detailModel.id];
    [self.navigationController pushViewController:targetVc animated:YES];
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

#pragma lazyLoad
- (OSCInformationHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[OSCInformationHeaderView alloc] init];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (OSCPopInputView *)inputView{
    if(!_inputView){
        _inputView = [OSCPopInputView popInputViewWithFrame:CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) maxStringLenght:160 delegate:self autoSaveDraftNote:YES];
        _inputView.popInputViewType = OSCPopInputViewType_At;
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld",(long)(long)_informationID];
    }
    return _inputView;
}

@end
