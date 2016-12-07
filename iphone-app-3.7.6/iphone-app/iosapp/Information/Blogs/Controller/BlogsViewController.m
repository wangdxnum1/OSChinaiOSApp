//
//  BlogsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/30/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "BlogsViewController.h"
#import "BlogCell.h"
#import "OSCBlog.h"
#import "Config.h"
#import "DetailsViewController.h"
#import "NewBlogDetailController.h"
#import "OSCInformationDetailController.h"

static NSString *kBlogCellID = @"BlogCell";

@interface BlogsViewController ()

@end

@implementation BlogsViewController


#pragma mark - init method

- (instancetype)initWithBlogsType:(BlogsType)type
{
    if (self = [super init]) {
        NSString *blogType = type == BlogTypeLatest? @"latest" : @"recommend";
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?type=%@&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_BLOGS_LIST, blogType, (unsigned long)page, OSCAPI_SUFFIX];
        };
        self.objClass = [OSCBlog class];
        
        
        self.needAutoRefresh = YES;
        self.refreshInterval = 7200;
        self.kLastRefreshTime = [NSString stringWithFormat:@"BlogsRefreshInterval-%ld", type];
    }
    
    return self;
}

- (instancetype)initWithUserID:(int64_t)userID
{
    if (self = [super init]) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?authoruid=%lld&pageIndex=%lu&uid=%lld", OSCAPI_PREFIX, OSCAPI_USERBLOGS_LIST, userID, (unsigned long)page, [Config getOwnID]];
        };
        self.objClass = [OSCBlog class];
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"blogs"] childrenWithTag:@"blog"];
}



#pragma mark - life cycle



- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[BlogCell class] forCellReuseIdentifier:kBlogCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - tableView things

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BlogCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kBlogCellID forIndexPath:indexPath];
    OSCBlog *blog = self.objects[indexPath.row];
    
    cell.backgroundColor = [UIColor themeColor];
    
    [cell.titleLabel setAttributedText:blog.attributedTittle];
    [cell.bodyLabel setText:blog.body];
    [cell.authorLabel setText:blog.author];
    cell.titleLabel.textColor = [UIColor titleColor];
    [cell.timeLabel setAttributedText:[Utils attributedTimeString:blog.pubDate]];
    [cell.commentCount setAttributedText:blog.attributedCommentCount];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCBlog *blog = self.objects[indexPath.row];
    
    self.label.font = [UIFont boldSystemFontOfSize:15];
    [self.label setAttributedText:blog.attributedTittle];
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)].height;
    
    self.label.text = blog.body;
    self.label.font = [UIFont systemFontOfSize:13];
    height += [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)].height;
    
    return height + 42;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCBlog *blog = self.objects[indexPath.row];
    
    NewBlogDetailController* newsBlogDetailVc = [[NewBlogDetailController alloc] initWithBlogId:blog.blogID];
    newsBlogDetailVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newsBlogDetailVc animated:YES];
}





@end
