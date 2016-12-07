//
//  TweetDetailNewTableViewController.m
//  iosapp
//
//  Created by Holden on 16/6/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetDetailNewTableViewController.h"
#import "UIColor+Util.h"
#import "ImageViewerController.h"
#import "Config.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "OSCUserItem.h"
#import "OSCCommentItem.h"
#import "OSCTweet.h"
#import "OSCTweetItem.h"
#import "OSCPhotoGroupView.h"
#import "OSCUserHomePageController.h"
#import "NSString+FontAwesome.h"
#import "UIImage+Util.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "UINavigationController+Router.h"
#import "ImageDownloadHandle.h"
#import "TweetDetailCell.h"
#import "TweetLikeNewCell.h"
#import "TweetCommentNewCell.h"
#import "NewMultipleDetailCell.h"
#import "UMSocial.h"

#import <AFNetworking.h>
#import <MJRefresh.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>
#import <SDImageCache.h>
#import <SDWebImageDownloader.h>
#import <UIImage+GIF.h>
#import <YYKit.h>
#import "OSCModelHandler.h"


@import SafariServices ;

static NSString * const tDetailReuseIdentifier = @"TweetDetailCell";
static NSString * const tLikeReuseIdentifier = @"TweetLikeTableViewCell";
static NSString * const tCommentReuseIdentifier = @"TweetCommentTableViewCell";
static NSString * const tMultipleDetailReuseIdentifier = @"NewMultipleDetailCell";

@interface TweetDetailNewTableViewController ()<NewMultipleDetailCellDelegate,UITextViewDelegate>
@property (nonatomic, strong)UIView *headerView;
@property (nonatomic)BOOL isShowCommentList;
@property (nonatomic, strong)NSMutableArray *tweetLikeList;
@property (nonatomic, strong)NSMutableArray *tweetCommentList;
@property (nonatomic)NSInteger likeListPage;
@property (nonatomic)NSInteger commentListPage;
@property (nonatomic, copy)NSString *TweetLikesPageToken;
@property (nonatomic, copy)NSString *TweetCommentsPageToken;

@property (nonatomic, weak) UILabel *label;
@property (nonatomic, strong) OSCTweetItem *tweetDetail;
@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, weak) UITableViewCell *lastSelectedCell;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation TweetDetailNewTableViewController

- (void)showHubView {
    UIView *coverView = [[UIView alloc]initWithFrame:self.view.bounds];
    coverView.backgroundColor = [UIColor whiteColor];
    coverView.tag = 10;
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    _hud = [[MBProgressHUD alloc] initWithView:window];
    _hud.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    [window addSubview:_hud];
    [self.tableView addSubview:coverView];
    [_hud showAnimated:YES];
    _hud.removeFromSuperViewOnHide = YES;
    _hud.userInteractionEnabled = NO;
}

- (void)hideHubView {
    [_hud hideAnimated:YES];
    [[self.tableView viewWithTag:10] removeFromSuperview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideHubView];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetLikeNewCell" bundle:nil] forCellReuseIdentifier:tLikeReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCommentNewCell" bundle:nil] forCellReuseIdentifier:tCommentReuseIdentifier];
    [self.tableView registerClass:[TweetDetailCell class] forCellReuseIdentifier:tDetailReuseIdentifier];
    [self.tableView registerClass:[NewMultipleDetailCell class] forCellReuseIdentifier:tMultipleDetailReuseIdentifier];
    self.tableView.estimatedRowHeight = 250;
    self.tableView.tableFooterView = [UIView new];
	
    _tweetLikeList = [NSMutableArray new];
    _tweetCommentList = [NSMutableArray new];
    UILabel* weakLabel  = [[UILabel alloc]init];
    _label = weakLabel;
    _label.numberOfLines = 0;
    _isShowCommentList = YES;       //默认展示评论列表
	
    //上拉刷新
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadTweetLikesIsRefresh:NO];
        [self loadTweetCommentsIsRefresh:NO];
    }];
    
    // 添加等待动画
    [self showHubView];
    
    [self loadTweetDetails];
    [self loadTweetLikesIsRefresh:YES];
    [self loadTweetCommentsIsRefresh:YES];
	
	self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_share_black_pressed"]
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(shareForActivity:)];
	
	self.navigationItem.title = @"hello";
}

