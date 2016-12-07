//
//  DetailsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "DetailsViewController.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>
#import <TBXML.h>

#import "OSCAPI.h"
#import "OSCNews.h"
#import "OSCBlog.h"
#import "OSCPost.h"
#import "OSCSoftware.h"
#import "OSCNewsDetails.h"
#import "OSCBlogDetails.h"
#import "OSCPostDetails.h"
#import "OSCSoftwareDetails.h"
#import "Utils.h"
#import "Config.h"
#import "CommentsBottomBarViewController.h"
#import "SoftwareCommentsViewController.h"
#import "UMSocial.h"
#import "UIBarButtonItem+Badge.h"
#import "AppDelegate.h"
#import "OSCQuestion.h"
#import "OSCNewHotBlog.h"
#import "OSCInformation.h"

@interface DetailsViewController () <UIWebViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) CommentType commentType;
@property (nonatomic, assign) FavoriteType favoriteType;
@property (nonatomic, assign) int64_t objectID;
@property (nonatomic, assign) BOOL isStarred;

@property (nonatomic, strong) OSCNews *news;
@property (nonatomic, copy) NSString *detailsURL;
@property (nonatomic, readonly, assign) int commentCount;
@property (nonatomic, copy) NSString *webURL;
@property (nonatomic, copy) NSString *mURL;
@property (nonatomic, copy) NSString *objectTitle;
@property (nonatomic, strong) UIWebView *detailsView;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *softwareName;
@property (nonatomic, copy) NSString *digest;
@property (nonatomic, assign) SEL loadMethod;
@property (nonatomic, assign) Class detailsClass;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation DetailsViewController

#pragma mark - 初始化方法

- (instancetype)initWithNews:(OSCNews *)news
{
    self = [super initWithModeSwitchButton:YES];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _news = news;
        _objectID = news.newsID;
        
        switch (news.type) {
            case NewsTypeStandardNews:
                self.navigationItem.title = @"资讯详情";
                _detailsURL = [NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_NEWS_DETAIL, news.newsID];
                _tag = @"news";
                _commentType = CommentTypeNews;
                _favoriteType = FavoriteTypeNews;
                _detailsClass = [OSCNewsDetails class];
                _loadMethod = @selector(loadNewsDetails:);
                break;
            case NewsTypeSoftWare:
                self.navigationItem.title = @"软件详情";
                _detailsURL = [NSString stringWithFormat:@"%@%@?ident=%@", OSCAPI_PREFIX, OSCAPI_SOFTWARE_DETAIL, news.attachment];
                _tag = @"software";
                _commentType = CommentTypeSoftware;
                _favoriteType = FavoriteTypeSoftware;
                _softwareName = news.attachment;
                _detailsClass = [OSCSoftwareDetails class];
                _loadMethod = @selector(loadSoftwareDetails:);
                break;
            case NewsTypeQA:
                self.navigationItem.title = @"帖子详情";
                _detailsURL = [NSString stringWithFormat:@"%@%@?id=%@", OSCAPI_PREFIX, OSCAPI_POST_DETAIL, news.attachment];
                _tag = @"post";
                _objectID = [news.attachment longLongValue];
                _commentType = CommentTypePost;
                _favoriteType = FavoriteTypeTopic;
                _detailsClass = [OSCPostDetails class];
                _loadMethod = @selector(loadPostDetails:);
                break;
            case NewsTypeBlog:
                self.navigationItem.title = @"博客详情";
                _detailsURL = [NSString stringWithFormat:@"%@%@?id=%@", OSCAPI_PREFIX, OSCAPI_BLOG_DETAIL, news.attachment];
                _tag = @"blog";
                _commentType = CommentTypeBlog;
                _favoriteType = FavoriteTypeBlog;
                _objectID = [news.attachment longLongValue];
                _detailsClass = [OSCBlogDetails class];
                _loadMethod = @selector(loadBlogDetails:);
                break;
            default:
                break;
        }
    }
    
    return self;
}
#pragma mark --新的资讯详情初始化
- (instancetype)initWithInfo:(OSCInformation *)info {
    self = [super initWithModeSwitchButton:YES];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        //        _news = news;
        _objectID = info.id;
        self.navigationItem.title = @"资讯详情";
        _detailsURL = [NSString stringWithFormat:@"%@%@?id=%ld", OSCAPI_PREFIX, OSCAPI_NEWS_DETAIL, (long)info.id];
        _tag = @"news";
        _commentType = CommentTypeNews;
        _favoriteType = FavoriteTypeNews;
        _detailsClass = [OSCNewsDetails class];
        _loadMethod = @selector(loadNewsDetails:);
    }
    return self;
}
- (instancetype)initWithBlog:(OSCBlog *)blog
{
    self = [super initWithModeSwitchButton:YES];
    if (self) {
        _commentType = CommentTypeBlog;
        _favoriteType = FavoriteTypeBlog;
        _objectID = blog.blogID;
        
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.title = @"博客详情";
        _detailsURL = [NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_BLOG_DETAIL, blog.blogID];
        _tag = @"blog";
        _detailsClass = [OSCBlogDetails class];
        _loadMethod = @selector(loadBlogDetails:);
    }
    
    return self;
}
#pragma mark -- 旧接口新的初始化方式
- (instancetype)initWithNewHotBlog:(OSCNewHotBlog *)blog
{
    self = [super initWithModeSwitchButton:YES];
    if (self) {
        _commentType = CommentTypeBlog;
        _favoriteType = FavoriteTypeBlog;
        _objectID = blog.id;
        
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.title = @"博客详情";
        _detailsURL = [NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_BLOG_DETAIL, blog.id];
        _tag = @"blog";
        _detailsClass = [OSCBlogDetails class];
        _loadMethod = @selector(loadBlogDetails:);
    }
    
    return self;
}

