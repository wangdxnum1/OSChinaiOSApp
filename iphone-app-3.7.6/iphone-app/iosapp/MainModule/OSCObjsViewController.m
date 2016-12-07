//
//  OSCObjsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"
#import "OSCBaseObject.h"
#import "LastCell.h"

#import <MBProgressHUD.h>

@interface OSCObjsViewController ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSDate *lastRefreshTime;

@property (nonatomic, strong) UIImageView * imageView;

@end


@implementation OSCObjsViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        _objects = [NSMutableArray new];
        _page = 0;
        _needRefreshAnimation = YES;
        _shouldFetchDataAfterLoaded = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _imageView.hidden = YES;
    
    if (_needAutoRefresh) {
        NSDate *currentTime = [NSDate date];
        if ([currentTime timeIntervalSinceDate:_lastRefreshTime] > _refreshInterval) {
            _lastRefreshTime = currentTime;
            
            [self refresh];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _imageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dawnAndNightMode:) name:@"dawnAndNight" object:nil];
    
    self.tableView.backgroundColor = [UIColor themeColor];
    
    _lastCell = [[LastCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    [_lastCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchMore)]];
    _lastCell.status = LastCellStatusMore;
    self.tableView.tableFooterView = _lastCell;
    
    self.tableView.mj_header = ({
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        header;
    });
    
    _label = [UILabel new];
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.font = [UIFont boldSystemFontOfSize:14];
    _lastCell.textLabel.textColor = [UIColor titleColor];
    
    
    /*** 自动刷新 ***/
    
    if (_needAutoRefresh) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _lastRefreshTime = [_userDefaults objectForKey:_kLastRefreshTime];
        
        if (!_lastRefreshTime) {
            _lastRefreshTime = [NSDate date];
            [_userDefaults setObject:_lastRefreshTime forKey:_kLastRefreshTime];
        }
    }
    
    if (_isJsonDataVc) {
        _manager = [AFHTTPRequestOperationManager OSCJsonManager];
        if (_needAutoRefresh) {
            if ([_netWorkingDelegate respondsToSelector:@selector(getJsonDataWithParametersDic:isRefresh:)]) {
                [_netWorkingDelegate getJsonDataWithParametersDic:_parametersDic isRefresh:YES];
            }
        }
    }else {
        _manager = [AFHTTPRequestOperationManager OSCManager];
        [self fetchObjectsOnPage:0 refresh:YES];
    }
    
    if (!_shouldFetchDataAfterLoaded) {return;}
    if (!_isJsonDataVc && _needRefreshAnimation) {
        [self.tableView.mj_header beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height)
                                animated:YES];
    }
    
    if (_needCache) {
        _manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dawnAndNight" object:nil];
}



-(void)dawnAndNightMode:(NSNotification *)center
{
    _lastCell.textLabel.backgroundColor = [UIColor themeColor];
    _lastCell.textLabel.textColor = [UIColor titleColor];

}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tableView.separatorColor = [UIColor separatorColor];
    
    return _objects.count;
}



#pragma mark - 刷新

- (void)refresh
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        if (_isJsonDataVc) {
            if ([_netWorkingDelegate respondsToSelector:@selector(getJsonDataWithParametersDic:isRefresh:)]) {
                [_netWorkingDelegate getJsonDataWithParametersDic:_parametersDic isRefresh:YES];
            }
        }else {
            [self fetchObjectsOnPage:0 refresh:YES];
        }
        
    });
    
    //刷新时，增加另外的网络请求功能
    if (self.anotherNetWorking) {
        self.anotherNetWorking();
    }
}




#pragma mark - 上拉加载更多

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height - 150)) {        
        [self fetchMore];
    }
}

- (void)fetchMore
{
    if (!_lastCell.shouldResponseToTouch) {return;}
    
    _lastCell.status = LastCellStatusLoading;
    _manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    if (_isJsonDataVc) {
        if ([_netWorkingDelegate respondsToSelector:@selector(getJsonDataWithParametersDic:isRefresh:)]) {
            [_netWorkingDelegate getJsonDataWithParametersDic:_parametersDic isRefresh:NO];
        }
    }else {
        [self fetchObjectsOnPage:++_page refresh:NO];
    }
    
}


#pragma mark - 请求数据

- (void)fetchObjectsOnPage:(NSUInteger)page refresh:(BOOL)refresh
{
    [_manager GET:self.generateURL(page)
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
             _allCount = [[[responseDocument.rootElement firstChildWithTag:@"allCount"] numberValue] intValue];
             NSArray *objectsXML = [self parseXML:responseDocument];
             
             if (refresh) {
                 _page = 0;
                 [_objects removeAllObjects];
                 if (_didRefreshSucceed) {_didRefreshSucceed();}
             }
             
             if (_parseExtraInfo) {_parseExtraInfo(responseDocument);}
             
             for (ONOXMLElement *objectXML in objectsXML) {
                 BOOL shouldBeAdded = YES;
                 id obj = [[_objClass alloc] initWithXML:objectXML];
                 
                 for (OSCBaseObject *baseObj in _objects) {
                     if ([obj isEqual:baseObj]) {
                         shouldBeAdded = NO;
                         break;
                     }
                 }
                 if (shouldBeAdded) {
                     [_objects addObject:obj];
                 }
             }
             
             if (_needAutoRefresh) {
                 [_userDefaults setObject:_lastRefreshTime forKey:_kLastRefreshTime];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (self.tableWillReload) {self.tableWillReload(objectsXML.count);}
                 else {
                     if (_page == 0 && objectsXML.count == 0) {
                         _lastCell.status = LastCellStatusEmpty;
                     } else if (objectsXML.count == 0 || (_page == 0 && objectsXML.count < 20)) {
                         _lastCell.status = LastCellStatusFinished;
                     } else {
                         _lastCell.status = LastCellStatusMore;
                     }
                 }
                 
                 if (self.tableView.mj_header.isRefreshing) {
                     [self.tableView.mj_header endRefreshing];
                 }
                 
                 [self.tableView reloadData];
             });
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
//             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.detailsLabel.text = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
             
             [HUD hideAnimated:YES afterDelay:1];
             
             _lastCell.status = LastCellStatusError;
             if (self.tableView.mj_header.isRefreshing) {
                 [self.tableView.mj_header endRefreshing];
             }
             [self.tableView reloadData];
         }
     ];
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    NSAssert(false, @"Over ride in subclasses");
    return nil;
}


@end
