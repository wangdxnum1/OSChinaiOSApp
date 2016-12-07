//
//  DiscussionDetailsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 4/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "DiscussionDetailsViewController.h"
#import "Utils.h"
#import "Config.h"
#import "TeamAPI.h"
#import "TeamDiscussionDetails.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

@interface DiscussionDetailsViewController () <UIWebViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) int teamID;
@property (nonatomic, assign) int discussionID;
@property (nonatomic, strong) TeamDiscussionDetails *discussionDetails;
@property (nonatomic, copy) NSString *HTML;
@property (nonatomic, assign) CGFloat webViewHeight;

@end

@implementation DiscussionDetailsViewController

- (instancetype)initWithDiscussionID:(int)discussionID
{
    self = [super initWithObjectID:discussionID andType:TeamReplyTypeDiscuss];
    if (self) {
        _discussionID = discussionID;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"帖子详情";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_DISCUSS_DETAIL]
      parameters:@{
                   @"teamid":@([Config teamID]),
                   @"discussid": @(_discussionID)
                   }
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             _discussionDetails = [[TeamDiscussionDetails alloc] initWithXML:[responseObject.rootElement firstChildWithTag:@"discuss"]];
             
             NSDictionary *data = @{
                                    @"title" : _discussionDetails.title,
                                    @"authorID" : @(_discussionDetails.author.memberID),
                                    @"authorName" : _discussionDetails.author.name,
                                    @"timeInterval" : [_discussionDetails.createTime timeAgoSinceNow],
                                    @"content" : _discussionDetails.body,
                                    };
             
             _HTML = [Utils HTMLWithData:data usingTemplate:@"article"];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - tableview datasource and delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return _webViewHeight + 15;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        return [super tableView:tableView titleForHeaderInSection:section];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [UITableViewCell new];
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        cell.backgroundColor = [UIColor themeColor];
        
        UIWebView *webView = [UIWebView new];
        webView.scrollView.bounces = NO;
        webView.scrollView.scrollEnabled = NO;
        webView.opaque = NO;
        webView.backgroundColor = [UIColor themeColor];
        [cell.contentView addSubview:webView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(webView);
        webView.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:views]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[webView]|" options:0 metrics:nil views:views]];
        
        webView.delegate = self;
        [webView loadHTMLString:_HTML baseURL:[NSBundle mainBundle].resourceURL];
        
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    if (_webViewHeight == webViewHeight) {return;}
    
    _webViewHeight = webViewHeight;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark - 发表评论

- (void)sendContent
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.label.text = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_DISCUSS_REPLY]
       parameters:@{
                    @"uid": @([Config getOwnID]),
                    @"teamid": @(_teamID),
                    @"discussid": @(_discussionID),
                    @"content": [Utils convertRichTextToRawText:self.editingBar.editView]
                    }
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
              
              HUD.mode = MBProgressHUDModeCustomView;
              
              if (errorCode == 1) {
                  self.editingBar.editView.text = @"";
                  [self updateInputBarHeight];
                  
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.label.text = @"评论发表成功";
                  
                  [self.tableView setContentOffset:CGPointZero animated:NO];
                  [self fetchRepliesOnPage:0];
              } else {
//                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
              }
              
              [HUD hideAnimated:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              HUD.mode = MBProgressHUDModeCustomView;
//              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.detailsLabel.text = error.localizedFailureReason;
              
              [HUD hideAnimated:YES afterDelay:1];
          }];
}


@end
