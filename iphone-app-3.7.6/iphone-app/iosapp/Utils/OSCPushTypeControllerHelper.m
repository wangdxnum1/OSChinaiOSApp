//
//  OSCPushTypeControllerHelper.m
//  iosapp
//
//  Created by Graphic-one on 16/8/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPushTypeControllerHelper.h"
#import "OSCMessageCenter.h"
#import "OSCNewHotBlog.h"
#import "OSCDiscuss.h"
#import "OSCRandomMessage.h"
#import "OSCSearchItem.h"
#import "OSCListItem.h"
#import "OSCUserHomePageController.h"
#import "OSCInformationDetailController.h"
#import "NewBlogDetailController.h"
#import "Utils.h"

#import "SoftWareViewController.h"
#import "QuesAnsDetailViewController.h"
#import "OSCInformationDetailController.h"
#import "TranslationViewController.h"
#import "ActivityDetailViewController.h"
#import "TweetDetailsWithBottomBarViewController.h"
#import <MBProgressHUD.h>

@implementation OSCPushTypeControllerHelper

/**
 OSCDiscusOriginTypeLineNews = 0,       //链接新闻
 OSCDiscusOriginTypeSoftWare = 1,       //软件推荐
 OSCDiscusOriginTypeForum = 2,          //讨论区帖子（问答）
 OSCDiscusOriginTypeBlog = 3,           //博客
 OSCDiscusOriginTypeTranslation = 4,    //翻译文章
 OSCDiscusOriginTypeActivity = 5,       //活动类型
 OSCDiscusOriginTypeInfo = 6,           //资讯类型
 OSCDiscusOriginTypeTweet = 100         //动弹（评论）类型
 */
+ (UIViewController *)pushControllerWithDiscussOriginType:(OSCDiscussOrigin *)discussOrigin{
    switch (discussOrigin.type) {
        case OSCDiscusOriginTypeLineNews:{
            return nil;
            break;
        }
        case OSCDiscusOriginTypeSoftWare:{
            SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:discussOrigin.id];
            [detailsViewController setHidesBottomBarWhenPushed:YES];
            return detailsViewController;
            break;
        }
        case OSCDiscusOriginTypeForum:{
            QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.questionID = discussOrigin.id;
            return detailVC;
            break;
        }
        case OSCDiscusOriginTypeBlog:{
            NewBlogDetailController* blogDetailVC = [[NewBlogDetailController alloc] initWithBlogId:discussOrigin.id];
            blogDetailVC.hidesBottomBarWhenPushed = YES;
            return blogDetailVC;
            break;
        }
        case OSCDiscusOriginTypeTranslation:{
            TranslationViewController *translationVc = [TranslationViewController new];
            translationVc.hidesBottomBarWhenPushed = YES;
            translationVc.translationId = discussOrigin.id;
            return translationVc;
            break;
        }
        case OSCDiscusOriginTypeActivity:{
            ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:discussOrigin.id];
            activityDetailCtl.hidesBottomBarWhenPushed = YES;
            return activityDetailCtl;
            break;
        }
        case OSCDiscusOriginTypeInfo:{
            OSCInformationDetailController* informationDetailController = [[OSCInformationDetailController alloc] initWithInformationID:discussOrigin.id];
            informationDetailController.hidesBottomBarWhenPushed = YES;
            return informationDetailController;
            break;
        }
        case OSCDiscusOriginTypeTweet:{
            TweetDetailsWithBottomBarViewController *tweetDetailsBVC = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:discussOrigin.id];
            return tweetDetailsBVC;
            break;
        }
            
            
        default:
            return nil;
            break;
    }
}



/**
 OSCRandomMessageTypeLinkNews = 0 ,    //链接新闻
 OSCRandomMessageTypeSoftware ,        //软件推荐
 OSCRandomMessageTypeDiscuss ,         //讨论区帖子
 OSCRandomMessageTypeBlog ,            //博客
 OSCRandomMessageTypeTranslation ,     //翻译文章
 OSCRandomMessageTypeActivity ,        //活动类型
 OSCRandomMessageTypeNew               //资讯类型
 */