#pragma mark - layoutUI
- (void)layoutUI{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - right BarButton
- (void)shareForActivity:(UIBarButtonItem *)barButton
{
	NSLog(@"share");
	
	NSString *trimmedHTML = [_tweetDetail.content deleteHTMLTag];
	NSInteger length = trimmedHTML.length < 60 ? trimmedHTML.length : 60;
	NSString *digest = [trimmedHTML substringToIndex:length];
	
	// 微信相关设置
	[UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
	[UMSocialData defaultData].extConfig.wechatSessionData.url = _tweetDetail.href;
	[UMSocialData defaultData].extConfig.wechatTimelineData.url = _tweetDetail.href;
    [UMSocialData defaultData].extConfig.title = trimmedHTML.length > 10 ? [NSString stringWithFormat:@"%@... - 开源中国",[trimmedHTML substringWithRange:NSMakeRange(0, 9)]] : [NSString stringWithFormat:@"%@ - 开源中国",trimmedHTML];
	
	// 手机QQ相关设置
	[UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
	[UMSocialData defaultData].extConfig.qqData.title = _tweetDetail.author.name;
	[UMSocialData defaultData].extConfig.qqData.url = _tweetDetail.href;
	
	// 新浪微博相关设置
	[[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:_tweetDetail.href];
	
	[UMSocialSnsService presentSnsIconSheetView:self
										 appKey:@"54c9a412fd98c5779c000752"
									  shareText:[NSString stringWithFormat:@"%@...分享来自 %@", digest, _tweetDetail.href]
									 shareImage:[UIImage imageNamed:@"logo"]
								shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
									   delegate:nil];
}

#pragma mark -- headerView
- (UIView*) headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:(CGRect){{0,0},{self.view.bounds.size.width,40}}];
        _headerView.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
        
        for (int k=0; k<2; k++) {
            UIButton* subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            subBtn.tag = k+1;
            NSString* likeBtnTitle = subBtn.tag==1?@"赞":@"评论";
            BOOL isSelected = subBtn.tag==2;
            NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:likeBtnTitle isSelected:isSelected];
            [subBtn setAttributedTitle:att forState:UIControlStateNormal];
            
            [subBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            CGFloat btnWidth = _headerView.bounds.size.width/2;
            subBtn.frame = (CGRect){{btnWidth*k,0},{btnWidth,40}};
            [_headerView addSubview:subBtn];
        }

    }else {
        if (_tweetDetail.likeCount > 0) {
            UIButton *likeBtn = [(UIButton*)_headerView viewWithTag:1];
            NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:[NSString stringWithFormat:@"赞 (%ld)", (long)_tweetDetail.likeCount] isSelected:!_isShowCommentList];
            [likeBtn setAttributedTitle:att forState:UIControlStateNormal];
        }
        if (_tweetDetail.commentCount > 0) {
            UIButton *commentBtn = [(UIButton*)_headerView viewWithTag:2];
            NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:[NSString stringWithFormat:@"评论 (%ld)", (long)_tweetDetail.commentCount] isSelected:_isShowCommentList];
            [commentBtn setAttributedTitle:att forState:UIControlStateNormal];
        }

    }
    
    return _headerView;
}

-(NSMutableAttributedString*)getSubBtnAttributedStringWithTitle:(NSString*)title isSelected:(BOOL)isSelected {
    NSMutableAttributedString* attributedStrNormal = [[NSMutableAttributedString alloc]initWithString:title];
    UIFont *font = [UIFont systemFontOfSize:15];
    UIColor *currentColor = isSelected?[UIColor colorWithHex:0x24cf5f]:[UIColor colorWithHex:0x6a6a6a];
    [attributedStrNormal setAttributes:@{NSForegroundColorAttributeName:currentColor,NSFontAttributeName:font} range:(NSRange){0,title.length}];
    return attributedStrNormal;
}

