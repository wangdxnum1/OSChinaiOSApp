//
//  OSCRecommendTopicsController.h
//  iosapp
//
//  Created by Graphic-one on 16/11/4.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "enumList.h"

@interface OSCRecommendTopicsController : UIViewController

- (instancetype)initWithTopicName:(NSString* )topicName;

- (instancetype)initWithTopicName:(NSString* )topicName
                        topicDesc:(NSString* )topicDesc
                        joinCount:(NSInteger)joinCount
                          bgImage:(TopicRecommedTweetType)imageType;

@end
