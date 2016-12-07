//
//  OSCSearchResultTableViewController.h
//  iosapp
//
//  Created by 王恒 on 16/10/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TableViewType){
    TableViewTypeBlog = 0,
    TableViewTypeSoft,
    TableViewTypeNews,
    TableViewTypeQuestion,
    TableViewTypePerson,
};

@protocol ResultContrllerDelegate <NSObject>

/**当滚动时*/
-(void)resultTableViewDidScroll;

/**当开始加载时*/
-(void)resultVCBeginRequest;

/**当加载完成时*/
-(void)resultVCCompleteRequest;

/**当点击cell时*/
-(void)resultClickCellWithContoller:(UIViewController *)targetVC withHref:(NSString *)href;

@end

@interface OSCSearchResultTableViewController : UITableViewController

@property (nonatomic,strong)NSString *keyWord;
@property (nonatomic,assign)id<ResultContrllerDelegate> resultDelegate;

-(instancetype)initWithStyle:(UITableViewStyle)style withType:(TableViewType)type;

-(void)getDataWithisRefresh:(BOOL)isRefresh;

-(void)controllerChanged;

@end