+ (UIViewController *)pushControllerWithRandomNewsType:(OSCRandomMessageItem *)randomMessageItem{
    switch (randomMessageItem.type) {
        case OSCRandomMessageTypeLinkNews:{
            return nil;
            break;
        }
            
        case OSCRandomMessageTypeSoftware:{
            SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:randomMessageItem.id];
            [detailsViewController setHidesBottomBarWhenPushed:YES];
            return detailsViewController;
            break;
        }
            
        case OSCRandomMessageTypeDiscuss:{
            QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.questionID = randomMessageItem.id;
            return detailVC;
            break;
        }
            
        case OSCRandomMessageTypeBlog:{
            NewBlogDetailController* blogDetailVC = [[NewBlogDetailController alloc] initWithBlogId:randomMessageItem.id];
            blogDetailVC.hidesBottomBarWhenPushed = YES;
            return blogDetailVC;
            break;
        }
            
        case OSCRandomMessageTypeTranslation:{
            TranslationViewController *translationVc = [TranslationViewController new];
            translationVc.hidesBottomBarWhenPushed = YES;
            translationVc.translationId = randomMessageItem.id;
            return translationVc;
            break;
        }
            
        case OSCRandomMessageTypeActivity:{
            ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:randomMessageItem.id];
            activityDetailCtl.hidesBottomBarWhenPushed = YES;
            return activityDetailCtl;
            break;
        }
            
        case OSCRandomMessageTypeNew:{
            OSCInformationDetailController* informationDetailController = [[OSCInformationDetailController alloc] initWithInformationID:randomMessageItem.id];
            informationDetailController.hidesBottomBarWhenPushed = YES;
            return informationDetailController;
            break;
        }
            
        default:{
            return nil;
            break;
        }
    }
}


/**
InformationTypeLinkNews = 0,//链接新闻
InformationTypeSoftWare = 1,//软件推荐
InformationTypeForum = 2,//讨论区帖子（问答）
InformationTypeBlog = 3,//博客
InformationTypeTranslation = 4,//翻译文章
InformationTypeActivity = 5,//活动类型
InformationTypeInfo = 6,//资讯

InformationTypeUserCenter = 11,//用户中心
*/
+ (UIViewController *)pushControllerWithSearchItem:(__kindof OSCSearchModel* )searchModel{
    if ([searchModel isKindOfClass:[OSCSearchItem class]]) {
        OSCSearchItem *model = (OSCSearchItem *)searchModel;
        switch (model.type) {
            case InformationTypeBlog:{
                NewBlogDetailController* blogDetailVC = [[NewBlogDetailController alloc] initWithBlogId:model.id];
                blogDetailVC.hidesBottomBarWhenPushed = YES;
                return blogDetailVC;
                break;
            }
            case InformationTypeSoftWare:{
                SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:model.id];
                [detailsViewController setHidesBottomBarWhenPushed:YES];
                return detailsViewController;
                break;
            }
            case InformationTypeInfo:{
                OSCInformationDetailController* informationDetailController = [[OSCInformationDetailController alloc] initWithInformationID:model.id];
                informationDetailController.hidesBottomBarWhenPushed = YES;
                return informationDetailController;
                break;
            }
            case InformationTypeForum:{
                QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
                detailVC.hidesBottomBarWhenPushed = YES;
                detailVC.questionID = model.id;
                return detailVC;
                break;
            }
            default:
                return nil;
                break;
        }
    }
    
    else if ([searchModel isKindOfClass:[OSCSearchPeopleItem class]]){
        OSCSearchPeopleItem *model = (OSCSearchPeopleItem *)searchModel;
        if (model.id > 0) {
            OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:model.id];
            return userDetailsVC;
        } else {
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.label.text = @"该用户不存在";
            
            [HUD hideAnimated:YES afterDelay:1];
            return nil;
        }
    }
    
    else{
        return nil;
    }
}



