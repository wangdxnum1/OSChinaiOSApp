//
//  OSCUserHomePageController.m
//  iosapp
//
//  Created by Graphic-one on 16/9/1.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCUserHomePageController.h"
#import "UserDrawHeaderView.h"
#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"
#import "OSCUserItem.h"
#import "OSCTweetItem.h"
#import "OSCNewHotBlog.h"
#import "OSCQuestion.h"
#import "OSCDiscuss.h"
#import "OSCPhotoGroupView.h"
#import "OSCPushTypeControllerHelper.h"
#import "BubbleChatViewController.h"
#import "OSCInformationDetailController.h"
#import "NewBlogDetailController.h"

#import "AsyncDisplayTableViewCell.h"
#import "OSCTextTweetCell.h"
#import "OSCImageTweetCell.h"
#import "OSCMultipleTweetCell.h"
#import "NewHotBlogTableViewCell.h"
#import "QuesAnsTableViewCell.h"
#import "OSCDiscussCell.h"

#import "NewLoginViewController.h"
#import "FriendsViewController.h"
#import "QuesAnsDetailViewController.h"
#import "TweetDetailsWithBottomBarViewController.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "UINavigationBar+BackgroundColor.h"

#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <YYKit.h>
#import "OSCModelHandler.h"

#define NAVI_BAR_HEIGHT 64
#define HEADER_VIEW_HEIGHT 330
#define SECTION_HEADER_VIEW_HEIGHT 64

/** key */
static NSString* const requestUrl = @"requestUrlString";
static NSString* const requestParameter = @"requestParameterString";
/** reuseIdentifier */
static NSString* const reuseTextTweetCellReuseIdentifier = @"OSCTextTweetCell";
static NSString* const reuseImageTweetCellReuseIdentifier = @"OSCImageTweetCell";
static NSString* const reuseMultipleTweetCellReuseIdentifier = @"OSCMultipleTweetCell";
static NSString* const reuseNewHotBlogTableViewCellReuseIdentifier = @"NewHotBlogTableViewCell";
static NSString* const reuseQuesAnsTableViewCellReuseIdentifier = @"QuesAnsTableViewCell";
static NSString* const reuseDiscussCellReuseIdentifier = @"OSCDiscussCell";


@interface OSCUserHomePageController ()<UITableViewDelegate,UITableViewDataSource,AsyncDisplayTableViewCellDelegate>
{
    NSUInteger _currentIndex;
}
@property (nonatomic,strong) NSMutableArray<UIButton* >* buttons;
@property (nonatomic,strong) NSMutableArray<NSString* >* nextTokens;
@property (nonatomic,strong) NSMutableArray<NSMutableArray* >* dataSources;

@property (nonatomic,strong) OSCUserHomePageItem* user;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) UserDrawHeaderView* headerCanvasView;
@property (nonatomic,strong) UIView* sectionHeaderView;
@property (nonatomic,strong) MBProgressHUD* HUD;

@end

@implementation OSCUserHomePageController{
//左右naviBarItem
    UIButton* _rightBarMessageBtn;
    UIButton* _rightBarFollowrBtn;
//请求参数
    NSInteger _userID;
    NSString* _userName;
    NSString* _hisName;
}

#pragma mark --- Initialization method
- (instancetype)initWithUserID:(NSInteger)userID{
    self = [super init];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        _userID = userID;
        _userName = nil;
        _hisName = nil;
    }
    return self;
}
- (instancetype)initWithUserName:(NSString *)userName{
    self = [super init];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        _userName = userName;
        _userID = NSNotFound;
        _hisName = nil;
    }
    return self;
}
- (instancetype)initWithUserHisName:(NSString *)hisName{
    self = [super init];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        _hisName = hisName;
        _userName = nil;
        _userID = NSNotFound;
    }
    return self;
}


