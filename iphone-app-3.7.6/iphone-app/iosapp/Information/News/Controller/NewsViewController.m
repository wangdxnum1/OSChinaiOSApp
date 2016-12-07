//
//  NewsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsCell.h"
#import "OSCNews.h"
#import "DetailsViewController.h"
#import "ActivityDetailsWithBarViewController.h"

static NSString *kNewsCellID = @"NewsCell";

@interface NewsViewController ()

@end

@implementation NewsViewController

- (instancetype)initWithNewsListType:(NewsListType)type
{
    self = [super init];

    if (self) {
        __weak NewsViewController *weakSelf = self;
        self.generateURL = ^NSString * (NSUInteger page) {
            if (type < 4) {
                return [NSString stringWithFormat:@"%@%@?catalog=%d&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_NEWS_LIST, type, (unsigned long)page, OSCAPI_SUFFIX];
            } else if (type == NewsListTypeAllTypeWeekHottest) {
                return [NSString stringWithFormat:@"%@%@?show=week", OSCAPI_PREFIX, OSCAPI_NEWS_LIST];
            } else {
                return [NSString stringWithFormat:@"%@%@?show=month", OSCAPI_PREFIX, OSCAPI_NEWS_LIST];
            }
        };
        
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            if (type >= 4) {weakSelf.lastCell.status = LastCellStatusFinished;}
            else {responseObjectsCount < 20? (weakSelf.lastCell.status = LastCellStatusFinished) :
                                             (weakSelf.lastCell.status = LastCellStatusMore);}
        };
        
        self.objClass = [OSCNews class];
        
        
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = [NSString stringWithFormat:@"NewsRefreshInterval-%d", type];
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"newslist"] childrenWithTag:@"news"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[NewsCell class] forCellReuseIdentifier:kNewsCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewsCellID forIndexPath:indexPath];
    OSCNews *news = self.objects[indexPath.row];
    
    cell.backgroundColor = [UIColor themeColor];
    
    [cell.titleLabel setAttributedText:news.attributedTittle];
    [cell.bodyLabel setText:news.body];
    [cell.authorLabel setText:news.author];
    cell.titleLabel.textColor = [UIColor titleColor];
    [cell.timeLabel setAttributedText:[Utils attributedTimeString:news.pubDate]];
    [cell.commentCount setAttributedText:news.attributedCommentCount];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCNews *news = self.objects[indexPath.row];
    
    self.label.font = [UIFont boldSystemFontOfSize:15];
    [self.label setAttributedText:news.attributedTittle];
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)].height;
    
    self.label.text = news.body;
    self.label.font = [UIFont systemFontOfSize:13];
    height += [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)].height;
    
    return height + 42;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCNews *news = self.objects[indexPath.row];
    if (news.eventURL.absoluteString.length > 0) {
        
        ActivityDetailsWithBarViewController *activityBVC = [[ActivityDetailsWithBarViewController alloc] initWithActivityID:[news.attachment longLongValue]];
        [self.navigationController pushViewController:activityBVC animated:YES];
    } else if (news.url.absoluteString.length > 0) {
        [self.navigationController handleURL:news.url name:nil];
    } else {
        DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithNews:news];
        [self.navigationController pushViewController:detailsViewController animated:YES];
    }
}








@end
