//
//  PostsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "PostsViewController.h"
#import "PostCell.h"
#import "OSCPost.h"
#import "DetailsViewController.h"
#import "UIImageView+Util.h"
#import <SDWebImage/UIImageView+WebCache.h>


static NSString *kPostCellID = @"PostCell";


@implementation PostsViewController

- (instancetype)initWithPostsType:(PostsType)type
{
    self = [super init];
    
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?catalog=%d&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_POSTS_LIST, type, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.objClass = [OSCPost class];
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"posts"] childrenWithTag:@"post"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[PostCell class] forCellReuseIdentifier:kPostCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}





#pragma mark - 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPostCellID forIndexPath:indexPath];
    OSCPost *post = self.objects[indexPath.row];
    
    [cell.portrait loadPortrait:post.portraitURL];
    [cell.titleLabel setText:post.title];
    [cell.bodyLabel setText:post.body];
    [cell.authorLabel setText:post.author];
    [cell.timeLabel setText:[post.pubDate timeAgoSinceNow]];
    [cell.commentAndView setText:[NSString stringWithFormat:@"%d回 / %d阅", post.replyCount, post.viewCount]];
    
    cell.titleLabel.textColor = [UIColor titleColor];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCPost *post = self.objects[indexPath.row];
    
    self.label.font = [UIFont boldSystemFontOfSize:15];
    self.label.text = post.title;
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 62, MAXFLOAT)].height;
    
    self.label.text = post.body;
    self.label.font = [UIFont systemFontOfSize:13];
    height += [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 62, MAXFLOAT)].height;
    
    return height + 41;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCPost *post = self.objects[indexPath.row];
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithPost:post];
    [self.navigationController pushViewController:detailsViewController animated:YES];
}







@end
