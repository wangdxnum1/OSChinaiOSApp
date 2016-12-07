//
//  ActivityDetailViewController.m
//  iosapp
//
//  Created by 李萍 on 16/5/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "ActivityHeadCell.h"
#import "ActivityDetailCell.h"
#import "PresentMembersViewController.h"
#import "ActivitySignUpViewController.h"
#import "NewLoginViewController.h"
#import "OSCCommentReplyViewController.h"

#import "Utils.h"
#import "Config.h"
#import "OSCAPI.h"
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>
#import <MJExtension.h>
#import "UMSocial.h"
#import "OSCActivityFooterView.h"

#import "OSCActivities.h"
#import "OSCModelHandler.h"

@import SafariServices ;

static NSString * const activityHeadDetailReuseIdentifier = @"ActivityHeadCell";
static NSString * const activityDetailReuseIdentifier = @"ActivityDetailCell";
@interface ActivityDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate,OSCActivityFooterDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (nonatomic, strong) NSArray *cellTypes;

@property (nonatomic, strong) OSCActivities *activityDetail;
@property (nonatomic, assign) int64_t     activityID;
@property (nonatomic, copy)   NSString *HTML;
@property (nonatomic, assign) BOOL      isLoadingFinished;
@property (nonatomic, assign) CGFloat   webViewHeight;

@property (nonatomic, assign) BOOL isFav;
@property (nonatomic,strong) MBProgressHUD* HUD;

@property (nonatomic,strong) OSCActivityFooterView *footerView;

@end

@implementation ActivityDetailViewController


- (instancetype)initWithActivityID:(int64_t)activityID
{
    self = [super init];
    if (self) {
        _activityID = activityID;
    }
    
    return self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _HUD.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"活动详情";
    self.navigationController.navigationBar.translucent = YES;
    
    _footerView = [[OSCActivityFooterView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _footerView.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ActivityHeadCell" bundle:nil] forCellReuseIdentifier:activityHeadDetailReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ActivityDetailCell" bundle:nil] forCellReuseIdentifier:activityDetailReuseIdentifier];
    
    self.tableView.hidden = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 250;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [UIView new];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_share_black_pressed"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(shareForActivity:)];
    
    [self fetchForActivityDetailDate];
    _cellTypes = @[@"priceType", @"timeType", @"addressType", @"descType"];
    self.bottomView.backgroundColor = [UIColor newCellColor];
}

- (void)didReceiveMemoryWarning {
    [self.navigationController popViewControllerAnimated:YES];
    [super didReceiveMemoryWarning];
}