- (instancetype)initWithPost:(OSCPost *)post
{
    self = [super initWithModeSwitchButton:YES];
    if (!self) {return nil;}
    
    _commentType = CommentTypePost;
    _favoriteType = FavoriteTypeTopic;
    _objectID = post.postID;
    
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.title = @"帖子详情";
    _detailsURL = [NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_POST_DETAIL, post.postID];
    _tag = @"post";
    _detailsClass = [OSCPostDetails class];
    _loadMethod = @selector(loadPostDetails:);
    
    return self;
}

- (instancetype)initWithQuestion:(OSCQuestion *)question
{
    self = [super initWithModeSwitchButton:YES];
    if (!self) {return nil;}
    
    _commentType = CommentTypePost;
    _favoriteType = FavoriteTypeTopic;
    _objectID = question.Id;
    
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.title = @"帖子详情";
    _detailsURL = [NSString stringWithFormat:@"%@%@?id=%ld", OSCAPI_PREFIX, OSCAPI_POST_DETAIL, (long)question.Id];
    _tag = @"post";
    _detailsClass = [OSCPostDetails class];
    _loadMethod = @selector(loadPostDetails:);
    
    return self;
}

- (instancetype)initWithSoftware:(OSCSoftware *)software
{
    self = [super initWithModeSwitchButton:YES];
    if (!self) {return nil;}
    
    _commentType = CommentTypeSoftware;
    _favoriteType = FavoriteTypeSoftware;
    
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.title = @"软件详情";
    _detailsURL = [NSString stringWithFormat:@"%@%@?ident=%@", OSCAPI_PREFIX, OSCAPI_SOFTWARE_DETAIL, software.url.absoluteString.lastPathComponent];
    
    _tag = @"software";
    _softwareName = software.name;
    _detailsClass = [OSCSoftwareDetails class];
    _loadMethod = @selector(loadSoftwareDetails:);
    //    http://www.oschina.net/news/73898/apache-shiro-1-2-5
    return self;
}
#pragma mark -- v2接口软件详情的初始化方式
- (instancetype)initWithV2Software:(OSCSoftware *)software
{
    self = [super initWithModeSwitchButton:YES];
    if (!self) {return nil;}
    
    _commentType = CommentTypeSoftware;
    _favoriteType = FavoriteTypeSoftware;
    
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.title = @"软件详情";
    _detailsURL = [NSString stringWithFormat:@"%@%@?id=%ld", OSCAPI_PREFIX, OSCAPI_SOFTWARE_DETAIL, software.softId];
    
    _tag = @"software";
    _softwareName = software.name;
    _detailsClass = [OSCSoftwareDetails class];
    _loadMethod = @selector(loadSoftwareDetails:);
    return self;
}