/**
 InformationTypeLinkNews,//链接新闻
 InformationTypeSoftWare,//软件推荐
 InformationTypeForum,//讨论区帖子（问答）
 InformationTypeBlog,//博客
 InformationTypeTranslation,//翻译文章
 InformationTypeActivity,//活动类型
 InformationTypeInfo//资讯
 */
+ (UIViewController *)pushControllerWithListItem:(OSCListItem *)listItem{
    switch (listItem.type) {
        case InformationTypeLinkNews:{
            return nil;
            break;
        }
            
        case InformationTypeSoftWare:{
            SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:listItem.id];
            [detailsViewController setHidesBottomBarWhenPushed:YES];
            return detailsViewController;
            break;
        }
            
        case InformationTypeForum:{
            QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.questionID = listItem.id;
            return detailVC;
            break;
        }
            
        case InformationTypeBlog:{
            NewBlogDetailController* blogDetailVC = [[NewBlogDetailController alloc] initWithBlogId:listItem.id];
            blogDetailVC.hidesBottomBarWhenPushed = YES;
            return blogDetailVC;
            break;
        }
            
        case InformationTypeTranslation:{
            TranslationViewController *translationVc = [TranslationViewController new];
            translationVc.hidesBottomBarWhenPushed = YES;
            translationVc.translationId = listItem.id;
            return translationVc;
            break;
        }
            
        case InformationTypeActivity:{
            ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:listItem.id];
            activityDetailCtl.hidesBottomBarWhenPushed = YES;
            return activityDetailCtl;
            break;
        }
            
        case InformationTypeInfo:{
            OSCInformationDetailController* informationDetailController = [[OSCInformationDetailController alloc] initWithInformationID:listItem.id];
            informationDetailController.hidesBottomBarWhenPushed = YES;
            return informationDetailController;
            break;
        }
            
        default:{
            return nil;
            break;
        }
    }
}



/**
 InformationTypeLinkNews,//链接新闻
 InformationTypeSoftWare,//软件推荐
 InformationTypeForum,//讨论区帖子（问答）
 InformationTypeBlog,//博客
 InformationTypeTranslation,//翻译文章
 InformationTypeActivity,//活动类型
 InformationTypeInfo//资讯
 InformationTypeTweet//动弹（评论）类型
 */
+ (UIViewController* )pushControllerGeneralWithType:(InformationType)type
                                    detailContentID:(NSInteger)id
{
    if(id == NSNotFound) { return  nil;}
    
    switch (type) {
        case InformationTypeLinkNews:{
            return nil;
            break;
        }
            
        case InformationTypeSoftWare:{
            SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:id];
            [detailsViewController setHidesBottomBarWhenPushed:YES];
            return detailsViewController;
            break;
        }
            
        case InformationTypeForum:{
            QuesAnsDetailViewController *detailVC = [QuesAnsDetailViewController new];
            detailVC.hidesBottomBarWhenPushed = YES;
            detailVC.questionID = id;
            return detailVC;
            break;
        }
            
        case InformationTypeBlog:{
            NewBlogDetailController* blogDetailVC = [[NewBlogDetailController alloc] initWithBlogId:id];
            blogDetailVC.hidesBottomBarWhenPushed = YES;
            return blogDetailVC;
            break;
        }
            
        case InformationTypeTranslation:{
            TranslationViewController *translationVc = [TranslationViewController new];
            translationVc.hidesBottomBarWhenPushed = YES;
            translationVc.translationId = id;
            return translationVc;
            break;
        }
            
        case InformationTypeActivity:{
            ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:id];
            activityDetailCtl.hidesBottomBarWhenPushed = YES;
            return activityDetailCtl;
            break;
        }
            
        case InformationTypeInfo:{
            OSCInformationDetailController* informationDetailController = [[OSCInformationDetailController alloc]initWithInformationID:id];
            informationDetailController.hidesBottomBarWhenPushed = YES;
            return informationDetailController;
            break;
        }
            
        case InformationTypeTweet:{
            TweetDetailsWithBottomBarViewController *tweetDetailsBVC = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:id];
            return tweetDetailsBVC;
            break;
        }
            
        default:{
            return nil;
            break;
        }
    }
}

@end








