//
//  OSCAPI.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#ifndef iosapp_OSCAPI_h
#define iosapp_OSCAPI_h

#define OSCAPI_HTTPS_PREFIX                 @"https://www.oschina.net/action/api/"
#define OSCAPI_PREFIX                       OSCAPI_HTTPS_PREFIX
#define OSCAPI_V2_HTTPS_PREFIX              @"https://www.oschina.net/action/apiv2/"
#define OSCAPI_V2_PREFIX                    OSCAPI_V2_HTTPS_PREFIX

//#define OSCAPI_HTTPS_PREFIX                 @"http://192.168.1.10:8000/action/api/"
//#define OSCAPI_PREFIX                       OSCAPI_HTTPS_PREFIX
//#define OSCAPI_V2_HTTPS_PREFIX              @"http://192.168.1.10:8000/action/apiv2/"
//#define OSCAPI_V2_PREFIX                    @"http://192.168.1.10:8000/action/apiv2/"

#define OSCAPI_SUFFIX                   @"pageSize=20"

#define OSCAPI_NEWS_LIST                @"news_list"
#define OSCAPI_NEWS_DETAIL              @"news_detail"

//#define OSCAPI_BLOGS_LIST               @"blog_list"
#define OSCAPI_BLOGS_LIST               @"blog"

#define OSCAPI_POSTS_LIST               @"post_list"
#define OSCAPI_POST_DETAIL              @"post_detail"
#define OSCAPI_POST_PUB                 @"post_pub"

#define OSCAPI_TWEETS_LIST              @"tweet_list"
#define OSCAPI_TWEETS                   @"tweets"
#define OSCAPI_TWEETS_TOPIC             @"tweet_topic"
#define OSCAPI_TWEET_DETAIL             @"tweet_detail"
#define OSCAPI_TWEET_DELETE             @"tweet_delete"
#define OSCAPI_TWEET_PUB                @"tweet_pub"
#define OSCAPI_TWEET_LIKE               @"tweet_like"
#define OSCAPI_TWEET_UNLIKE             @"tweet_unlike"
#define OSCAPI_TWEET_LIKE_REVERSE       @"tweet_like_reverse"

#define OSCAPI_TWEET_LIKE_LIST          @"tweet_like_list"
#define OSCAPI_MY_TWEET_LIKE_LIST       @"my_tweet_like_list"
#define OSCAPI_SOFTWARE_TWEET_PUB       @"software_tweet_pub"
#define OSCAPI_TWEET_TOPIC_LIST         @"tweet_topic_list"
//新动弹接口
#define OSCAPI_TWEET_LIKES              @"tweet_likes"      //点赞列表
#define OSCAPI_TWEET_COMMENTS           @"tweet_comments"   //评论列表

#define OSCAPI_INFORMATION_SUB_ENUM     @"sub_menu"
#define OSCAPI_INFORMATION_LIST         @"sub_list"
#define OSCAPI_BANNER                   @"banner"

#define OSCAPI_ACTIVE_LIST              @"active_list"

#define OSCAPI_GET_USER_INFO            @"user_info"//获取自己/某人的信息
#define OSCAPI_MESSAGES_LIST            @"user_msg_letters"//消息中心_私信我的列表
#define OSCAPI_MESSAGES_ATME_LIST       @"user_msg_mentions"//消息中心_@我的列表
#define OSCAPI_MESSAGES_COMMENTS_LIST   @"user_msg_comments"//消息中心_评论列表
#define OSCAPI_MESSAGE_CHAT_LIST        @"messages"//获取与某人的私信列表
#define OSCAPI_MESSAGE_DELETE           @"message_delete"
#define OSCAPI_MESSAGE_PUB              @"message_pub"//给某人发送私信

#define OSCAPI_COMMENTS_LIST            @"comment_list"
#define OSCAPI_COMMENT_PUB              @"comment_pub"
#define OSCAPI_COMMENT_REPLY            @"comment_reply"
#define OSCAPI_COMMENT_DELETE           @"comment_delete"