#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchDetails)];
    
    // 资讯、博客和软件详情没有“举报”选项
    if (_commentType == CommentTypeNews || _commentType == CommentTypeSoftware || _commentType == CommentTypeBlog) {
        self.operationBar.items = [self.operationBar.items subarrayWithRange:NSMakeRange(0, 12)];
    }
    
    _detailsView = [UIWebView new];
    _detailsView.delegate = self;
    _detailsView.scrollView.delegate = self;
    _detailsView.opaque = NO;
    _detailsView.backgroundColor = [UIColor themeColor];
    _detailsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_detailsView];
    
    [self.view bringSubviewToFront:(UIView *)self.editingBar];
    
    
    NSDictionary *views = @{@"detailsView": _detailsView, @"bottomBar": self.editingBar};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[detailsView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailsView][bottomBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
    
    [self.editingBar.modeSwitchButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    // 添加等待动画
    _HUD = [Utils createHUD];
    _HUD.userInteractionEnabled = NO;
    
    _manager = [AFHTTPRequestOperationManager OSCManager];
    [self fetchDetails];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode = [Config getMode];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_HUD hideAnimated:YES];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -

- (void)setBlockForOperationBar
{
    __weak typeof(self) weakSelf = self;
    
    /********* 收藏 **********/
    
    self.operationBar.toggleStar = ^ {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        NSString *API = weakSelf.isStarred? OSCAPI_FAVORITE_DELETE: OSCAPI_FAVORITE_ADD;
        [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, API]
           parameters:@{
                        @"uid":   @([Config getOwnID]),
                        @"objid": @(weakSelf.objectID),
                        @"type":  @(weakSelf.favoriteType)
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
                  
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  if (errorCode == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.label.text = weakSelf.isStarred? @"删除收藏成功": @"添加收藏成功";
                      weakSelf.isStarred = !weakSelf.isStarred;
                      weakSelf.operationBar.isStarred = weakSelf.isStarred;
                  } else {
//                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                      HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  }
                  
                  [HUD hideAnimated:YES afterDelay:1];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
//                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.label.text = @"网络异常，操作失败";
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    };
    
    
    /********** 显示回复 ***********/
    
    self.operationBar.showComments = ^ {
        if (weakSelf.commentType == CommentTypeSoftware) {
            SoftwareCommentsViewController *softwareCommentsVC = [[SoftwareCommentsViewController alloc] initWithSoftwareID:weakSelf.objectID andSoftwareName:weakSelf.softwareName];
            [weakSelf.navigationController pushViewController:softwareCommentsVC animated:YES];
        } else {
            CommentsBottomBarViewController *commentsBVC = [[CommentsBottomBarViewController alloc] initWithCommentType:weakSelf.commentType andObjectID:weakSelf.objectID];
            [weakSelf.navigationController pushViewController:commentsBVC animated:YES];
        }
    };
    
    
    /********** 分享设置 ***********/
    
    self.operationBar.share = ^ {
        NSString *title = weakSelf.objectTitle;
        
        // 微信相关设置
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
        [UMSocialData defaultData].extConfig.wechatSessionData.url = weakSelf.mURL;
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = weakSelf.mURL;
        [UMSocialData defaultData].extConfig.title = title;
        
        // 手机QQ相关设置
        [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
        [UMSocialData defaultData].extConfig.qqData.title = title;
        //[UMSocialData defaultData].extConfig.qqData.shareText = weakSelf.objectTitle;
        [UMSocialData defaultData].extConfig.qqData.url = weakSelf.mURL;
        
        // 新浪微博相关设置
        [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:weakSelf.mURL];
        
        // 复制链接
#if 0
        UMSocialSnsPlatform *snsPlatform = [[UMSocialSnsPlatform alloc] initWithPlatformName:@"CustomPlatform"];
        snsPlatform.displayName = @"复制链接";
        snsPlatform.bigImageName = @"UMS_facebook_icon";
        snsPlatform.snsClickHandler = ^(UIViewController *presentingController, UMSocialControllerService *socialControllerService, BOOL isPresentInController){
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = weakSelf.mURL;
            
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeText;
            HUD.label.text = @"复制成功";
            
            [HUD hideAnimated:YES afterDelay:1];
        };
        
        [UMSocialConfig addSocialSnsPlatform:@[snsPlatform]];
        [UMSocialConfig setSnsPlatformNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina, @"CustomPlatform"]];
#endif
        
        [UMSocialSnsService presentSnsIconSheetView:weakSelf
                                             appKey:@"54c9a412fd98c5779c000752"
                                          shareText:[NSString stringWithFormat:@"%@...分享来自 %@", weakSelf.digest, weakSelf.mURL]
                                         shareImage:[UIImage imageNamed:@"logo"]
                                    shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                           delegate:nil];
    };
    
    
    /*********** 举报 ************/
    
    self.operationBar.report = ^ {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"举报"
                                                            message:[NSString stringWithFormat:@"链接地址：%@", weakSelf.webURL]
                                                           delegate:weakSelf
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].placeholder = @"举报原因";
        if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode){
            [alertView textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceDark;
        }
        [alertView show];
    };
}

- (NSString *)mURL
{
    if (_mURL) {
        return _mURL;
    } else {
        NSMutableString *strUrl = [NSMutableString stringWithFormat:@"%@", _webURL];
        if (_commentType == CommentTypeBlog) {
            strUrl = [NSMutableString stringWithFormat:@"http://m.oschina.net/blog/%lld", _objectID];
        } else {
            [strUrl replaceCharactersInRange:NSMakeRange(7, 3) withString:@"m"];
        }
        _mURL = [strUrl copy];
        return _mURL;
    }
}

//#pragma mark -- detailsWithJsonData
//-(void)fetchDetailsWithJsonData {
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
//
//    [manager GET:_detailsURL parameters:nil success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error:%@",error);
//    }];
//}

- (void)fetchDetails
{
    [_manager GET:_detailsURL parameters:nil success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
        NSString *response = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        TBXML *XML = [[TBXML alloc]initWithXMLString:response error:nil];
        ONOXMLElement *onoXML = [responseDocument.rootElement firstChildWithTag:_tag];
        if (!onoXML || onoXML.children.count <= 0) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            id details;
            if ([_tag isEqualToString:@"blog"] || [_tag isEqualToString:@"post"]) {     //tbxml
                TBXMLElement *element = XML.rootXMLElement;
                TBXMLElement *subElement = [TBXML childElementNamed:_tag parentElement:element];
                details = [[_detailsClass alloc] initWithTBXMLElement:subElement];
            } else {     //onoxml
                ONOXMLElement *XML = [responseDocument.rootElement firstChildWithTag:_tag];
                details = [[_detailsClass alloc] initWithXML:XML];
                //新接口软件详情评论
                if([_tag isEqualToString:@"software"]) {
                    _softwareName = ((OSCSoftwareDetails*)details).title;
                }
            }
            
            [self performSelector:_loadMethod withObject:details];
            
            self.operationBar.isStarred = _isStarred;
            
            UIBarButtonItem *commentsCountButton = self.operationBar.items[4];
            commentsCountButton.shouldHideBadgeAtZero = YES;
            commentsCountButton.badgeValue = [NSString stringWithFormat:@"%i", _commentCount];
            commentsCountButton.badgePadding = 1;
            commentsCountButton.badgeBGColor = [UIColor colorWithHex:0x24a83d];
            
            if (_commentType == CommentTypeSoftware) {_objectID = ((OSCSoftwareDetails *)details).softwareID;}
            
            [self setBlockForOperationBar];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error:%@",error);
    }];
    
    
    //////////////////ONOXMLDocument///////////////////////
    /*
     [_manager GET:_detailsURL
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
     //              NSString *response = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
     
     //              ONOXMLDocument *test = [ONOXMLDocument XMLDocumentWithString:response encoding:NSUTF8StringEncoding error:nil];
     
     ONOXMLElement *XML = [responseDocument.rootElement firstChildWithTag:_tag];
     if (!XML || XML.children.count <= 0) {
     [self.navigationController popViewControllerAnimated:YES];
     } else {
     id details = [[_detailsClass alloc] initWithXML:XML];
     _commentCount = [[[XML firstChildWithTag:@"commentCount"] numberValue] intValue];
     
     //                  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%d条评论", _commentCount]
     //                                                                                            style:UIBarButtonItemStylePlain
     //                                                                                           target:self action:@selector(refresh)];
     
     [self performSelector:_loadMethod withObject:details];
     
     self.operationBar.isStarred = _isStarred;
     
     UIBarButtonItem *commentsCountButton = self.operationBar.items[4];
     commentsCountButton.shouldHideBadgeAtZero = YES;
     commentsCountButton.badgeValue = [NSString stringWithFormat:@"%i", _commentCount];
     commentsCountButton.badgePadding = 1;
     commentsCountButton.badgeBGColor = [UIColor colorWithHex:0x24a83d];
     
     if (_commentType == CommentTypeSoftware) {_objectID = ((OSCSoftwareDetails *)details).softwareID;}
     
     [self setBlockForOperationBar];
     }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     _HUD.mode = MBProgressHUDModeCustomView;
     _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
     _HUD.detailsLabel.text = error.userInfo[NSLocalizedDescriptionKey];
     
     [_HUD hideAnimated:YES afterDelay:1];
     }
     ];
     */
}

- (void)loadNewsDetails:(OSCNewsDetails *)newsDetails
{
    [self.detailsView loadHTMLString:newsDetails.html baseURL:[[NSBundle mainBundle] resourceURL]];
    
    _isStarred = newsDetails.isFavorite;
    
    _webURL = [newsDetails.url absoluteString];
    _objectTitle = newsDetails.title;
    _commentCount = newsDetails.commentCount;
    NSString *trimmedHTML = [newsDetails.body deleteHTMLTag];
    NSInteger length = trimmedHTML.length < 60 ? trimmedHTML.length : 60;
    _digest = [trimmedHTML substringToIndex:length];
}

- (void)loadBlogDetails:(OSCBlogDetails *)blogDetails
{
    [self.detailsView loadHTMLString:blogDetails.html baseURL:[[NSBundle mainBundle] resourceURL]];
    
    _isStarred = blogDetails.isFavorite;
    _webURL = [blogDetails.url absoluteString];
    _objectTitle = blogDetails.title;
    _commentCount = blogDetails.commentCount;
    NSString *trimmedHTML = [blogDetails.body deleteHTMLTag];
    NSInteger length = trimmedHTML.length < 60 ? trimmedHTML.length : 60;
    _digest = [trimmedHTML substringToIndex:length];
}

- (void)loadPostDetails:(OSCPostDetails *)postDetails
{
    [self.detailsView loadHTMLString:postDetails.html baseURL:[[NSBundle mainBundle] resourceURL]];
    
    _isStarred = postDetails.isFavorite;
    _webURL = [postDetails.url absoluteString];
    _commentCount = postDetails.answerCount;
    _objectTitle = postDetails.title;
    
    NSString *trimmedHTML = [postDetails.body deleteHTMLTag];
    NSInteger length = trimmedHTML.length < 60 ? trimmedHTML.length : 60;
    _digest = [trimmedHTML substringToIndex:length];
}

- (void)loadSoftwareDetails:(OSCSoftwareDetails *)softwareDetails
{
    [self.detailsView loadHTMLString:softwareDetails.html baseURL:[[NSBundle mainBundle] resourceURL]];
    
    _isStarred = softwareDetails.isFavorite;
    _webURL = [softwareDetails.url absoluteString];
    
    _commentCount = softwareDetails.tweetCount;
    _objectTitle = [NSString stringWithFormat:@"%@ %@", softwareDetails.extensionTitle, softwareDetails.title];
    
    NSString *trimmedHTML = [softwareDetails.body deleteHTMLTag];
    NSInteger length = trimmedHTML.length < 60 ? trimmedHTML.length : 60;
    _digest = [trimmedHTML substringToIndex:length];
}


#pragma mark - 发表评论

- (void)sendContent
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.label.text = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *URL;
    NSDictionary *parameters;
    NSString *content = [Utils convertRichTextToRawText:self.editingBar.editView];
    
    if (_commentType == CommentTypeSoftware) {
        URL = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_PUB];
        parameters = @{
                       @"uid": @([Config getOwnID]),
                       @"msg": [content stringByAppendingString:[NSString stringWithFormat:@" #%@#", _softwareName]]
                       };
    } else if (_commentType == CommentTypeBlog) {
        URL = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_BLOGCOMMENT_PUB];
        parameters = @{
                       @"blog": @(_objectID),
                       @"uid": @([Config getOwnID]),
                       @"content": content,
                       @"reply_id": @(0),
                       @"objuid": @(0)
                       };
    } else {
        URL = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_COMMENT_PUB];
        parameters = @{
                       @"catalog": @(_commentType),
                       @"id": @(_objectID),
                       @"uid": @([Config getOwnID]),
                       @"content": content,
                       @"isPostToMyZone": @(0)
                       };
    }
    
    [manager POST:URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
              ONOXMLElement *result = [responseDocument.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
              
              HUD.mode = MBProgressHUDModeCustomView;
              
              if (errorCode == 1) {
                  self.editingBar.editView.text = @"";
                  [self updateInputBarHeight];
                  
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.label.text = @"评论发表成功";
              } else {
//                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
              }
              
              [HUD hideAnimated:YES afterDelay:2];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              HUD.mode = MBProgressHUDModeCustomView;
//              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.label.text = @"网络异常，动弹发送失败";
              
              [HUD hideAnimated:YES afterDelay:2];
          }];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.editingBar.editView) {
        [self.editingBar.editView resignFirstResponder];
        [self hideEmojiPageView];
    }
}



#pragma mark - 浏览器链接处理

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL name:nil];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_HUD hideAnimated:YES];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        [manager POST:@"http://www.oschina.net/action/communityManage/report"
           parameters:@{
                        @"memo":        [alertView textFieldAtIndex:0].text.length == 0? @"其他原因": [alertView textFieldAtIndex:0].text,
                        @"obj_id":      @(_objectID),
                        @"obj_type":    @"2",
                        @"reason":      @"4",
                        @"url":         _webURL
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.label.text = @"举报成功";
                  
                  [HUD hideAnimated:YES afterDelay:1];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
//                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.label.text = @"网络异常，操作失败";
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    }
}





@end