#pragma mark --- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self settingSomthing];
    [self layoutUI];
    [self getCurrentUserInfo];//获取用户info
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tableView.tableHeaderView = self.headerCanvasView;
    if (_user) { [self assemblyHeaderView]; }
    
    [self.navigationController.navigationBar lt_reset];
    [self.navigationController.navigationBar setBackgroundImage:[Utils createImageWithColor:[UIColor navigationbarColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor navigationbarColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollViewDidScroll:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[Utils createImageWithColor:[UIColor navigationbarColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar lt_setBackgroundColor:[[UIColor navigationbarColor] colorWithAlphaComponent:1]];
    [self.navigationController.navigationBar lt_reset];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.headerCanvasView = nil;
    self.tableView.tableHeaderView = nil;
    
    [self.navigationController.navigationBar lt_reset];
    [self.navigationController.navigationBar setBackgroundImage:[Utils createImageWithColor:[UIColor navigationbarColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor navigationbarColor]];
}

#pragma mark --- Setting default value
- (void)settingSomthing{
    self.navigationItem.title = @"用户中心";
    
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];

    self.navigationController.navigationBar.translucent = YES;
    
    self.buttons[1].selected = YES;
    _currentIndex = 1;

    [self.tableView registerNib:[UINib nibWithNibName:@"NewHotBlogTableViewCell" bundle:nil] forCellReuseIdentifier:reuseNewHotBlogTableViewCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"QuesAnsTableViewCell" bundle:nil] forCellReuseIdentifier:reuseQuesAnsTableViewCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"OSCDiscussCell" bundle:nil] forCellReuseIdentifier:reuseDiscussCellReuseIdentifier];
}

#pragma mark --- layout
- (void)layoutUI{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:({
        UIView* bgView = [[UIView alloc]initWithFrame:(CGRect){{0,-NAVI_BAR_HEIGHT},{self.view.bounds.size.width,HEADER_VIEW_HEIGHT}}];
        bgView.backgroundColor = [UIColor navigationbarColor];
        bgView;
    })];
    [self.view addSubview:self.tableView];

    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getDataThroughDropdown:NO];
    }];
}


#pragma mark --- networking 
- (void)getCurrentUserInfo{
    NSString* urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_GET_USER_INFO];;
    
    NSMutableDictionary* mutableDic = [NSMutableDictionary dictionaryWithCapacity:1];
    if (_userID != NSNotFound) {
        [mutableDic setObject:@(_userID) forKey:@"id"];
    }else if (_userName != nil){
        [mutableDic setObject:_userName forKey:@"nickname"];
    }else if (_hisName != nil){
        [mutableDic setObject:_hisName forKey:@"suffix"];
    }else{
        mutableDic = nil;
    }
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    _HUD = [Utils createHUD];
    
    [manger GET:urlStr
     parameters:[mutableDic copy]
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary* userResult = responseObject[@"result"];
                _user = [OSCUserHomePageItem osc_modelWithJSON:userResult];
                
                if (!_user) { [self.navigationController popViewControllerAnimated:YES];}
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self assemblyHeaderView];
                    if (_user.id != [Config getOwnID]) {
                        [self settingNaviBarItem];
                    }
                    [self updateRelationshipImage];
                    [_HUD hideAnimated:YES afterDelay:0.3];
                    [self getDataThroughDropdown:YES];//获取默认的数据源
                });
            }else{
                _HUD.label.text = @"未知错误";
                [_HUD hideAnimated:YES afterDelay:0.3];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
    }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _HUD.label.text = @"网络异常，操作失败";
                [_HUD hideAnimated:YES afterDelay:0.3];
                [self.navigationController popViewControllerAnimated:YES];
            });
    }];
}
- (void)getDataThroughDropdown:(BOOL)dropDown{//YES:下拉  NO:上拉
    NSMutableDictionary* parameterDic = @{}.mutableCopy;
    
    NSDictionary* materialDic = [self getRequestMaterial:_currentIndex];
    NSString* urlStr = materialDic[requestUrl];
    NSString* parameterStr = materialDic[requestParameter];

    [parameterDic setValue:@(_user.id) forKey:parameterStr];
    if (!dropDown && self.nextTokens[_currentIndex].length > 0) {
        [parameterDic setValue:self.nextTokens[_currentIndex] forKey:@"pageToken"];
    }
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    if (dropDown) {
        _HUD = [Utils createHUD];
    }

    [manger GET:urlStr
     parameters:[parameterDic copy]
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary* resultDic = responseObject[@"result"];
                self.nextTokens[_currentIndex] = resultDic[@"nextPageToken"];
                NSMutableArray* currentArr = self.dataSources[_currentIndex];
                
                NSArray* models = [self handleOriginal_JSON:resultDic currentIndex:_currentIndex];
                if (dropDown) {
                    [currentArr removeAllObjects];
                }
                [currentArr addObjectsFromArray:models];
                
            }else{
                _HUD.label.text = @"未知错误";
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                if (!dropDown) {
                    [self.tableView.mj_footer endRefreshing];
                }
                [_HUD hideAnimated:YES afterDelay:0.3];
            });
    }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!dropDown) {
                    [self.tableView.mj_footer endRefreshing];
                }
                _HUD.label.text = @"网络异常，操作失败";
                [_HUD hideAnimated:YES afterDelay:0.3];
            });
    }];
}


