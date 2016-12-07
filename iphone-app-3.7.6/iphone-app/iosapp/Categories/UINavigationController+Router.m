//
//  UINavigationController+Router.m
//  iosapp
//
//  Created by AeternChan on 10/14/15.
//  Copyright © 2015 oschina. All rights reserved.
//

#import "UINavigationController+Router.h"

#import "OSCUserHomePageController.h"
#import "DetailsViewController.h"
#import "ImageViewerController.h"
#import "PostsViewController.h"
#import "TweetDetailsWithBottomBarViewController.h"
#import "TweetTableViewController.h"
#import "NewBlogDetailController.h"

#import "OSCNews.h"
#import "OSCPost.h"
#import "OSCTweet.h"
#import "SoftWareViewController.h"
#import "QuesAnsDetailViewController.h"
#import "OSCPhotoGroupView.h"
#import "UIDevice+SystemInfo.h"

#import "OSCInformationDetailController.h"

@import SafariServices ;



@implementation UINavigationController (Router)

- (void)handleURL:(NSURL *)url
             name:(NSString* )name
{
    NSString *urlString = url.absoluteString;
    
    //判断是否包含 oschina.net 来确定是不是站内链接
    NSRange range = [urlString rangeOfString:@"oschina.net"];
    if (range.length <= 0) {
		//TODO: 替换合适的webviewcontroller
        if ( [url.absoluteString hasPrefix:@"http"]) {
            SFSafariViewController *webviewController = [[SFSafariViewController alloc] initWithURL:url];
            webviewController.hidesBottomBarWhenPushed = YES;
            [self pushViewController:webviewController animated:YES];
        }else{
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        //站内链接
        if ([url.absoluteString hasPrefix:@"https"]) {
            urlString = [urlString substringFromIndex:8];
        }else{
            urlString = [urlString substringFromIndex:7];
        }
        NSArray *pathComponents = [urlString pathComponents];
        NSString *prefix = [pathComponents[0] componentsSeparatedByString:@"."][0];
        UIViewController *viewController;
        
        if ([prefix isEqualToString:@"my"]) {
            if (pathComponents.count == 2) {
                if (name != nil) {
                    viewController = [[OSCUserHomePageController alloc] initWithUserName:name];
                    viewController.navigationItem.title = @"用户详情";
                }else{
                    // 个人专页 my.oschina.net/dong706
                    viewController = [[OSCUserHomePageController alloc] initWithUserHisName:pathComponents[1]];
                    viewController.navigationItem.title = @"用户详情";
                }
            } else if (pathComponents.count == 3) {
                if (name != nil) {
                    viewController = [[OSCUserHomePageController alloc] initWithUserName:name];
                    viewController.navigationItem.title = @"用户详情";
                }else{
                    // 个人专页 my.oschina.net/u/12
                    if ([pathComponents[1] isEqualToString:@"u"]) {
                        viewController= [[OSCUserHomePageController alloc] initWithUserID:[pathComponents[2] longLongValue]];
                        viewController.navigationItem.title = @"用户详情";
                    }
                }
            } else if (pathComponents.count == 4) {
                NSString *type = pathComponents[2];
                if ([type isEqualToString:@"blog"]) {
                    NSInteger blogId = [pathComponents[3] integerValue];
                    if(blogId > 0) {
//                        viewController = [[NewsBlogDetailTableViewController alloc]initWithObjectId:blogId isBlogDetail:YES];
//                        viewController.hidesBottomBarWhenPushed = YES;
                        
                        viewController = [[NewBlogDetailController alloc] initWithBlogId:blogId];
                        viewController.hidesBottomBarWhenPushed = YES;
                    }
 
                } else if ([type isEqualToString:@"tweet"]){
                    OSCTweet *tweet = [OSCTweet new];
                    tweet.tweetID = [pathComponents[3] longLongValue];
                    viewController = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:tweet.tweetID];
                    viewController.navigationItem.title = @"动弹详情";
                }
            } else if(pathComponents.count == 5) {
                NSString *type = pathComponents[3];
                if ([type isEqualToString:@"blog"]) {
                    NSInteger blogId = [pathComponents[4] integerValue];
                    if(blogId > 0) {
//                        viewController = [[NewsBlogDetailTableViewController alloc]initWithObjectId:blogId isBlogDetail:YES];
                        
                        viewController = [[NewBlogDetailController alloc] initWithBlogId:blogId];
                        viewController.hidesBottomBarWhenPushed = YES;
                    }
				}else if ([type isEqualToString:@"tweet"]){
					OSCTweet *tweet = [OSCTweet new];
					tweet.tweetID = [pathComponents[4] longLongValue];
					viewController = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:tweet.tweetID];
					viewController.navigationItem.title = @"动弹详情";
				}
            }
        } else if ([prefix isEqualToString:@"www"] || [prefix isEqualToString:@"m"]) {
            //新闻,软件,问答
            NSArray *urlComponents = [urlString componentsSeparatedByString:@"/"];
            NSUInteger count = urlComponents.count;
            if (count >= 3) {
                NSString *type = urlComponents[1];
                if ([type isEqualToString:@"news"]) {
                    // 新闻
                    // www.oschina.net/news/27259/mobile-internet-market-is-small
                    int64_t newsID = [urlComponents[2] longLongValue];
                    //新版资讯界面
                    viewController =[[OSCInformationDetailController alloc] initWithInformationID:newsID];
                    viewController.hidesBottomBarWhenPushed = YES;
                    
                } else if ([type isEqualToString:@"p"]) {
                    // 软件 www.oschina.net/p/jx
                    OSCNews *news = [OSCNews new];
                    news.type = NewsTypeSoftWare;
                    news.attachment = urlComponents[2];
					
					viewController = [[SoftWareViewController alloc] initWithSoftWareIdentity:news.attachment];
					viewController.hidesBottomBarWhenPushed = YES;
                    viewController.navigationItem.title = @"软件详情";
					
                } else if ([type isEqualToString:@"question"]) {
                    // 问答
                    
                    if (count == 3) {
                        // 问答 www.oschina.net/question/12_45738
                        NSArray *IDs = [urlComponents[2] componentsSeparatedByString:@"_"];
                        if ([IDs count] >= 2) {
                            OSCPost *post = [OSCPost new];
                            post.postID = [IDs[1] longLongValue];
							
							QuesAnsDetailViewController *questionViewController = [[QuesAnsDetailViewController alloc] init];
							questionViewController.questionID = post.postID;
							viewController = questionViewController;
							viewController.hidesBottomBarWhenPushed = YES;
							viewController.navigationItem.title = @"帖子详情";
                        }
                    } else if (count >= 4) {
                        // 问答-标签 www.oschina.net/question/tag/python
                        NSString *tag = urlComponents.lastObject;
                        
                        viewController = [PostsViewController new];
                        ((PostsViewController *)viewController).generateURL = ^NSString * (NSUInteger page) {
                            return [NSString stringWithFormat:@"%@%@?tag=%@&pageIndex=0&%@", OSCAPI_PREFIX, OSCAPI_POSTS_LIST, tag, OSCAPI_SUFFIX];
                        };
                        
                        ((PostsViewController *)viewController).objClass = [OSCPost class];
                        viewController.navigationItem.title = [tag stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                } else if ([type isEqualToString:@"tweet-topic"]) {
                    //话题
                    urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    urlComponents = [urlString componentsSeparatedByString:@"/"];
                    viewController = [[TweetTableViewController alloc] initTweetListWithTopic:urlComponents[2]];
                    viewController.title = [NSString stringWithFormat:@"#%@#", urlComponents[2]];
                    viewController.hidesBottomBarWhenPushed = YES;
                }
            }
        } else if ([prefix isEqualToString:@"static"]) {
            ImageViewerController *imageViewerVC = [[ImageViewerController alloc] initWithImageURL:url];
            [self presentViewController:imageViewerVC animated:YES completion:nil];
            return;
		}
		
        if (viewController) {
            [self pushViewController:viewController animated:YES];
        } else {
			SFSafariViewController *webviewController = [[SFSafariViewController alloc] initWithURL:url];
            webviewController.hidesBottomBarWhenPushed = YES;
			[self pushViewController:webviewController animated:YES];
        }
    }
}


@end