#pragma mark - right BarButton
- (void)shareForActivity:(UIBarButtonItem *)barButton
{
	NSLog(@"share");
	
	NSString *trimmedHTML = [_activityDetail.body deleteHTMLTag];
	NSInteger length = trimmedHTML.length < 60 ? trimmedHTML.length : 60;
	NSString *digest = [trimmedHTML substringToIndex:length];
	
	// 微信相关设置
	[UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
	[UMSocialData defaultData].extConfig.wechatSessionData.url = _activityDetail.href;
	[UMSocialData defaultData].extConfig.wechatTimelineData.url = _activityDetail.href;
	[UMSocialData defaultData].extConfig.title = _activityDetail.title;
	
	// 手机QQ相关设置
	[UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
	[UMSocialData defaultData].extConfig.qqData.title = _activityDetail.title;
	//[UMSocialData defaultData].extConfig.qqData.shareText = weakSelf.objectTitle;
	[UMSocialData defaultData].extConfig.qqData.url = _activityDetail.href;
	
	// 新浪微博相关设置
	[[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:_activityDetail.href];
	
	[UMSocialSnsService presentSnsIconSheetView:self
										 appKey:@"54c9a412fd98c5779c000752"
									  shareText:[NSString stringWithFormat:@"%@...分享来自 %@", digest, _activityDetail.href]
									 shareImage:[UIImage imageNamed:@"logo"]
								shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
									   delegate:nil];
}

#pragma mark - 获取数据
- (void)fetchForActivityDetailDate
{
	
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.userInteractionEnabled = NO;
	
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    NSString *activityDetailUrlStr= [NSString stringWithFormat:@"%@event?id=%lld", OSCAPI_V2_PREFIX, _activityID];
    
    [manager GET:activityDetailUrlStr
      parameters:nil
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if ([responseObject[@"code"]integerValue] == 1) {
                 _activityDetail = [OSCActivities mj_objectWithKeyValues:responseObject[@"result"]];
                 
                 _activityDetail.body = [Utils HTMLWithData:@{@"content":  _activityDetail.body}
                                              usingTemplate:@"newTweet"];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.commentButton setTitle:[NSString stringWithFormat:@"评论(%ld)", (long)_activityDetail.commentCount] forState:UIControlStateNormal];
                     [self setFavButtonAction:_activityDetail.favorite];
                     [self setApplyButton:_activityDetail.applyStatus];
                     [_footerView setNeedLoad:_activityDetail.body];
                 });
             }else{
                 _HUD.hidden = YES;
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"这个活动找不到了(不存在/已删除)";
                 [HUD hideAnimated:YES afterDelay:1];
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self.navigationController popViewControllerAnimated:YES];
                 });
             }
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            MBProgressHUD *HUD = [MBProgressHUD new];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.label.text = @"网络异常，加载失败";

            [HUD hideAnimated:YES afterDelay:1];
    }];

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ActivityHeadCell *cell = [_tableView dequeueReusableCellWithIdentifier:activityHeadDetailReuseIdentifier forIndexPath:indexPath];
        
        cell.activity = _activityDetail;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.backgroundColor = [UIColor navigationbarColor];
        cell.contentView.backgroundColor = [UIColor navigationbarColor];
        
        return cell;
    } else if (indexPath.row > 0){
        ActivityDetailCell *cell = [_tableView dequeueReusableCellWithIdentifier:activityDetailReuseIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cellType = _cellTypes[indexPath.row-1];
        cell.activity = _activityDetail;
        cell.contentView.backgroundColor = [UIColor newCellColor];
        cell.backgroundColor = [UIColor themeColor];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
        return cell;
    }
    
    
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 210;
    } else {
        return UITableViewAutomaticDimension;
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
        self.footerView.frame = CGRectMake(0, 0, kScreenSize.width , height);
        _HUD.hidden = YES;
        self.tableView.tableFooterView = self.footerView;
        [self.tableView reloadData];
        self.tableView.hidden = NO;
    });
}


#pragma mark - button clicked
- (IBAction)settingTouchDownColor:(UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithHex:0x188E50];
}
- (IBAction)settingTouchUp:(UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithHex:0x18BB50];
}

- (IBAction)clickedButton:(UIButton *)sender {
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        if (sender.tag == 1) {
            //收藏
            [self postFav];
        } else if (sender.tag == 2){
            //报名
            [self enrollActivity];
        } else if (sender.tag == 3) {
            OSCCommentReplyViewController *newCommentVC = [[OSCCommentReplyViewController alloc] initWithCommentType:CommentIdTypeForActivity sourceID:_activityDetail.id];
            
            [self.navigationController pushViewController:newCommentVC animated:YES];
        }
    }
    
}

- (void)setFavButtonAction:(BOOL)isStarted
{
    if (isStarted) {
        self.isFav = YES;
        [_favButton setTitle:@"已收藏" forState:UIControlStateNormal];
        [_favButton setImage:[UIImage imageNamed:@"ic_faved_pressed"] forState:UIControlStateNormal];
    } else {
        self.isFav = NO;
        [_favButton setTitle:@"收藏" forState:UIControlStateNormal];
        [_favButton setImage:[UIImage imageNamed:@"ic_fav_pressed"] forState:UIControlStateNormal];
    }
}