#pragma mark --- UITableViewDelegate & UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return SECTION_HEADER_VIEW_HEIGHT;
}
- (UIView* )tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.sectionHeaderView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray* dataSource = self.dataSources[_currentIndex];
    return dataSource.count;
}
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray* dataSource = [self.dataSources[_currentIndex] copy];
    return [self getCurrentDisplayCell:_currentIndex tableView:tableView indexPath:indexPath dataSource:dataSource[indexPath.row]];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushControllerHelper:_currentIndex indexPath:indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray* dataSource = [self.dataSources[_currentIndex] copy];
    return [self getCurrentDisplayCellRowHeight:_currentIndex dataSource:dataSource[indexPath.row]];
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_currentIndex == 2) {
        return 150;
    }else if (_currentIndex == 3){
        return 105;
    }else if(_currentIndex == 4){
        return 155;
    }else{
        return 0;
    }
}

#pragma mark -  scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.y < -HEADER_VIEW_HEIGHT) {
        [self.tableView setContentOffset:CGPointMake(0, -NAVI_BAR_HEIGHT) animated:NO];
    }
    
    UIColor * color = [UIColor navigationbarColor];
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > NAVI_BAR_HEIGHT) {
        self.navigationItem.title = _user.name;
        CGFloat alpha = MIN(1, 1 - ((NAVI_BAR_HEIGHT + 64 - offsetY) / 64));
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
    } else {
        self.navigationItem.title = @"用户中心";
        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
    }
}

#pragma mark --- AsyncDisplayTableViewCell Delegate
- (void)userPortraitDidClick:(__kindof AsyncDisplayTableViewCell *)cell{
//    OSCTweetItem* tweetItem = [cell valueForKey:@"tweetItem"];
//    OSCUserHomePageController* otherUserHomePage = [[OSCUserHomePageController alloc]initWithUserID:tweetItem.author.id];
//    [self.navigationController pushViewController:otherUserHomePage animated:YES];
}
- (void)loadLargeImageDidFinsh:(__kindof AsyncDisplayTableViewCell *)cell
                photoGroupView:(OSCPhotoGroupView *)groupView
                      fromView:(UIImageView *)fromView
{
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
//    [groupView presentFromImageView:fromView toContainer:currentWindow animated:YES completion:nil];
    /** 点开拿到大图之后 用大图更新update缩略图 提高清晰度 */
    [groupView presentFromImageView:fromView toContainer:currentWindow animated:YES completion:^{
        OSCTweetItem* tweetItem = [cell valueForKey:@"tweetItem"];
        OSCTweetImages* currentImageItem = tweetItem.images[groupView.currentPage];
        UIImage* image = [[YYWebImageManager sharedManager].cache getImageForKey:currentImageItem.href withType:YYImageCacheTypeMemory];
        if (image) { fromView.image = image; }
    }];
}
- (void)changeTweetStausButtonDidClick:(__kindof AsyncDisplayTableViewCell *)cell{
    [self toPraise:cell];
}
- (void) shouldInteractTextView:(UITextView* )textView
                            URL:(NSURL *)URL
                        inRange:(NSRange)characterRange
{
    [self.navigationController handleURL:URL name:nil];
}
- (void)textViewTouchPointProcessing:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.tableView];
    [self tableView:self.tableView didSelectRowAtIndexPath:[self.tableView indexPathForRowAtPoint:point]];
}

