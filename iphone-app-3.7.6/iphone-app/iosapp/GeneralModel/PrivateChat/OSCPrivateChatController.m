//
//  OSCPrivateChatController.m
//  iosapp
//
//  Created by Graphic-one on 16/8/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPrivateChatController.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCPrivateChatCell.h"
#import "OSCPrivateChat.h"
#import "OSCPhotoGroupView.h"

#import "ImageDownloadHandle.h"

#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"

#import <MJRefresh.h>
#import <MJExtension.h>
#import <MBProgressHUD.h>

static NSString* const OSCPrivateChatCellReuseIdentifier = @"OSCPrivateChatCell";
@interface OSCPrivateChatController ()<UITableViewDelegate,UITableViewDataSource,OSCPrivateChatCellDelegate, UITextViewDelegate>
{
    NSInteger _requestCount;
}

@property (nonatomic,strong) NSMutableArray* dataSource;
@property (nonatomic,strong) NSString* nextPageToken;
@property (nonatomic,strong) NSString* prevPageToken;

@end

@implementation OSCPrivateChatController{
    NSInteger _authorId;
}
#pragma mark --- initialize method
- (instancetype)initWithAuthorId:(NSInteger)authorId{
    self = [super init];
    if (self) {
        _authorId = authorId;
        _prevPageToken = @"";
        _nextPageToken = @"";
        _requestCount = 0;
        _dataSource = [NSMutableArray array];
    }
    return self;
}

#pragma mark --- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        [self getDataUpgradeRequest:YES];
    }];
    [self getDataUpgradeRequest:NO];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark - refresh
- (void)refresh
{
    [self.dataSource removeAllObjects];
    _nextPageToken = @"";
    _prevPageToken = @"";
    [self getDataUpgradeRequest:NO];
}
- (void)refreshToBottom{
    [self.tableView reloadData];
    if (self.dataSource.count != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.dataSource.count - 1) inSection:0]  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}


#pragma mark --- Networking
// YES:往上请求数据 带prevPageToken   NO:往下请求数据 带nextPageToken
- (void)getDataUpgradeRequest:(BOOL)isUpgradeReq{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@?uid=%llu&authorId=%ld",OSCAPI_V2_PREFIX,OSCAPI_MESSAGE_CHAT_LIST,[Config getOwnID],_authorId];
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];

    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    if (isUpgradeReq && [self.nextPageToken length] > 0) {
        [paraMutableDic setObject:self.nextPageToken forKey:@"pageToken"];
    }
    if (!isUpgradeReq && [self.prevPageToken length] > 0) {
        [paraMutableDic setObject:self.prevPageToken forKey:@"pageToken"];
    }
    
    MBProgressHUD* HUD = [Utils createHUD];
    [manager GET:strUrl
      parameters:paraMutableDic.copy
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             if ([responseObject[@"code"]integerValue] == 1) {
                 NSDictionary* resultDic = responseObject[@"result"];
                 NSArray* items = resultDic[@"items"];
                 self.nextPageToken = resultDic[@"nextPageToken"];
                 self.prevPageToken = resultDic[@"prevPageToken"];
                 NSArray* models = [OSCPrivateChat mj_objectArrayWithKeyValuesArray:items];
                 NSArray* reversedArray = models;
                 
/** 容错重复数据*/
                 if (isUpgradeReq) {//往上请求数据 添加到数组前面
                     OSCPrivateChat* newData_last = nil;
                     OSCPrivateChat* nowData_last = nil;
                     if (reversedArray.count) { newData_last = [reversedArray lastObject]; }
                     if (self.dataSource.count) { nowData_last = [self.dataSource lastObject]; }
                     
                     if (newData_last.id != nowData_last.id) {
                         NSRange range = NSMakeRange(0, reversedArray.count);
                         NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                         [self.dataSource insertObjects:reversedArray atIndexes:indexSet];
                     }
                 }else{//往下请求数据  添加到数组后面
                     OSCPrivateChat* newData_first = nil;
                     OSCPrivateChat* nowData_first = nil;
                     if (reversedArray.count) { newData_first = [reversedArray firstObject]; }
                     if (self.dataSource.count) { nowData_first = [self.dataSource firstObject]; }

                     if (newData_first.id != nowData_first.id) {
                         [self.dataSource addObjectsFromArray:reversedArray];
                     }
                 }
             }
             
             
             NSMutableArray *imageUrl = [[NSMutableArray alloc] init];
             for (OSCPrivateChat *model in self.dataSource) {
                 if (model.type == OSCPrivateChatTypeImage) {
                    [imageUrl addObject:model.resource];
                 }
             }
             
             __block int imageNumber = 0;
             
             if (imageUrl.count == 0) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (isUpgradeReq) {
                         [self.tableView reloadData];
                     }else{
                         [self refreshToBottom];
                     }
                     [HUD hideAnimated:YES afterDelay:0.3];
                 });
             }
             
             for(int i = 0 ; i < imageUrl.count ; i ++){
                 UIImage *image = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageUrl[i]];
                 if (!image) {
                     [ImageDownloadHandle downloadImageWithUrlString:imageUrl[i] SaveToDisk:YES completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                         imageNumber ++ ;
                         if(imageNumber == imageUrl.count){
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if (isUpgradeReq) {
                                     [self.tableView reloadData];
                                 }else{
                                     [self refreshToBottom];
                                 }
                                 [HUD hideAnimated:YES afterDelay:0.3];
                             });
                         }
                     }];
                 }else{
                     imageNumber ++;
                     if (imageNumber == imageUrl.count) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (isUpgradeReq) {
                                 [self.tableView reloadData];
                             }else{
                                 [self refreshToBottom];
                             }
                             [HUD hideAnimated:YES afterDelay:0.3];
                         });
                     }
                 }
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [TimeTipHelper resetTimeTipHelper];
                 if (isUpgradeReq) {
                     [self.tableView.mj_header endRefreshing];
                 }else{
                     [self.tableView.mj_footer endRefreshing];
                 }

                 [HUD hideAnimated:YES afterDelay:0.3];
             });
    }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (isUpgradeReq) {
                     [self.tableView.mj_header endRefreshing];
                 }else{
                     [self.tableView.mj_footer endRefreshing];
                 }
                 HUD.label.text = @"网络异常，操作失败";
                 [HUD hideAnimated:YES afterDelay:1];
             });
    }];
}

