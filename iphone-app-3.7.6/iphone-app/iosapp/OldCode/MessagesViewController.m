//
//  MessagesViewController.m
//  iosapp
//
//  Created by ChanAetern on 12/12/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "MessagesViewController.h"
#import "Config.h"
#import "Utils.h"
#import "OSCMessage.h"
#import "MessageCell.h"
#import "BubbleChatViewController.h"
#import "OSCUserHomePageController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import <MBProgressHUD.h>

static NSString * const kMessageCellID = @"MessageCell";

@implementation MessagesViewController

- (instancetype)init
{
    self = [super init];
    if (!self) {return nil;}
    
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@?uid=%llu&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_MESSAGES_LIST, [Config getOwnID], (unsigned long)page, OSCAPI_SUFFIX];
    };
    
    self.objClass = [OSCMessage class];
    
    return self;
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"messages"] childrenWithTag:@"message"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[MessageCell class] forCellReuseIdentifier:kMessageCellID];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCMessage *message = self.objects[indexPath.row];
    
    MessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kMessageCellID forIndexPath:indexPath];
    
    [self setBlockForMessageCell:cell];
    
    cell.backgroundColor = [UIColor themeColor];
    [cell.portrait loadPortrait:message.portraitURL];
    cell.portrait.tag = (int)message.friendID;
    [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushUserDetails:)]];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", message.senderID == [Config getOwnID] ? @"发给" : @"来自", message.friendName];
    cell.contentLabel.text = message.content;
    cell.timeLabel.text = [message.pubDate timeAgoSinceNow];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%d封私信", message.messageCount];
    
    cell.contentLabel.textColor = [UIColor titleColor];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCMessage *message = self.objects[indexPath.row];
    
    self.label.text = message.senderName;
    self.label.font = [UIFont boldSystemFontOfSize:14];
    CGSize nameSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 70, MAXFLOAT)];
    
    self.label.text = message.content;
    self.label.font = [UIFont boldSystemFontOfSize:15];
    CGSize contentSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
    
    return nameSize.height + contentSize.height + 38;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    OSCMessage *message = self.objects[indexPath.row];
    BubbleChatViewController *bubbleChatVC = [[BubbleChatViewController alloc] initWithUserID:message.friendID andUserName:message.friendName];
    
    [self.navigationController pushViewController:bubbleChatVC animated:YES];
}

- (void)pushUserDetails:(UIGestureRecognizer *)recognizer
{
    [self.navigationController pushViewController:[[OSCUserHomePageController alloc] initWithUserID:recognizer.view.tag] animated:YES];
}
#pragma mark - 删除回复

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_didScroll) {_didScroll();}
}

- (void)setBlockForMessageCell:(MessageCell *)cell
{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(deleteObject:)) {
            return YES;
        }
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        OSCMessage *message = self.objects[indexPath.row];
        
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.label.text = @"正在删除回复";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_MESSAGE_DELETE]
           parameters:@{
                        @"friendid": @(message.friendID),
                        @"uid": @([Config getOwnID])
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  ONOXMLElement *resultXML = [responseObject.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[resultXML firstChildWithTag: @"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[resultXML firstChildWithTag:@"errorMessage"] stringValue];
                  
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  if (errorCode == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.label.text = @"回复删除成功";
                      
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