-(void)clickBtn:(UIButton*)btn {
    if (btn.tag == 1) { //赞
        _isShowCommentList = NO;
        NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:@"赞" isSelected:YES];
        [btn setAttributedTitle:att forState:UIControlStateNormal];
        
        NSMutableAttributedString *attr = [self getSubBtnAttributedStringWithTitle:@"评论" isSelected:NO];
        [((UIButton*)[_headerView viewWithTag:2]) setAttributedTitle:attr forState:UIControlStateNormal];
    }else if (btn.tag == 2) {     //评论
        _isShowCommentList = YES;
        NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:@"评论" isSelected:YES];
        [btn setAttributedTitle:att forState:UIControlStateNormal];
        
        NSMutableAttributedString *attr = [self getSubBtnAttributedStringWithTitle:@"赞" isSelected:NO];
        [((UIButton*)[_headerView viewWithTag:1]) setAttributedTitle:attr forState:UIControlStateNormal];
    }    
    [self.tableView reloadData];
}

#pragma mark - 获取动弹详情数据
- (void)loadTweetDetails {
    NSString *tweetDetailUrlStr = [NSString stringWithFormat:@"%@tweet?id=%ld", OSCAPI_V2_PREFIX, (long)self.tweetID];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:tweetDetailUrlStr
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"]integerValue] == 1) {
                _tweetDetail = [OSCTweetItem osc_modelWithJSON:responseObject[@"result"]];
                [_tweetDetail calculateLayout];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHubView];
                    [self.tableView reloadData];
                });
            }else{
                [self hideHubView];
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.label.text = @"这个动弹找不到了(不存在/已删除)";
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

#pragma mark - 获取点赞列表数据
-(void)loadTweetLikesIsRefresh:(BOOL)isRefresh {
    if (isRefresh) {
        _TweetLikesPageToken = @"";
    }
    NSDictionary *paraDic = @{@"sourceId":@(_tweetID),
                              @"pageToken":_TweetLikesPageToken
                              };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_TWEET_LIKES]
      parameters:paraDic
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if([responseObject[@"code"]integerValue] == 1) {
                 NSDictionary* resultDic = responseObject[@"result"];
                 NSArray* items = resultDic[@"items"];
                 if (isRefresh && items.count > 0) {//下拉得到的数据
                     [self.tweetLikeList removeAllObjects];
                 }
                 for(int k=0;k<items.count;k++) {
                     NSDictionary *userDic =[items objectAtIndex:k][@"author"];
                     OSCUserItem *user = [OSCUserItem osc_modelWithJSON:userDic];
                     if (user) {
                         [self.tweetLikeList addObject:user];
                     }
                 }
                 _TweetLikesPageToken = resultDic[@"nextPageToken"];
             }
             
             if (self.tableView.mj_footer.isRefreshing) {
                 [self.tableView.mj_footer endRefreshing];
             }
             if (!_isShowCommentList) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self networkingError:error];
         }
     ];
}


//发表评论后，为了更新总的评论数
-(void)reloadCommentList {
    _tweetDetail.commentCount++;
    [self loadTweetCommentsIsRefresh:YES];
}

#pragma mark - 获取评论列表数据
-(void)loadTweetCommentsIsRefresh:(BOOL)isRefresh {
    if (isRefresh) {
        _TweetCommentsPageToken = @"";
    }
    NSDictionary *paraDic = @{@"sourceId":@(_tweetID),
                              @"pageToken":_TweetCommentsPageToken
                              };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_TWEET_COMMENTS]
      parameters:paraDic
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             if([responseObject[@"code"]integerValue] == 1) {
                 NSDictionary* resultDic = responseObject[@"result"];
                 NSArray* items = resultDic[@"items"];
                 NSArray *modelArray = [NSArray osc_modelArrayWithClass:[OSCCommentItem class] json:items];
                 
                 if (isRefresh && modelArray.count > 0) {//下拉得到的数据
                     [self.tweetCommentList removeAllObjects];
                 }
                 [self.tweetCommentList addObjectsFromArray:modelArray];

                 _TweetCommentsPageToken = resultDic[@"nextPageToken"];
             }
             
             if (self.tableView.mj_footer.isRefreshing) {
                 [self.tableView.mj_footer endRefreshing];
             }
             if (_isShowCommentList) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self networkingError:error];
         }
     ];
}