#pragma mark --- UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCPrivateChatCell* chatCell = [OSCPrivateChatCell returnReusePrivateChatCellWithTableView:tableView identifier:OSCPrivateChatCellReuseIdentifier];
    chatCell.privateChat = self.dataSource[indexPath.row];
    chatCell.delegate = self;
    return chatCell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCPrivateChat* dataSource = self.dataSource[indexPath.row];
    if (dataSource.privateChatType == OSCPrivateChatTypeImage) {
        dataSource.rowHeight = dataSource.popFrame.size.height + SCREEN_PADDING_TOP + SCREEN_PADDING_BOTTOM;
        if (dataSource.isDisplayTimeTip) {
            dataSource.rowHeight += PRIVATE_TIME_TIP_ADDITIONAL;
        }
        return dataSource.rowHeight;
    }else{
        if (dataSource.rowHeight == 0) {
            dataSource.rowHeight = dataSource.popFrame.size.height + SCREEN_PADDING_TOP + SCREEN_PADDING_BOTTOM;
            if (dataSource.isDisplayTimeTip) {
                dataSource.rowHeight += PRIVATE_TIME_TIP_ADDITIONAL;
            }
        }
    }
    return dataSource.rowHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_didScroll) {
        _didScroll();
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_didScroll) {
        _didScroll();
    }
}

#pragma mark --- scrollView delegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (scrollView == self.tableView && _didScroll) {_didScroll();}
//}


#pragma mark --- OSCPrivateChatCellDelegate
//文本cell回调
- (void)privateChatNodeTextViewDidClickText:(OSCPrivateChatCell *)privateChatCell{

}
//文本点击回调
- (void)privateChatNodeTextViewshouldInteractTextView:(UITextView *)textView URL:(NSURL *)URL inRange:(NSRange)characterRange{
    NSString* nameStr = [textView.text substringWithRange:characterRange];
    if ([[nameStr substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"@"]) {
        nameStr = [nameStr substringFromIndex:1];
        [self.navigationController handleURL:URL name:nameStr];
    }else{
        [self.navigationController handleURL:URL name:nil];
    }
}
//图片cell回调
- (void)privateChatNodeImageViewDidClickImage:(OSCPrivateChatCell *)privateChatCell{

}
- (void)privateChatNodeImageViewloadThumbImageDidFinsh:(OSCPrivateChatCell *)privateChatCell{
//    NSLog(@"123");
//    [self refresh];
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:privateChatCell];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
- (void)privateChatNodeImageViewloadLargerImageDidFinsh:(OSCPrivateChatCell *)privateChatCell photoGroupView:(OSCPhotoGroupView *)groupView fromView:(UIImageView *)fromView{
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    [groupView presentFromImageView:fromView toContainer:currentWindow animated:YES completion:nil];
}
//文件cell回调
- (void)privateChatNodeFileViewDidClickFile:(OSCPrivateChatCell *)privateChatCell{
    
}






#pragma 监听
-(void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    float keyBoardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataSource.count - 1 inSection:0];
    OSCPrivateChatCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    CGFloat differenceY = [UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(cell.frame) - 109;
    CGPoint point = self.tableView.contentOffset;
    if (0 < differenceY && differenceY < keyBoardHeight) {
        [self.tableView setContentOffset:CGPointMake(point.x, point.y + keyBoardHeight - differenceY) animated:YES];
    }else if (differenceY < 0 || differenceY >= [UIScreen mainScreen].bounds.size.height - 109){
        [self.tableView setContentOffset:CGPointMake(point.x, point.y + keyBoardHeight) animated:YES];
    }
    }

@end
