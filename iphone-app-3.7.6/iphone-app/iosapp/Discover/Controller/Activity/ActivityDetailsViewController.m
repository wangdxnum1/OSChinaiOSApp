//
//  ActivityDetailsViewController.m
//  iosapp
//
//  Created by ChanAetern on 1/26/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ActivityDetailsViewController.h"
#import "OSCActivity.h"
#import "ActivityBasicInfoCell.h"
#import "ActivityDetailsCell.h"
#import "OSCAPI.h"
#import "OSCPostDetails.h"
#import "Utils.h"
#import "Config.h"
#import "ActivityDetailsWithBarViewController.h"
#import "UIBarButtonItem+Badge.h"
#import "PresentMembersViewController.h"
#import "ActivitySignUpViewController.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>
#import <GRMustache.h>


@interface ActivityDetailsViewController () <UIWebViewDelegate>

@property (nonatomic, readonly, strong) OSCActivity *activity;
@property (nonatomic, readonly, assign) int64_t     activityID;

@property (nonatomic, copy)   NSString *HTML;
@property (nonatomic, assign) BOOL      isLoadingFinished;
@property (nonatomic, assign) CGFloat   webViewHeight;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property NSDateFormatter *formatter;

@end

@implementation ActivityDetailsViewController

- (instancetype)initWithActivityID:(int64_t)activityID
{
    self = [super init];
    if (self) {
        _activityID = activityID;
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"活动详情";
    self.view.backgroundColor = [UIColor themeColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _HUD = [Utils createHUD];
    _HUD.userInteractionEnabled = NO;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];

    [manager GET:[NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_POST_DETAIL, _activityID]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             ONOXMLElement *postXML = [responseObject.rootElement firstChildWithTag:@"post"];
             _postDetails = [[OSCPostDetails alloc] initWithXML:postXML];
             _activity = [[OSCActivity alloc] initWithXML:[postXML firstChildWithTag:@"event"]];
             
             _HTML = [Utils HTMLWithData:@{
                                           @"content": _postDetails.body,
                                           @"night": @([Config getMode]),
                                           }
                           usingTemplate:@"activity"];
             
             UIBarButtonItem *commentsCountButton = _bottomBarVC.operationBar.items[4];
             commentsCountButton.shouldHideBadgeAtZero = YES;
             commentsCountButton.badgeValue = [NSString stringWithFormat:@"%i", _postDetails.answerCount];
             commentsCountButton.badgePadding = 1;
             commentsCountButton.badgeBGColor = [UIColor colorWithHex:0x24a83d];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             _HUD.mode = MBProgressHUDModeCustomView;
//             _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             _HUD.label.text = @"网络异常，加载失败";
             
             [_HUD hideAnimated:YES afterDelay:1];
         }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_HUD hideAnimated:YES];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _postDetails? 2 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            UILabel *label = [UILabel new];
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            CGFloat width = tableView.frame.size.width - 16;
            
            label.font = [UIFont boldSystemFontOfSize:16];
            label.text = _activity.title;
            CGFloat height = [label sizeThatFits:CGSizeMake(width, MAXFLOAT)].height;
            
            label.font = [UIFont systemFontOfSize:13];
            label.text = [NSString stringWithFormat:@"开始：%@\n结束：%@",[self.formatter stringFromDate:_activity.startTime], [self.formatter stringFromDate:_activity.endTime]];
            height += [label sizeThatFits:CGSizeMake(width, MAXFLOAT)].height;
            
            label.text = _activity.location;
            height += [label sizeThatFits:CGSizeMake(width, MAXFLOAT)].height;
            
            return height + 95;
        }
        case 1:
            return _isLoadingFinished? _webViewHeight + 30 : 400;
        default:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            ActivityBasicInfoCell *cell = [ActivityBasicInfoCell new];
            cell.titleLabel.text = _activity.title;
            cell.titleLabel.textColor = [UIColor titleColor];
            cell.timeLabel.text = [NSString stringWithFormat:@"开始：%@\n结束：%@", [self.formatter stringFromDate:_activity.startTime], [self.formatter stringFromDate:_activity.endTime]];
            cell.locationLabel.text = [NSString stringWithFormat:@"地点：%@ %@", _activity.city, _activity.location];
            
            if (_postDetails.applyStatus == 0) {
                [cell.applicationButton setTitle:@"审核中" forState:UIControlStateNormal];
                
            } else if (_postDetails.applyStatus == 1) {
                [cell.applicationButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [cell.applicationButton setTitle:@"你的报名已确认，现场可以扫描二维码签到！" forState:UIControlStateNormal];
                cell.applicationButton.titleLabel.font = [UIFont systemFontOfSize:14];
                [cell.applicationButton setBackgroundColor:[UIColor clearColor]];
            } else {
                if (_postDetails.applyStatus == 2) {
                    [cell.applicationButton setTitle:@"出席人员" forState:UIControlStateNormal];
                }
                if (_postDetails.category == 4) {
                    [cell.applicationButton setTitle:@"报名链接" forState:UIControlStateNormal];
                }
                [cell.applicationButton addTarget:self action:@selector(enrollActivity) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        }
        case 1: {
            ActivityDetailsCell *cell = [ActivityDetailsCell new];
            cell.webView.delegate = self;
            [cell.webView loadHTMLString:_HTML baseURL:[NSBundle mainBundle].resourceURL];
            
            return cell;
        }
        default:
            return nil;
    }
}

//, postDetails.status, postDetails.applyStatus
#pragma mark - 报名

- (void)enrollActivity
{
    if (_postDetails.category == 4) {
        [[UIApplication sharedApplication] openURL:_postDetails.signUpUrl];
    } else {
        if (_postDetails.applyStatus == 2) {
            PresentMembersViewController *presentMembersViewController = [[PresentMembersViewController alloc] initWithEventID:_postDetails.postID];
            [self.navigationController pushViewController:presentMembersViewController animated:YES];
        } else {
            ActivitySignUpViewController *signUpViewController = [ActivitySignUpViewController new];
            signUpViewController.eventId = _postDetails.postID;
            signUpViewController.remarkTipStr = _activity.remarkTip;
            signUpViewController.remarkCitys = _activity.remarkCitys;
            [self.navigationController pushViewController:signUpViewController animated:YES];
        }
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_HTML == nil) {return;}
    if (_isLoadingFinished) {
        webView.hidden = NO;
        [_HUD hideAnimated:YES];
        return;
    }
    
    _webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    _isLoadingFinished = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.bottomBarVC.navigationController handleURL:request.URL name:nil];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_bottomBarVC.didScroll) {
        _bottomBarVC.didScroll();
    }
}





@end