#define OSCAPI_LOGIN_VALIDATE           @"login_validate"
#define OSCAPI_MY_INFORMATION           @"my_information"
#define OSCAPI_USER_INFORMATION         @"user_information"
#define OSCAPI_USER_UPDATERELATION      @"user_updaterelation"
#define OSCAPI_USER_RELATION_REVERSE    @"user_relation_reverse"//user_relation_reverse
#define OSCAPI_USERINFO_UPDATE          @"portrait_update"
#define OSCAPI_USER_NOTICE              @"user_notice"
#define OSCAPI_NOTICE_CLEAR             @"notice_clear"

#define OSCAPI_SOFTWARE_DETAIL          @"software_detail"
#define OSCAPI_BLOG_DETAIL              @"blog_detail"

#define OSCAPI_FAVORITE_LIST            @"favorite_list"
#define OSCAPI_FAVORITE_ADD             @"favorite_add"
#define OSCAPI_FAVORITE_DELETE          @"favorite_delete"

#define OSCAPI_SEARCH_LIST              @"search_list"
#define OSCAPI_FRIENDS_LIST             @"friends_list"
#define OSCAPI_SOFTWARECATALOG_LIST     @"softwarecatalog_list"
#define OSCAPI_SOFTWARE_LIST            @"software_list"
#define OSCAPI_SOFTWARETAG_LIST         @"softwaretag_list"
#define OSCAPI_SOFTWARE_TWEET_LIST      @"software_tweet_list"

#define OSCAPI_BLOGCOMMENTS_LIST        @"blogcomment_list"
#define OSCAPI_BLOGCOMMENT_PUB          @"blogcomment_pub"
#define OSCAPI_BLOGCOMMENT_DELETE       @"blogcomment_delete"

#define OSCAPI_USERBLOG_DELETE          @"userblog_delete"
#define OSCAPI_USERBLOGS_LIST           @"userblog_list"

#define OSCAPI_REPORT                   @"communityManage/report"

#define OSCAPI_SEARCH_USERS             @"find_user"
#define OSCAPI_RANDOM_MESSAGE           @"rock_rock"
#define OSCAPI_RANDOM_SHAKING_NEW       @"shake_news"
#define OSCAPI_RANDOM_SHAKING_GIFT      @"shake_present"
#define OSCAPI_EVENT_LIST               @"event_list"
#define OSCAPI_EVENT_APPLY              @"event_apply"
#define OSCAPI_EVENT_ATTEND_USER        @"event_attend_user"

#define OSCAPI_USER_REPORT_TO_ADMIN     @"user_report_to_admin"
#define OSCAPI_OPENID_LOGIN             @"openid_login"
#define OSCAPI_OPENID_BINDING           @"openid_bind"
#define OSCAPI_OPENID_REGISTER          @"openid_reg"

#define OSCAPI_QUESTION                 @"question"         //问答列表
#define OSCAPI_ACTIVITY                 @"user_activity"    //动态（讨论）列表

#define OSCAPI_USER_FOLLOWS             @"user_follows"
#define OSCAPI_USER_FANS                @"user_fans"

#define OSCAPI_ACCOUNT_LOGIN            @"account_login" //登录
#define OSCAPI_ACCOUNT_OPEN_LOGIN       @"account_open_login" //第三方登录
#define OSCAPI_ACCOUNT_REGISTER         @"account_register" //注册
#define OSCAPI_PHONE_SEND_CODE          @"phone_send_code" // 手机、验证码、换取Token信息 第一步
#define OSCAPI_PHONE_VALIDATE           @"phone_validate" // 手机、验证码、换取Token信息 第二步
#define OSCAPI_ACCOUNT_PASSWORD_FORGET  @"account_password_forgot" //找回密码

#endif