-(void)networkingError:(NSError*)error {
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.detailsLabel.text = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
    [HUD hideAnimated:YES afterDelay:1];
    
    if (self.tableView.mj_footer.isRefreshing) {
        [self.tableView.mj_footer endRefreshing];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 1;
    }else if (section==1) {
        return _isShowCommentList?_tweetCommentList.count:_tweetLikeList.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0?0:40;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return self.headerView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (!_isShowCommentList) {
            return 56;
        }else{
            return UITableViewAutomaticDimension;
        }
    }else{
        return UITableViewAutomaticDimension;
    }
}

/**
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (_tweetDetail.images.count <= 1) {
            return [tableView fd_heightForCellWithIdentifier:tDetailReuseIdentifier configuration:^(TweetDetailCell* cell) {
                cell.tweet = _tweetDetail;
                [self setUpTweetDetailCell:cell];
            }];
        }else{
            return [tableView fd_heightForCellWithIdentifier:tMultipleDetailReuseIdentifier configuration:^(NewMultipleDetailCell* cell) {
                if (!_tweetDetail) {return ;}
                cell.item = _tweetDetail;
            }];
        }
    }else if (indexPath.section == 1) {
        if (!_isShowCommentList) {
            return 56;
        }else {
            return [tableView fd_heightForCellWithIdentifier:tCommentReuseIdentifier configuration:^(TweetCommentNewCell* cell) {
                if (indexPath.row < _tweetCommentList.count) {
                    OSCCommentItem *commentModel = _tweetCommentList[indexPath.row];
                    [cell setCommentModel:commentModel];
                    [self setBlockForCommentCell:cell];
                    cell.commentTagIv.tag = indexPath.row;
                    [cell.commentTagIv addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(replyReviewer:)]];
                    cell.portraitIv.tag = commentModel.author.id;
                    [cell.portraitIv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentItemPushUserDetails:)]];
                }
            }];
        }
    }
    return 0;
}
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (_tweetDetail.images.count <= 1) {
            TweetDetailCell *detailCell = [tableView dequeueReusableCellWithIdentifier:tDetailReuseIdentifier forIndexPath:indexPath];
            detailCell.tweet = _tweetDetail;
            [self setUpTweetDetailCell:detailCell];
            return detailCell;
        }else{
            NewMultipleDetailCell* detailCell = [tableView dequeueReusableCellWithIdentifier:tMultipleDetailReuseIdentifier forIndexPath:indexPath];
            if (_tweetDetail == nil) {return nil;}
            detailCell.item = _tweetDetail;
            detailCell.delegate = self;
            return detailCell;
        }
    }else if (indexPath.section == 1) {
        if (_isShowCommentList) {
            TweetCommentNewCell *commentCell = [self.tableView dequeueReusableCellWithIdentifier:tCommentReuseIdentifier forIndexPath:indexPath];
            if (indexPath.row < _tweetCommentList.count) {
                OSCCommentItem *commentModel = _tweetCommentList[indexPath.row];
                [commentCell setCommentModel:commentModel];
                
                [self setBlockForCommentCell:commentCell];
                
                commentCell.commentTagIv.tag = indexPath.row;
                [commentCell.commentTagIv addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(replyReviewer:)]];
                
                commentCell.portraitIv.tag = commentModel.author.id;
                [commentCell.portraitIv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentItemPushUserDetails:)]];
            }
            return commentCell;
        }else {
            TweetLikeNewCell *likeCell = [self.tableView dequeueReusableCellWithIdentifier:tLikeReuseIdentifier forIndexPath:indexPath];
            if (indexPath.row < _tweetLikeList.count) {
                OSCUserItem *likedUser = [_tweetLikeList objectAtIndex:indexPath.row];
                [likeCell.portraitIv loadPortrait:[NSURL URLWithString:likedUser.portrait]];
                likeCell.nameLabel.text = likedUser.name;
                likeCell.touchButton.tag = likedUser.id;
                
                [likeCell.touchButton addTarget:self action:@selector(likedUserDetails:) forControlEvents:UIControlEventTouchUpInside];
            }
            return likeCell;
        }
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        if (_isShowCommentList && _tweetCommentList.count > 0) {
            OSCCommentItem *comment = _tweetCommentList[indexPath.row];
            if (self.didTweetCommentSelected) {
                self.didTweetCommentSelected(comment);
            }
        }
    }
}

#pragma mark -- NewMultipleDetailCell Delegate
- (void) userPortraitDidClick:(NewMultipleDetailCell* )multipleTweetCell
                  tapGestures:(UITapGestureRecognizer* )tap
{
    if (_tweetDetail.author.id) {
        [self.navigationController pushViewController:[[OSCUserHomePageController alloc] initWithUserID:_tweetDetail.author.id] animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

- (void) commentButtonDidClick:(NewMultipleDetailCell *)multipleTweetCell
                   tapGestures:(UITapGestureRecognizer *)tap
{
    [self commentTweet];
}

- (void) likeButtonDidClick:(NewMultipleDetailCell *)multipleTweetCell
                tapGestures:(UITapGestureRecognizer *)tap
{
    [self likeOrCancelLikeTweetAndUpdateTagIv:(UIImageView* )tap.view];
}

-(void)assemblyMultipleTweetCellDidFinsh:(NewMultipleDetailCell *)multipleTweetCell
{
    [self.tableView reloadData];
}

- (void) loadLargeImageDidFinsh:(NewMultipleDetailCell* )multipleTweetCell
                 photoGroupView:(OSCPhotoGroupView* )groupView
                       fromView:(UIImageView* )fromView
{
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
//    [groupView presentFromImageView:fromView toContainer:currentWindow animated:YES completion:nil];
    /** 点开拿到大图之后 用大图更新update缩略图 提高清晰度 */
    [groupView presentFromImageView:fromView toContainer:currentWindow animated:YES completion:^{
        OSCTweetItem* tweetItem = [multipleTweetCell valueForKey:@"item"];
        OSCTweetImages* currentImageItem = tweetItem.images[groupView.currentPage];
        UIImage* image = [[YYWebImageManager sharedManager].cache getImageForKey:currentImageItem.href withType:YYImageCacheTypeMemory];
        if (image) { fromView.image = image; }
    }];

}

