//
//  SoftwareListVC.h
//  iosapp
//
//  Created by ChanAetern on 12/9/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

typedef NS_ENUM(int, SoftwaresType)
{
    SoftwaresTypeRecommended,
    SoftwaresTypeNewest,
    SoftwaresTypeHottest,
    SoftwaresTypeCN,
};

@interface SoftwareListVC : OSCObjsViewController

- (instancetype)initWithSoftwaresType:(SoftwaresType)softwareType;
- (instancetype)initWIthSearchTag:(int)searchTag;

@end
