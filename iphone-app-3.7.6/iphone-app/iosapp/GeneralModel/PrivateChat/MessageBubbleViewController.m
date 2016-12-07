//
//  MessageBubbleViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 2/12/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "MessageBubbleViewController.h"
#import "MessageBubbleCell.h"
#import "OSCComment.h"
#import "Config.h"
#import "OSCUserHomePageController.h"

#import <MBProgressHUD.h>

@interface MessageBubbleViewController ()

@end

@implementation MessageBubbleViewController

- (instancetype)initWithUserID:(int64_t)userID andUserName:(NSString *)userName
{
    self = [super init];
    if (self) {
        self.navigationItem.title = userName;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?catalog=4&id=%llu&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_COMMENTS_LIST, userID, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.objClass = [OSCComment class];
    }
    
    return self;
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"comments"] childrenWithTag:@"comment"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[MessageBubbleCell class] forCellReuseIdentifier:kMessageBubbleOthers];
    [self.tableView registerClass:[MessageBubbleCell class] forCellReuseIdentifier:kMessageBubbleMe];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCComment *message = self.objects[indexPath.row];
    
    MessageBubbleCell *cell = nil;
    if (message.authorID == [Config getOwnID]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kMessageBubbleMe forIndexPath:indexPath];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kMessageBubbleOthers forIndexPath:indexPath];
    }
    
    [self setBlockForMessageCell:cell];
    
    [cell setContent:message.content andPortrait:message.portraitURL];
    
    cell.portrait.tag = message.authorID;
    [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushUserDetails:)]];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCComment *message = self.objects[indexPath.row];
    
    self.label.text = message.content;
    self.label.font = [UIFont systemFontOfSize:15];
    CGSize contentSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 85, MAXFLOAT)];
    
    return contentSize.height + 33;
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView && _didScroll) {_didScroll();}
}


- (void)pushUserDetails:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.view.tag > 0) {
        [self.navigationController pushViewController:[[OSCUserHomePageController alloc] initWithUserID: recognizer.view.tag] animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

#pragma mark - 删除私信

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return action == @selector(deleteObject:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // required
}

#pragma mark - UIScrollViewDelegate

- (void)setBlockForMessageCell:(MessageBubbleCell *)cell
{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteObject:)) {
            return YES;
        }
        
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        OSCComment *comment = self.objects[indexPath.row];
        
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.label.text = @"正在删除私信";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_COMMENT_DELETE]
           parameters:@{@"catalog": @(4),
                        @"id": @([Config getOwnID]),
                        @"replyid": @(comment.commentID),
                        @"authorid": @(comment.authorID)
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  ONOXMLElement *resultXML = [responseObject.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[resultXML firstChildWithTag: @"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[resultXML firstChildWithTag:@"errorMessage"] stringValue];
                  
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  if (errorCode == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.label.text = @"私信删除成功";
                      
                      [self.objects removeObjectAtIndex:indexPath.row];
                      self.allCount--;
                      if (self.objects.count > 0) {
                          [self.tableView beginUpdates];
                          [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                          [self.tableView endUpdates];
                      }
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.tableView reloadData];
                      });
                  } else {
//                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                      HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  }
                  
                  [HUD hideAnimated:YES afterDelay:1];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  HUD.mode = MBProgressHUDModeCustomView;
//                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.detailsLabel.text = error.userInfo[NSLocalizedDescriptionKey];
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    };
}



@end
