//
//  OSCRecommendTopicsController.m
//  iosapp
//
//  Created by Graphic-one on 16/11/4.
//  Copyright © 2016年 oschina. All rights reserved.
//

#define kScreen_Width [UIScreen mainScreen].bounds.size.width
#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kHeaderView_Height 160

#define kHeaderView_PeopleLabel_topPadding 60
#define kHeaderView_PeopleLabel_Height 18
#define kHeaderView_descLabel_verticalPadding 13
#define kHeaderView_descLabel_horizontalPadding 40

#define kSectionView_Height 40
#define kSectionView_BgColor [UIColor colorWithHex:0xf6f6f6]
#define kSectionView_Btn_Color_Nomal [UIColor colorWithHex:0x6a6a6a]
#define kSectionView_Btn_Color_Select [UIColor colorWithHex:0x24cf5f]

#define hot_Tag 1001
#define latest_Tag 1002

#import "OSCRecommendTopicsController.h"
#import "TweetTableViewController.h"

#import "UIColor+Util.h"
#import "AFHTTPRequestOperationManager+Util.h"

#import <UMSocial.h>

@interface OSCRecommendTopicsController () <UIScrollViewDelegate>
@property (nonatomic,strong) TweetTableViewController* latestRecommendVC , *hotRecommendVC;
@property (nonatomic,strong) UIButton* latestBtn , *hotBtn;
@property (nonatomic,strong) UIScrollView* listScrollView;
@property (nonatomic,strong) UIView* headerView , *sectionHeaderView;
@property (nonatomic,strong) UILabel* peopleCountLabel , * descLabel;
@end

@implementation OSCRecommendTopicsController{
    TopicRecommedTweetType _imageType;
    NSInteger _curBenTag;
}

#pragma mark - public init M
- (instancetype)initWithTopicName:(NSString* )topicName
{
    self = [super init];
    if (self) {
        self.navigationController.title = topicName;
        self.headerView.hidden = NO;
        _peopleCountLabel.text = [NSString stringWithFormat:@"共有 ### 人参与"];
        _descLabel.text = [NSString stringWithFormat:@"尽情发表你对 #%@# 话题的看法吧",topicName];
        
        [self getHeaderInfoRequest:topicName];
        
        _latestRecommendVC = [[TweetTableViewController alloc] initWithTag:topicName order:TweetListOrderLatest];
        _hotRecommendVC = [[TweetTableViewController alloc] initWithTag:topicName order:TweetListOrderHot];
        [self addChildViewController:_latestRecommendVC];
        [self addChildViewController:_hotRecommendVC];
        
    }
    return self;
}

- (instancetype)initWithTopicName:(NSString* )topicName
                        topicDesc:(NSString* )topicDesc
                        joinCount:(NSInteger)joinCount
                          bgImage:(TopicRecommedTweetType)imageType
{
    self = [super init];
    if (self) {
        _imageType = imageType;
        
        self.navigationController.title = topicName;
        self.headerView.hidden = NO;
        _peopleCountLabel.text = [NSString stringWithFormat:@"共有 %ld 人参与",(long)joinCount];
        _descLabel.text = topicDesc;
        
        _latestRecommendVC = [[TweetTableViewController alloc] initWithTag:topicName order:TweetListOrderLatest];
        _hotRecommendVC = [[TweetTableViewController alloc] initWithTag:topicName order:TweetListOrderHot];
        [self addChildViewController:_latestRecommendVC];
        [self addChildViewController:_hotRecommendVC];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStyleDone target:self action:@selector(shareForRecommen:)];
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self layouUI];
}

- (void)layouUI{
    [self.view addSubview:self.listScrollView];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.listScrollView];
    
    UITableView* latestTableView = _latestRecommendVC.tableView;
    latestTableView.frame = (CGRect){{0,0},{kScreen_Width,kScreen_Height - kHeaderView_Height - kSectionView_Height}};
    [self.listScrollView addSubview:latestTableView];
    
    UITableView* hotTableView = _hotRecommendVC.tableView;
    hotTableView.frame = (CGRect){{kScreen_Width,0},{kScreen_Height - kHeaderView_Height - kSectionView_Height}};
    [self.listScrollView addSubview:hotTableView];
}

#pragma mark - get HeaderInfo Request
- (void)getHeaderInfoRequest:(NSString* )topicName{
    NSString* urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_TWEETS_TOPIC];
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:urlStr
     parameters:@{
                  @"tag" : topicName,
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary* resultDic = responseObject[@"result"];
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSInteger joinCount = [resultDic[@"joinCount"] integerValue];
                    NSString* descStr = resultDic[@"desc"];
                    if (joinCount && joinCount != NSNotFound) {
                        _peopleCountLabel.text = [NSString stringWithFormat:@"共有 %ld 人参与",(long)joinCount];
                    }
                    if (descStr && descStr.length > 0) {
                        _descLabel.text = descStr;
                    }
                });
            }
    }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
    }];
}


#pragma mark - UIScrollView Delegate 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    
    if (offsetX < kScreen_Width * 0.5) {
        _hotBtn.selected = YES;
        _latestBtn.selected = NO;
    }else{
        _hotBtn.selected = NO;
        _latestBtn.selected = YES;
    }
}