- (void)setApplyButton:(ApplyStatus)appStatus
{
    switch (appStatus) {
        case ApplyStatusUnSignUp://未报名
        {
            _addButton.backgroundColor = [UIColor colorWithHex:0x18BB50];
            [_addButton setTitle:@"我要报名" forState:UIControlStateNormal];
            [_addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_addButton setImage:[UIImage imageNamed:@"ic_user_add-1"] forState:UIControlStateNormal];
            _addButton.enabled = YES;
            break;
        }
        case ApplyStatusAudited://审核中
        {
            _addButton.backgroundColor = [UIColor colorWithHex:0xeeeeee];
            [_addButton setTitle:@"审核中" forState:UIControlStateNormal];
            [_addButton setTitleColor:[UIColor colorWithHex:0xd5d5d5] forState:UIControlStateNormal];
            [_addButton setImage:[UIImage imageNamed:@"ic_user_add"] forState:UIControlStateNormal];
            _addButton.enabled = NO;
            break;
        }
        case ApplyStatusDetermined://已经确认
        {
            _addButton.backgroundColor = [UIColor colorWithHex:0xeeeeee];
            [_addButton setTitle:@"已确认" forState:UIControlStateNormal];
            [_addButton setTitleColor:[UIColor colorWithHex:0xd5d5d5] forState:UIControlStateNormal];
            [_addButton setImage:[UIImage imageNamed:@"ic_user_add"] forState:UIControlStateNormal];
            _addButton.enabled = NO;
            break;
        }
        case ApplyStatusAttended://已经出席
        {
            _addButton.backgroundColor = [UIColor colorWithHex:0xeeeeee];
            [_addButton setTitle:@"已出席" forState:UIControlStateNormal];
            [_addButton setTitleColor:[UIColor colorWithHex:0xd5d5d5] forState:UIControlStateNormal];
            [_addButton setImage:[UIImage imageNamed:@"ic_user_add"] forState:UIControlStateNormal];
            _addButton.enabled = NO;
            break;
        }
        case ApplyStatusCanceled://已取消
        {
            _addButton.backgroundColor = [UIColor colorWithHex:0xeeeeee];
            [_addButton setTitle:@"已取消" forState:UIControlStateNormal];
            [_addButton setTitleColor:[UIColor colorWithHex:0xd5d5d5] forState:UIControlStateNormal];
            [_addButton setImage:[UIImage imageNamed:@"ic_user_add"] forState:UIControlStateNormal];
            _addButton.enabled = NO;
            break;
        }
        case ApplyStatusRejected://已拒绝
        {
            _addButton.backgroundColor = [UIColor colorWithHex:0xeeeeee];
            [_addButton setTitle:@"已拒绝" forState:UIControlStateNormal];
            [_addButton setTitleColor:[UIColor colorWithHex:0xd5d5d5] forState:UIControlStateNormal];
            [_addButton setImage:[UIImage imageNamed:@"ic_user_add"] forState:UIControlStateNormal];
            _addButton.enabled = NO;
            break;
        }
        default:
            break;
    }
}

#pragma mark - fav
- (void)postFav
{
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger POST:[NSString stringWithFormat:@"%@/favorite_reverse", OSCAPI_V2_PREFIX]
      parameters:@{
                   @"id"   : @(_activityDetail.id),
                   @"type" : @(5)
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if ([responseObject[@"code"] integerValue]== 1) {
                 _activityDetail.favorite = [responseObject[@"result"][@"favorite"] boolValue];
             }
             
             
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.label.text = _activityDetail.favorite? @"收藏成功": @"取消收藏";
             
             [HUD hideAnimated:YES afterDelay:1];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self setFavButtonAction:_activityDetail.favorite];
                 [self.tableView reloadData];
             });
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.label.text = @"网络异常，操作失败";
             
             [HUD hideAnimated:YES afterDelay:1];
         }];
}

#pragma mark - 报名

- (void)enrollActivity
{
    if (_activityDetail.type == ActivityTypeBelow) {
		NSURL *url = [NSURL URLWithString:_activityDetail.href];
		if([[[UIDevice currentDevice] systemVersion] hasPrefix:@"9"]) {
			SFSafariViewController *webviewController = [[SFSafariViewController alloc] initWithURL:url];
			[self.navigationController pushViewController:webviewController animated:YES];
		} else {
			[[UIApplication sharedApplication] openURL:url];
		}
    } else {
        if (_activityDetail.applyStatus == ApplyStatusAttended) {
            PresentMembersViewController *presentMembersViewController = [[PresentMembersViewController alloc] initWithEventID:_activityDetail.id ];
            [self.navigationController pushViewController:presentMembersViewController animated:YES];
        } else {
            ActivitySignUpViewController *signUpViewController = [ActivitySignUpViewController new];
            signUpViewController.eventId = _activityDetail.id;
            
            signUpViewController.remarkTipStr = _activityDetail.remark[@"tip"];
            NSString *citys = _activityDetail.remark[@"select"];
            signUpViewController.remarkCitys = [citys componentsSeparatedByString:@","];
            [self.navigationController pushViewController:signUpViewController animated:YES];
        }
    }
}

@end