- (void)setBlockForCommentCell:(__kindof AsyncDisplayTableViewCell *)cell{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        }else{
            return NO;
        }
    };
}




#pragma mark --- setting NaviBar Item
-(void)settingNaviBarItem{
    _rightBarMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarMessageBtn.userInteractionEnabled = YES;
    _rightBarMessageBtn.frame  = CGRectMake(0, 0, 36, 36);
    [_rightBarMessageBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [_rightBarMessageBtn setTitle:@"" forState:UIControlStateNormal];
    [_rightBarMessageBtn setBackgroundImage:[UIImage imageNamed:@"btn_pm_normal"] forState:UIControlStateNormal];
    [_rightBarMessageBtn setBackgroundImage:[UIImage imageNamed:@"btn_pm_pressed"] forState:UIControlStateHighlighted];
    
    _rightBarFollowrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarFollowrBtn.userInteractionEnabled = YES;
    _rightBarFollowrBtn.frame  = CGRectMake(0, 0, 36, 36);
    [_rightBarFollowrBtn addTarget:self action:@selector(updateRelationship) forControlEvents:UIControlEventTouchUpInside];
    [_rightBarFollowrBtn setTitle:@"" forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:_rightBarFollowrBtn] ,[[UIBarButtonItem alloc] initWithCustomView:_rightBarMessageBtn]];;
}
- (void)sendMessage{
    if ([Config getOwnID] == 0) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeText;
        HUD.label.text = @"请先登录";
        [HUD hideAnimated:YES afterDelay:0.5];
    } else {
        BubbleChatViewController* chatVC = [[BubbleChatViewController alloc]initWithUserID:_user.id andUserName:_user.name];
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}
#pragma mark --点赞（新接口)
- (void)toPraise:(__kindof AsyncDisplayTableViewCell*)cell{
    OSCTweetItem* tweet = [cell valueForKey:@"tweetItem"];
    if (tweet.id == 0) {
        return;
    }
    NSString *postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_TWEET_LIKE_REVERSE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager POST:postUrl
       parameters:@{@"sourceId":@(tweet.id)}
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              
              if([responseObject[@"code"]integerValue] == 1) {
                  tweet.liked = !tweet.liked;
                  NSDictionary* resultDic = responseObject[@"result"];
                  tweet.likeCount = [resultDic[@"likeCount"] integerValue];
              }else {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.label.text = [NSString stringWithFormat:@"%@", responseObject[@"message"]?:@"未知错误"];
                  [HUD hideAnimated:YES afterDelay:1];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [cell setLikeStatus:tweet.liked animation:tweet.liked];
              });
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.label.text = @"网络错误";
              [HUD hideAnimated:YES afterDelay:1];
          }
     ];
}
#pragma mark - 改变状态(关注 & 取消关注)
- (void)updateRelationship{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        [manger POST:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX,OSCAPI_USER_RELATION_REVERSE] parameters:@{ @"id" : @(_user.id) }
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 if ([responseObject[@"code"] floatValue] == 1) {
                     NSDictionary* resultDic = responseObject[@"result"];
                     _user.relation = [resultDic[@"relation"] intValue];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         HUD.mode = MBProgressHUDModeCustomView;
                         if (_user.relation == 1 || _user.relation == 2) {
                             HUD.label.text = @"关注成功";
                         }else{
                             HUD.label.text = @"取消关注";
                         }
                         
                         [HUD hideAnimated:YES afterDelay:1];
                         [self updateRelationshipImage];
                     });
                 }else{
                     HUD.mode = MBProgressHUDModeCustomView;
                     HUD.label.text = @"数据异常";
                     
                     [HUD hideAnimated:YES afterDelay:1];
                 }
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"网络异常，操作失败";
                 
                 [HUD hideAnimated:YES afterDelay:1];
             }];
    }
}
/** 更新关注状态照片*/
-(void)updateRelationshipImage{
    UIImage* relationImageNomal;
    UIImage* relationImagePress;
    if (_user.relation == 1) {
        relationImageNomal = [UIImage imageNamed:@"btn_following_both_normal"];
        relationImagePress = [UIImage imageNamed:@"btn_following_both_pressed"];
    }else if (_user.relation == 2){
        relationImageNomal = [UIImage imageNamed:@"btn_following_normal"];
        relationImagePress = [UIImage imageNamed:@"btn_following_pressed"];
    }else{
        relationImageNomal = [UIImage imageNamed:@"btn_follow_normal"];
        relationImagePress = [UIImage imageNamed:@"btn_follow_pressed"];
    }
    
    [_rightBarFollowrBtn setBackgroundImage:relationImageNomal forState:UIControlStateNormal];
    [_rightBarFollowrBtn setBackgroundImage:relationImagePress forState:UIControlStateHighlighted];
}
#pragma mark - 切换tableView数据源 & 选择性发送请求
- (void)changeTableViewDataSourceWithButton:(UIButton* )button{
    if (button.tag == _currentIndex) {return;}
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _currentIndex = button.tag;
    [self updateButtonStyle];
    
    NSMutableArray* dataSource = self.dataSources[_currentIndex];
    if (dataSource.count == 0) {
        [self getDataThroughDropdown:YES];
    }else{
        [self.tableView reloadData];
    }
}
- (void)updateButtonStyle{
    for (UIButton* btn in self.buttons) {
        btn.selected = NO;
    }
    self.buttons[_currentIndex].selected = YES;
}