-(void)shouldInteractTextView:(UITextView *)textView
                          URL:(NSURL *)URL
                      inRange:(NSRange)characterRange
{
    [self.navigationController handleURL:URL name:nil];
}


#pragma mark -- Copy/Paste.  All three methods must be implemented by the delegate.

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    _lastSelectedCell.backgroundColor = [UIColor whiteColor];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor selectCellSColor];
    _lastSelectedCell = cell;
    return indexPath.section != 0;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return indexPath.section != 0;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender {

}

#pragma mark -- 设置动弹详情cell
-(void)setUpTweetDetailCell:(TweetDetailCell*)cell {
    if (_tweetDetail) {
        [cell.userPortrait loadPortrait:[NSURL URLWithString:_tweetDetail.author.portrait]];
        cell.userPortrait.tag = _tweetDetail.author.id;
        [cell.userPortrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushUserDetails:)]];
        
        [cell.nameLabel setText:_tweetDetail.author.name];
        if ([[Utils contentStringFromRawString:_tweetDetail.content] length] == 0) {
            cell.descTextView.text = @"[表情]";
        }else{
            cell.descTextView.attributedText = [Utils contentStringFromRawString:_tweetDetail.content];
        }
        
		cell.descTextView.delegate = self; //监听点击事件
        
        if (_tweetDetail.images.count == 1) {
            cell.tweetImageView.hidden = NO;
            OSCTweetImages* imageData = [_tweetDetail.images lastObject];
            
            UIImage* largerImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageData.href];
            
            if (!largerImage) {
                UIImage* thumbImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageData.thumb];
                if (!thumbImage) {
                    [ImageDownloadHandle downloadImageWithUrlString:imageData.thumb SaveToDisk:NO completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                        if ([imageData.thumb hasSuffix:@".gif"]) {
                            NSData *dataImage = UIImagePNGRepresentation(image);
                            image = [UIImage sd_animatedGIFWithData:dataImage];
                        }
                        [cell.tweetImageView setImage:image];
                    }];
                }else{
                    if ([imageData.thumb hasSuffix:@".gif"]) {
                        NSData *dataImage = UIImagePNGRepresentation(thumbImage);
                        thumbImage = [UIImage sd_animatedGIFWithData:dataImage];
                    }
                    [cell.tweetImageView setImage:thumbImage];
                }
            }else{
                if ([imageData.thumb hasSuffix:@".gif"]) {
                    NSData *dataImage = UIImagePNGRepresentation(largerImage);
                    largerImage = [UIImage sd_animatedGIFWithData:dataImage];
                }
                [cell.tweetImageView setImage:largerImage];
            }
