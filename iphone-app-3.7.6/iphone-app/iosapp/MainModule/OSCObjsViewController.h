//
//  OSCObjsViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MJRefresh.h>

#import "Utils.h"
#import "OSCAPI.h"
#import "LastCell.h"

@protocol networkingJsonDataDelegate <NSObject>
-(void)getJsonDataWithParametersDic:(NSDictionary*)paraDic isRefresh:(BOOL)isRefresh;
@end

@class ONOXMLDocument;
@interface OSCObjsViewController : UITableViewController

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@property (nonatomic, copy) void (^parseExtraInfo)(ONOXMLDocument *);
@property (nonatomic, copy) NSString * (^generateURL)(NSUInteger page);
@property (nonatomic, copy) void (^tableWillReload)(NSUInteger responseObjectsCount);
@property (nonatomic, copy) void (^didRefreshSucceed)();

@property Class objClass;

@property (nonatomic, assign) BOOL shouldFetchDataAfterLoaded;
@property (nonatomic, assign) BOOL needRefreshAnimation;
@property (nonatomic, assign) BOOL needCache;
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, assign) int allCount;
@property (nonatomic, strong) LastCell *lastCell;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) NSUInteger page;

@property (nonatomic, assign) BOOL needAutoRefresh;
@property (nonatomic, copy) NSString *kLastRefreshTime;
@property (nonatomic, assign) NSTimeInterval refreshInterval;

@property (nonatomic, copy) void (^anotherNetWorking)();
//新接口相关
@property (nonatomic)BOOL isJsonDataVc;
@property (nonatomic, copy) NSString * (^generateUrl)();
@property (nonatomic, strong) NSDictionary *parametersDic;
@property (nonatomic, strong) id responseJsonObject;
@property (nonatomic,weak) id<networkingJsonDataDelegate> netWorkingDelegate;


- (NSArray *)parseXML:(ONOXMLDocument *)xml;
- (void)fetchMore;
- (void)refresh;

@end