#pragma mark --- 路由分发
#pragma mark - 获取请求所需 url & parameter(请求的字段名字)
- (NSDictionary* )getRequestMaterial:(NSInteger)currentIndex{
    NSMutableDictionary* materialDic = [NSMutableDictionary dictionaryWithCapacity:3];
    NSString* urlStr = nil;
    NSString* parameter = nil;
    
    if (currentIndex == 1) {
        urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_TWEETS];
        parameter = @"authorId";
    }else if (currentIndex == 2){
        urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_BLOGS_LIST];
        parameter = @"authorId";
    }else if (currentIndex == 3){
        urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_QUESTION];
        parameter = @"authorId";
    }else if (currentIndex == 4){
        urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_ACTIVITY];
        parameter = @"id";
    }
    
    [materialDic setValue:urlStr forKey:requestUrl];
    [materialDic setValue:parameter forKey:requestParameter];
    
    return [materialDic copy];
}
#pragma mark - 处理请求返回的原始JSON
- (NSArray* )handleOriginal_JSON:(NSDictionary* )original_JSON
                    currentIndex:(NSInteger)currentIndex{
    NSArray* models = @[];
    
    switch (currentIndex) {
        case 1:{
            NSArray* items = original_JSON[@"items"];
//            models = [OSCTweetItem mj_objectArrayWithKeyValuesArray:items];
            models = [NSArray osc_modelArrayWithClass:[OSCTweetItem class] json:items];
            for (OSCTweetItem* tweetItem in models) {
                [tweetItem calculateLayout];
            }
            break;
        }
        case 2:{
            NSArray* items = original_JSON[@"items"];
//            models = [OSCNewHotBlog mj_objectArrayWithKeyValuesArray:items];
            models = [NSArray osc_modelArrayWithClass:[OSCNewHotBlog class] json:items];
            break;
        }
        case 3:{
            NSArray* items = original_JSON[@"items"];
//            models = [OSCQuestion mj_objectArrayWithKeyValuesArray:items];
            models = [NSArray osc_modelArrayWithClass:[OSCQuestion class] json:items];
            break;
        }
        case 4:{
            NSArray* items = original_JSON[@"items"];
//            models = [OSCDiscuss mj_objectArrayWithKeyValuesArray:items];
            models = [NSArray osc_modelArrayWithClass:[OSCDiscuss class] json:items];
            break;
        }
        default:{
            return nil;
            break;
        }
    }
    return models;
}

