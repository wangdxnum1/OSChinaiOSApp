//
//  OSCFavorite.h
//  iosapp
//
//  Created by ChanAetern on 12/11/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

typedef NS_ENUM(int, FavoritesType)
{
    FavoritesTypeSoftware = 1,
    FavoritesTypeTopic,
    FavoritesTypeBlog,
    FavoritesTypeNews,
    FavoritesTypeCode,
};

@interface OSCFavorite : OSCBaseObject

@property (nonatomic, assign) int64_t objectID;
@property (nonatomic, assign) FavoritesType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSURL *url;

@end