#pragma mark - change dataSource
- (void)switchDataSource:(UIButton* )button{
    if (_curBenTag == button.tag) { return ; }
    
    switch (button.tag) {
        case hot_Tag:
            _curBenTag = hot_Tag;
            [self.listScrollView setContentOffset:(CGPoint){0,0} animated:YES];
            break;
            
        case latest_Tag:
            _curBenTag = latest_Tag;
            [self.listScrollView setContentOffset:(CGPoint){kScreen_Width,0} animated:YES];
            break;
            
        default:
            return;
            break;
    }
}

#pragma mark - lazy load
- (UIScrollView *)listScrollView{
    if (!_listScrollView) {
        _listScrollView = ({
            UIScrollView* scrollView = [[UIScrollView alloc] init];
            scrollView.frame = (CGRect){{0,kHeaderView_Height + kSectionView_Height},{kScreen_Width,kScreen_Height - kHeaderView_Height - kSectionView_Height}};
            scrollView.contentSize = (CGSize){kScreen_Width * 2 , kScreen_Height - kHeaderView_Height - kSectionView_Height};
            scrollView.delegate = self;
            scrollView.pagingEnabled = YES;
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView;
        });
    }
    return _listScrollView;
}
- (UIView* )headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:(CGRect){{0,0},{kScreen_Width,kHeaderView_Height}}];
        [_headerView addSubview:({
            UIImageView* imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTopicRecommedTweetImageArray[_imageType]]];
            imageView.frame = _headerView.bounds;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView;
        })];
        [_headerView addSubview:({
            UILabel* peopleCountLabel = [[UILabel alloc] init];
            peopleCountLabel.frame = (CGRect){{0,kHeaderView_PeopleLabel_topPadding},{kScreen_Width,kHeaderView_PeopleLabel_Height}};
            peopleCountLabel.textColor = [UIColor whiteColor];
            peopleCountLabel.font = [UIFont boldSystemFontOfSize:14];
            peopleCountLabel.textAlignment = NSTextAlignmentCenter;
            peopleCountLabel.text = @" ";
            _peopleCountLabel = peopleCountLabel;
            peopleCountLabel;
        })];
        [_headerView addSubview:({
            UILabel* descLabel = [[UILabel alloc] init];
            descLabel.frame = (CGRect){{kHeaderView_descLabel_horizontalPadding,kHeaderView_PeopleLabel_topPadding + kHeaderView_PeopleLabel_Height + kHeaderView_descLabel_verticalPadding},{kScreen_Width - kHeaderView_descLabel_horizontalPadding * 2 ,kHeaderView_Height - kHeaderView_PeopleLabel_topPadding - kHeaderView_PeopleLabel_Height - kHeaderView_descLabel_verticalPadding}};
            descLabel.textColor = [UIColor whiteColor];
            descLabel.font = [UIFont systemFontOfSize:14];
            descLabel.textAlignment = NSTextAlignmentCenter;
            descLabel.text = @" ";
            _descLabel = descLabel;
            descLabel;
        })];
    }
    return _headerView;
}
- (UIView *)sectionHeaderView{
    if (!_sectionHeaderView) {
        _sectionHeaderView = [[UIView alloc] initWithFrame:(CGRect){{0,0},{kScreen_Width,kSectionView_Height}}];
        _sectionHeaderView.backgroundColor = kSectionView_BgColor;
        
        [_sectionHeaderView addSubview:({
            UIButton* hotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            hotBtn.frame = (CGRect){{0,0},{kScreen_Width * 0.5,kSectionView_Height}};
            hotBtn.tag = hot_Tag;
            [hotBtn setTitle:@"最热" forState:UIControlStateNormal];
            [hotBtn setBackgroundColor:[UIColor clearColor]];
            [hotBtn setTitleColor:kSectionView_Btn_Color_Nomal forState:UIControlStateNormal];
            [hotBtn setTitleColor:kSectionView_Btn_Color_Select forState:UIControlStateSelected];
            [hotBtn addTarget:self action:@selector(switchDataSource:) forControlEvents:UIControlEventTouchUpInside];
            _hotBtn = hotBtn;
            hotBtn;
        })];
        [_sectionHeaderView addSubview:({
            UIButton* latestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            latestBtn.frame = (CGRect){{kScreen_Width * 0.5,0},{kScreen_Width * 0.5,kSectionView_Height}};
            latestBtn.tag = latest_Tag;
            [latestBtn setTitle:@"最新" forState:UIControlStateNormal];
            [latestBtn setBackgroundColor:[UIColor clearColor]];
            [latestBtn setTitleColor:kSectionView_Btn_Color_Nomal forState:UIControlStateNormal];
            [latestBtn setTitleColor:kSectionView_Btn_Color_Select forState:UIControlStateSelected];
            [latestBtn addTarget:self action:@selector(switchDataSource:) forControlEvents:UIControlEventTouchUpInside];
            _latestBtn = latestBtn;
            latestBtn;
        })];
        
        //nomal setting
        _hotBtn.selected = YES;
        _latestBtn.selected = NO;
    }
    return _sectionHeaderView;
}

#pragma mark - share
- (void)shareForRecommen:(UIBarButtonItem *)barButton
{
/**
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
 */
}

@end