#pragma mark --- 界面列表分发
- (__kindof UITableViewCell* )getCurrentDisplayCell:(NSInteger)currentIndex
                                          tableView:(UITableView* )tableView
                                          indexPath:(NSIndexPath* )indexPath
                                         dataSource:(__kindof NSObject* )model{
    switch (currentIndex) {
        case 1:{    //tweet
            OSCTweetItem* tweetItem = (OSCTweetItem* )model;
            if (tweetItem.images.count == 0) {
                OSCTextTweetCell* textCell = [OSCTextTweetCell returnReuseTextTweetCellWithTableView:tableView identifier:reuseTextTweetCellReuseIdentifier];
                textCell.tweetItem = tweetItem;
                textCell.delegate = self;
                [self setBlockForCommentCell:textCell];
                return textCell;
            }else if (tweetItem.images.count == 1){
                OSCImageTweetCell* imageCell = [OSCImageTweetCell returnReuseImageTweetCellWithTableView:tableView identifier:reuseImageTweetCellReuseIdentifier];
                imageCell.tweetItem = tweetItem;
                imageCell.delegate = self;
                [self setBlockForCommentCell:imageCell];
                return imageCell;
            }else{
                OSCMultipleTweetCell* multipleCell = [OSCMultipleTweetCell returnReuseMultipleTweetCellWithTableView:tableView identifier:reuseMultipleTweetCellReuseIdentifier];
                multipleCell.tweetItem = tweetItem;
                multipleCell.delegate = self;
                [self setBlockForCommentCell:multipleCell];
                return multipleCell;
            }
            break;
        }
            
        case 2:{    //blogs
            OSCNewHotBlog* blogItem = (OSCNewHotBlog* )model;
            NewHotBlogTableViewCell* blogCell = [NewHotBlogTableViewCell returnReuseNewHotBlogCellWithTableView:tableView indexPath:indexPath identifier:reuseNewHotBlogTableViewCellReuseIdentifier];
            blogCell.blog = blogItem;
            return blogCell;
            break;
        }
            
        case 3:{    //question
            OSCQuestion* questionItem = (OSCQuestion* )model;
            QuesAnsTableViewCell* questionCell = [tableView dequeueReusableCellWithIdentifier:reuseQuesAnsTableViewCellReuseIdentifier forIndexPath:indexPath];
            questionCell.viewModel = questionItem;
            return questionCell;
            break;
        }
            
        case 4:{    //discuss
            OSCDiscuss* discuss = (OSCDiscuss* )model;
            OSCDiscussCell* discussCell = [OSCDiscussCell returnReuseDiscussCellWithTableView:tableView indexPath:indexPath identifier:reuseDiscussCellReuseIdentifier];
            discussCell.discuss = discuss;
            return discussCell;
            break;
        }
            
        default:
            return nil;
            break;
    }
}
- (CGFloat)getCurrentDisplayCellRowHeight:(NSInteger)currentIndex
                               dataSource:(__kindof NSObject* )model{
    switch (currentIndex) {
        case 1:{
            OSCTweetItem* tweetItem = (OSCTweetItem* )model;
            if (tweetItem.images.count == 0) {
                if (tweetItem.rowHeight == 0) {
                    tweetItem.rowHeight = padding_top + nameLabel_H + nameLabel_space_descTextView + tweetItem.descTextFrame.size.height + descTextView_space_timeAndSourceLabel + timeAndSourceLabel_H + padding_bottom;
                }
                return tweetItem.rowHeight;
            }else if (tweetItem.images.count == 1){
                if (tweetItem.rowHeight == 0) {
                    tweetItem.rowHeight = padding_top + nameLabel_H + nameLabel_space_descTextView + tweetItem.descTextFrame.size.height + descTextView_space_imageView + tweetItem.imageFrame.size.height + imageView_space_timeAndSourceLabel + timeAndSourceLabel_H + padding_bottom;
                }
                return tweetItem.rowHeight;
            }else{
                if (tweetItem.rowHeight == 0) {
                    tweetItem.rowHeight = padding_top + nameLabel_H + nameLabel_space_descTextView + tweetItem.descTextFrame.size.height + descTextView_space_imageView + tweetItem.multipleFrame.frame.size.height + imageView_space_timeAndSourceLabel + timeAndSourceLabel_H + padding_bottom;
                }
                return tweetItem.rowHeight;
            }
            break;
        }
        
        case 2:{
            return UITableViewAutomaticDimension;
            break;
        }
        
        case 3:{
            return UITableViewAutomaticDimension;
            break;
        }
            
        case 4:{
            return UITableViewAutomaticDimension;
            break;
        }
            
        default:
            return 0;
            break;
    }
}