//            UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imageData.thumb];
//            if (!image) {
//                [cell.tweetImageView setImage:[UIImage imageNamed:@"loading"]];
//                [self downloadThumbnailImageThenReload:imageData.thumb];
//            } else {
//                if ([imageData.thumb hasSuffix:@".gif"]) {
//                    NSData *dataImage = UIImagePNGRepresentation(image);
//                    image = [UIImage sd_animatedGIFWithData:dataImage];
//                }
//                [cell.tweetImageView setImage:image];
//            }
        }else{
            cell.tweetImageView.hidden = YES;
        }
        
        [cell.tweetImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadTweetImage:)]];
        [cell.likeCountIv addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(likeThisTweet:)]];
        [cell.commentImage addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentTweet)]];
        
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:_tweetDetail.pubDate] timeAgoSinceNow]]];
        [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        [att appendAttributedString:[Utils getAppclientName:(int)_tweetDetail.appClient]];
        cell.timeLabel.attributedText = att;
        
        NSString *likeImgNameStr = _tweetDetail.liked ? @"ic_thumbup_actived" : @"ic_thumbup_normal";
        [cell.likeCountIv setImage:[UIImage imageNamed:likeImgNameStr]];
    }
}

#pragma mark  给UITextView添加监听
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    NSString* nameStr = [textView.text substringWithRange:characterRange];
    if ([[nameStr substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"@"]) {
        nameStr = [nameStr substringFromIndex:1];
        [self.navigationController handleURL:URL name:nameStr];
    }else{
        [self.navigationController handleURL:URL name:nil];
    }
    return NO;
}

#pragma mark 加载大图
-(void)loadTweetImage:(UITapGestureRecognizer*)tap {
    UIImageView* fromView = (UIImageView* )tap.view;
//        current touch object
    OSCPhotoGroupItem* currentPhotoItem = [OSCPhotoGroupItem new];
    currentPhotoItem.thumbView = fromView;
    OSCTweetImages* imageData = [_tweetDetail.images lastObject];
    currentPhotoItem.largeImageURL = [NSURL URLWithString:imageData.href];
    
    NSArray* photoGroupItems = @[currentPhotoItem];
    
    OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:photoGroupItems];
//    [photoGroup presentFromImageView:fromView toContainer:self.navigationController.view animated:YES completion:nil];
    /** 点开拿到大图之后 用大图更新update缩略图 提高清晰度 */
    [photoGroup presentFromImageView:fromView toContainer:self.navigationController.view animated:YES completion:^{
        OSCTweetItem* tweetItem = [fromView.superview.superview valueForKey:@"tweet"];
        OSCTweetImages* currentImageItem = tweetItem.images[photoGroup.currentPage];
        UIImage* image = [[YYWebImageManager sharedManager].cache getImageForKey:currentImageItem.href withType:YYImageCacheTypeMemory];
        if (image) { fromView.image = image; }
    }];
}

