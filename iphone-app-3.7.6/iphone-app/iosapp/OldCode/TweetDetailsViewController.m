//
//  TweetDetailsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "TweetDetailsViewController.h"
#import "OSCTweet.h"
#import "TweetCell.h"
#import "OSCUserHomePageController.h"
#import "ImageViewerController.h"
#import "TweetDetailsCell.h"
#import "OSCUserHomePageController.h"
#import "Config.h"
#import "TweetsLikeListViewController.h"
#import "OSCUser.h"
#import "NSString+FontAwesome.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>


@interface TweetDetailsViewController () <UIWebViewDelegate>

@property (nonatomic, strong) OSCTweet *tweet;
@property (nonatomic, assign) int64_t tweetID;

@property (nonatomic, assign) CGFloat webViewHeight;

@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation TweetDetailsViewController

- (instancetype)initWithTweetID:(int64_t)tweetID
{
    self = [super initWithCommentType:CommentTypeTweet andObjectID:tweetID];
    
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _tweetID = tweetID;
    }
    
    return self;
}


- (void)viewDidLoad {
    self.needRefreshAnimation = NO;
    [super viewDidLoad];
    
    _HUD = [Utils createHUD];
    _HUD.userInteractionEnabled = NO;
    _HUD.dimBackground = YES;
    
    [self getTweetDetails];
}

- (void)getTweetDetails
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//    manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    [manager GET:[NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_TWEET_DETAIL, _tweetID]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             ONOXMLElement *tweetDetailsXML = [responseObject.rootElement firstChildWithTag:@"tweet"];
             
             if (!tweetDetailsXML || tweetDetailsXML.children.count <= 0) {
                 [self.navigationController popViewControllerAnimated:YES];
             } else {
                 _tweet = [[OSCTweet alloc] initWithXML:tweetDetailsXML];
                 self.objectAuthorID = _tweet.authorID;
                 
                 NSDictionary *data = @{
                                        @"content": _tweet.body,
                                        @"imageURL": _tweet.bigImgURL.absoluteString,
                                        @"audioURL": _tweet.attach ?: @"",
                                        };
                 
                 _tweet.body = [Utils HTMLWithData:data usingTemplate:@"tweet"];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [_HUD hideAnimated:YES];
         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_HUD hideAnimated:YES];
    [super viewWillDisappear:animated];
}





#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0? 0 : 35;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        NSString *title;
        if (self.allCount) {
            title = [NSString stringWithFormat:@"%d 条评论", self.allCount];
        } else {
            title = @"没有评论";
        }
        return title;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.label setAttributedText:_tweet.likersDetailString];
        self.label.font = [UIFont systemFontOfSize:12];
        CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)].height + 5;
        
        height += _webViewHeight;
        
        return height + 63;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TweetDetailsCell *cell = [TweetDetailsCell new];
        
        if (_tweet) {
            [cell.portrait loadPortrait:_tweet.portraitURL];
            [cell.authorLabel setText:_tweet.author];
            
            [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushUserDetails)]];
            [cell.likeButton addTarget:self action:@selector(togglePraise) forControlEvents:UIControlEventTouchUpInside];
            [cell.likeListLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(PushToLikeList)]];
            
            [cell.likeListLabel setAttributedText:_tweet.likersDetailString];
            cell.likeListLabel.hidden = !_tweet.likeList.count;
            [cell.timeLabel setAttributedText:[Utils attributedTimeString:_tweet.pubDate]];
            if (_tweet.isLike) {
                [cell.likeButton setTitle:[NSString fontAwesomeIconStringForEnum:FAThumbsUp] forState:UIControlStateNormal];
                [cell.likeButton setTitleColor:[UIColor nameColor] forState:UIControlStateNormal];
            } else {
                [cell.likeButton setTitle:[NSString fontAwesomeIconStringForEnum:FAThumbsOUp] forState:UIControlStateNormal];
                [cell.likeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
            [cell.appclientLabel setAttributedText:[Utils getAppclient:_tweet.appclient]];
            cell.webView.delegate = self;
            [cell.webView loadHTMLString:_tweet.body baseURL:[NSBundle mainBundle].resourceURL];
        }
        
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section != 0;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return indexPath.section != 0;
}


#pragma mark - 头像点击事件处理

- (void)pushUserDetails
{
    [self.navigationController pushViewController:[[OSCUserHomePageController alloc] initWithUserID:_tweet.authorID] animated:YES];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    if (_webViewHeight == webViewHeight) {return;}
    
    _webViewHeight = webViewHeight;
    [_HUD hideAnimated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL name:nil];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}

#pragma mark - 跳转到点赞列表

- (void)PushToLikeList
{
    TweetsLikeListViewController *likeListCtl = [[TweetsLikeListViewController alloc] initWithtweetID:_tweet.tweetID];
    [self.navigationController pushViewController:likeListCtl animated:YES];
}

#pragma mark - 点赞功能
- (void)togglePraise
{
    [self toPraise:_tweet];
}

- (void)toPraise:(OSCTweet *)tweet
{
    NSString *postUrl;
    if (tweet.isLike) {
        postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_UNLIKE];
    } else {
        postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_TWEET_LIKE];
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:postUrl
       parameters:@{
                    @"uid": @([Config getOwnID]),
                    @"tweetid": @(tweet.tweetID),
                    @"ownerOfTweet": @(tweet.authorID)
                    }
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *resultXML = [responseObject.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[resultXML firstChildWithTag: @"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[resultXML firstChildWithTag:@"errorMessage"] stringValue];
              
              if (errorCode == 1) {
                  if (tweet.isLike) {
                      //取消点赞
                      for (OSCUser *user in tweet.likeList) {
                          if ([user.name isEqualToString:[Config getOwnUserName]]) {
                              [tweet.likeList removeObject:user];
                              break;
                          }
                      }
                      tweet.likeCount--;
                  } else {
                      //点赞
                      OSCUser *user = [OSCUser new];
                      user.userID = [Config getOwnID];
                      user.name = [Config getOwnUserName];
                      user.portraitURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Config getPortrait]]];
                      [tweet.likeList insertObject:user atIndex:0];
                      tweet.likeCount++;
                  }
                  tweet.isLike = !tweet.isLike;
                  tweet.likersDetailString = nil;
                  
                  [self.tableView beginUpdates];
                  [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                  [self.tableView endUpdates];
              } else {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.detailsLabel.text = error.userInfo[NSLocalizedDescriptionKey];
              
              [HUD hideAnimated:YES afterDelay:1];
          }];
}




@end