#pragma mark --- 跳转分发
- (void)pushControllerHelper:(NSInteger)currentIndex
                   indexPath:(NSIndexPath* )indexPath{
    switch (currentIndex) {
        case 1:{
            NSMutableArray* currentDataSource = self.dataSources[currentIndex];
            OSCTweetItem* tweetItem = currentDataSource[indexPath.row];
            TweetDetailsWithBottomBarViewController *tweetDetailsBVC = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:tweetItem.id];
            [self.navigationController pushViewController:tweetDetailsBVC animated:YES];
            break;
        }
        case 2:{
            NSMutableArray* currentDataSource = self.dataSources[currentIndex];
            OSCNewHotBlog* blogItem = currentDataSource[indexPath.row];
            NewBlogDetailController* blogDetailVC = [[NewBlogDetailController alloc] initWithBlogId:blogItem.id];
            blogDetailVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:blogDetailVC animated:YES];
            break;
        }
        case 3:{
            NSMutableArray* currentDataSource = self.dataSources[currentIndex];
            OSCQuestion* question = currentDataSource[indexPath.row];
            QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.questionID = question.Id;
            [self.navigationController pushViewController:detailVC animated:YES];
            break;
        }
        case 4:{
            NSMutableArray* currentDataSource = self.dataSources[currentIndex];
            OSCDiscuss* discuss = currentDataSource[indexPath.row];
            if (discuss.origin.type == OSCDiscusOriginTypeLineNews) {
                [self.navigationController handleURL:[NSURL URLWithString:discuss.origin.href] name:nil];
            }
            UIViewController* pushVC = [OSCPushTypeControllerHelper pushControllerWithDiscussOriginType:discuss.origin];
            if (pushVC == nil) {
                [self.navigationController handleURL:[NSURL URLWithString:discuss.origin.href] name:nil];
            }else{
                [self.navigationController pushViewController:pushVC animated:YES];
            }
            break;
        }
            
        default:
            break;
    }
}