#pragma  mark -- 用户详情界面
-(void)pushUserDetails:(UITapGestureRecognizer*)tap {
    if (tap.view.tag > 0) {
        [self.navigationController pushViewController:[[OSCUserHomePageController alloc] initWithUserID:tap.view.tag] animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

-(void)commentItemPushUserDetails:(UITapGestureRecognizer*)tap {
    NSInteger userId = tap.view.tag;
    if (userId > 0) {
        [self.navigationController pushViewController:[[OSCUserHomePageController alloc] initWithUserID:userId] animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

- (void)likedUserDetails:(UIButton*)btn {
    if (btn.tag > 0) {
        [self.navigationController pushViewController:[[OSCUserHomePageController alloc] initWithUserID:btn.tag] animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

-(void)likeThisTweet:(UITapGestureRecognizer*)tap {
    UIImageView *likeTagIv = (UIImageView*)tap.view;
    [self likeOrCancelLikeTweetAndUpdateTagIv:likeTagIv];
}

-(void)commentTweet {
    if (self.didActivatedInputBar) {
        self.didActivatedInputBar();
    }
}

-(void)replyReviewer:(UITapGestureRecognizer*)tap {
    OSCCommentItem *comment = _tweetCommentList[tap.view.tag];
    if (self.didTweetCommentSelected) {
        self.didTweetCommentSelected(comment);
    }
}

#pragma mark --点赞（新接口)
-(void)likeOrCancelLikeTweetAndUpdateTagIv:(UIImageView*)likeTagIv {
    if (_tweetDetail.id == 0) {
        return;
    }
    NSString *postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_TWEET_LIKE_REVERSE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager POST:postUrl
       parameters:@{@"sourceId":@(_tweetDetail.id)}
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
             if([responseObject[@"code"]integerValue] == 1) {
                 if (_tweetDetail.liked) {
                     //取消点赞
                     _tweetDetail.likeCount--;
                     [likeTagIv setImage:[UIImage imageNamed:@"ic_thumbup_normal"]];
                     for (OSCUserItem *likeUser in _tweetLikeList) {
                         OSCUserItem *currentUser = [OSCUserItem modelWithJSON:responseObject[@"result"][@"author"]];
                         if (currentUser.id == likeUser.id) {
                             [_tweetLikeList removeObject:likeUser];
                             break;
                         }
                     }
                     _tweetDetail.liked = NO;
                 } else {
                     //点赞
                     _tweetDetail.likeCount++;
                     [likeTagIv setImage:[UIImage imageNamed:@"ic_thumbup_actived"]];
                     OSCUserItem *currentUser = [OSCUserItem modelWithJSON:responseObject[@"result"][@"author"]];
                     [_tweetLikeList insertObject:currentUser atIndex:0];
                     _tweetDetail.liked = YES;
                 }
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                 });
             }else {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = [NSString stringWithFormat:@"%@", responseObject[@"message"]?:@"未知错误"];
                 
                 [HUD hideAnimated:YES afterDelay:1];
             }
             
             if (self.tableView.mj_footer.isRefreshing) {
                 [self.tableView.mj_footer endRefreshing];
             }
             if (!_isShowCommentList) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self networkingError:error];
         }
     ];
}

#pragma mark -- 删除动弹评论
- (void)setBlockForCommentCell:(TweetCommentNewCell *)cell {
    __weak typeof(self) weakSelf = self;
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteObject:)) {
            NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
            OSCCommentItem *comment = weakSelf.tweetCommentList[indexPath.row];
            int64_t ownID = [Config getOwnID];
            return (comment.author.id == ownID || weakSelf.tweetDetail.id == ownID);
        }
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
        OSCCommentItem *comment = weakSelf.tweetCommentList[indexPath.row];
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.label.text = @"正在删除评论";
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        [manager POST:[NSString stringWithFormat:@"%@%@?", OSCAPI_PREFIX, OSCAPI_COMMENT_DELETE]
           parameters:@{
                        @"catalog": @(3),
                        @"id": @(_tweetDetail.id),
                        @"replyid": @(comment.id),
                        @"authorid": @(comment.author.id)
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  ONOXMLElement *resultXML = [responseObject.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[resultXML firstChildWithTag: @"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[resultXML firstChildWithTag:@"errorMessage"] stringValue];
                  
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  if (errorCode == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.label.text = @"评论删除成功";
                      
                      [self.tweetCommentList removeObjectAtIndex:indexPath.row];
                      if (self.tweetCommentList.count > 0) {
                          [self.tableView beginUpdates];
                          [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                          [self.tableView endUpdates];
                      }
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.tableView reloadData];
                      });
                  } else {
                      HUD.label.text = [NSString stringWithFormat:@"%@", errorMessage];
                  }
                  
                  [HUD hideAnimated:YES afterDelay:1];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.label.text = @"网络异常，操作失败";
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    };
}
#pragma mark - 下载图片

- (void)downloadThumbnailImageThenReload:(NSString*)urlString
{
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:urlString]
                                                        options:SDWebImageDownloaderUseNSURLCache
                                                       progress:nil
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                          [[SDImageCache sharedImageCache] storeImage:image forKey:urlString toDisk:NO];

                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self.tableView reloadData];
                                                          });
                                                      }];
    
}

#pragma mark - scrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView && self.didScroll) {
        self.didScroll();
    }
}

@end