#pragma mark --- 装配HeaderView
- (void) assemblyHeaderView{
    [self.headerCanvasView setContentWithUserItem:_user];
    self.headerCanvasView.followsBtn.tag = 1;
    self.headerCanvasView.fansBtn.tag = 2;
    
    [self.headerCanvasView.followsBtn addTarget:self action:@selector(pushFriendsVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerCanvasView.fansBtn addTarget:self action:@selector(pushFriendsVC:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttons[1] setTitle:[NSString stringWithFormat:@"%@\n动弹",[Utils numberLimitString:(int)_user.statistics.tweet]] forState:UIControlStateNormal];
    [self.buttons[2] setTitle:[NSString stringWithFormat:@"%@\n博客",[Utils numberLimitString:(int)_user.statistics.blog]] forState:UIControlStateNormal];
    [self.buttons[3] setTitle:[NSString stringWithFormat:@"%@\n问答",[Utils numberLimitString:(int)_user.statistics.answer]] forState:UIControlStateNormal];
    [self.buttons[4] setTitle:[NSString stringWithFormat:@"%@\n讨论",[Utils numberLimitString:(int)_user.statistics.discuss]] forState:UIControlStateNormal];
}
#pragma mark - 处理页面跳转
- (void)pushFriendsVC:(UIButton *)button{
    if (button.tag == 1) {//关注
        FriendsViewController* followsVC = [[FriendsViewController alloc]initUserId:_user.id andRelation:OSCAPI_USER_FOLLOWS];
        followsVC.title = @"关注";
        [self.navigationController pushViewController:followsVC animated:YES];
    }else{//粉丝
        FriendsViewController* fansVC = [[FriendsViewController alloc]initUserId:_user.id andRelation:OSCAPI_USER_FANS];
        fansVC.title = @"粉丝";
        [self.navigationController pushViewController:fansVC animated:YES];
    }
}

#pragma mark --- lazy loading
- (UITableView *)tableView {
	if(_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:(CGRect){{0,0},{kScreen_W,self.view.bounds.size.height}} style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.tableFooterView = [UIView new];
	}
	return _tableView;
}
- (UserDrawHeaderView *)headerCanvasView {
    if(_headerCanvasView == nil) {
        _headerCanvasView = [[UserDrawHeaderView alloc] initWithFrame:(CGRect){{0,0},{[UIScreen mainScreen].bounds.size.width,HEADER_VIEW_HEIGHT}}];
    }
    return _headerCanvasView;
}
- (UIView *)sectionHeaderView {
    if(_sectionHeaderView == nil) {
        _sectionHeaderView = [[UIView alloc] initWithFrame:(CGRect){{0,0},{kScreen_W,SECTION_HEADER_VIEW_HEIGHT}}];
        _sectionHeaderView.backgroundColor = [UIColor colorWithHex:0x24CF5F];
        for (UIButton* button in self.buttons) {
            [_sectionHeaderView addSubview:button];
        }
    }
    return _sectionHeaderView;
}
- (NSMutableArray<UIButton* > *)buttons {
    if(_buttons == nil) {
        _buttons = @[[UIButton new],[UIButton new],[UIButton new],[UIButton new],[UIButton new]].mutableCopy;
        for (int i = 0; i < 4; i++) {
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i + 1;
            btn.frame = (CGRect){{(kScreen_W * 0.25) * i,0},{kScreen_W * 0.25,SECTION_HEADER_VIEW_HEIGHT}};
            [btn setTitleColor:[[UIColor colorWithHex:0xEEEEEE] colorWithAlphaComponent:0.66] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHex:0xEEEEEE] forState:UIControlStateSelected];
            btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn addTarget:self action:@selector(changeTableViewDataSourceWithButton:) forControlEvents:UIControlEventTouchUpInside];
            _buttons[ i + 1 ] = btn;
        }
    }
    return _buttons;
}
- (NSMutableArray<NSMutableArray* > *)dataSources {
	if(_dataSources == nil) {
        _dataSources = @[@[].mutableCopy,@[].mutableCopy,@[].mutableCopy,@[].mutableCopy,@[].mutableCopy].mutableCopy;
	}
	return _dataSources;
}
- (NSMutableArray<NSString* > *)nextTokens {
	if(_nextTokens == nil) {
		_nextTokens = @[@"",@"",@"",@"",@""].mutableCopy;
	}
	return _nextTokens;
}

@end
