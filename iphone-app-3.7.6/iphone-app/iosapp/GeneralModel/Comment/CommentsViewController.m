//
//  CommentsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentCell.h"
#import "OSCComment.h"
#import "OSCUserHomePageController.h"
#import "Config.h"
#import <MBProgressHUD.h>


static NSString *kCommentCellID = @"CommentCell";


@interface CommentsViewController ()

@property (nonatomic, assign) int64_t objectID;
@property (nonatomic, assign) CommentType commentType;

@end

@implementation CommentsViewController

- (instancetype)initWithCommentType:(CommentType)commentType andObjectID:(int64_t)objectID
{
    self = [super init];
    
    if (self) {
        _objectID = objectID;
        _commentType = commentType;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            NSString *URL;
            if (commentType <= 4) {
                URL = [NSString stringWithFormat:@"%@%@?catalog=%d&id=%lld&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_COMMENTS_LIST, commentType, objectID, (unsigned long)page, OSCAPI_SUFFIX];
            } else if (commentType == CommentTypeBlog) {
                URL = [NSString stringWithFormat:@"%@%@?id=%lld&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_BLOGCOMMENTS_LIST, objectID, (unsigned long)page, OSCAPI_SUFFIX];
            } else if (commentType == CommentTypeSoftware) {
                URL = [NSString stringWithFormat:@"%@%@?project=%lld&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_SOFTWARE_TWEET_LIST, objectID, (unsigned long)page, OSCAPI_SUFFIX];
            }
            return URL;
        };
        
        self.objClass = [OSCComment class];
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"comments"] childrenWithTag:@"comment"];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:kCommentCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - tableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    CommentCell *cell = [CommentCell new];
    OSCComment *comment = self.objects[row];
    
    [self setBlockForCommentCell:cell];
    [cell setContentWithComment:comment];
    cell.contentLabel.textColor = [UIColor contentTextColor];
    cell.portrait.tag = row; cell.authorLabel.tag = row;
    [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDetailsView:)]];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCComment *comment = self.objects[indexPath.row];
    
    if (comment.cellHeight) {return comment.cellHeight;}
    
    self.label.font = [UIFont boldSystemFontOfSize:14];
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:comment.content]];
    if (comment.replies.count > 0) {
        [contentString appendAttributedString:[OSCComment attributedTextFromReplies:comment.replies]];
    }
    
    self.label.font = [UIFont boldSystemFontOfSize:15];
    [self.label setAttributedText:contentString];
    __block CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)].height;
    
    
    CGFloat width = self.tableView.frame.size.width - 60;
    NSArray *references = comment.references;
    if (references.count > 0) {height += 3;}
    
    self.label.font = [UIFont systemFontOfSize:13];
    [references enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(OSCReference *reference, NSUInteger idx, BOOL *stop) {
        self.label.text = [NSString stringWithFormat:@"%@\n%@", reference.title, reference.body];
        height += [self.label sizeThatFits:CGSizeMake(width - (references.count-idx)*8, MAXFLOAT)].height + 13;
    }];
    
    comment.cellHeight = height + 61;
    
    return comment.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCComment *comment = self.objects[indexPath.row];
    
    if (self.didCommentSelected) {
        self.didCommentSelected(comment);
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


// 参考 http://stackoverflow.com/questions/12290828/how-to-show-a-custom-uimenuitem-for-a-uitableviewcell

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // required
}

- (void)setBlockForCommentCell:(CommentCell *)cell
{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteObject:)) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            
            OSCComment *comment = self.objects[indexPath.row];
            int64_t ownID = [Config getOwnID];
            
            return (comment.authorID == ownID || _objectAuthorID == ownID);
        }
        
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        OSCComment *comment = self.objects[indexPath.row];
        
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.label.text = @"正在删除评论";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        [manager POST:[NSString stringWithFormat:@"%@%@?", OSCAPI_PREFIX, OSCAPI_COMMENT_DELETE]
           parameters:@{
                        @"catalog": @(_commentType),
                        @"id": @(_objectID),
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
                      HUD.label.text = @"评论删除成功";
                      
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
                  HUD.label.text = @"网络异常，操作失败";
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    };
}



#pragma mark - scrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    if (scrollView == self.tableView && self.didScroll) {
        self.didScroll();
    }
}




#pragma mark - 跳转到用户详情页

- (void)pushDetailsView:(UITapGestureRecognizer *)tapGesture
{
    OSCComment *comment = self.objects[tapGesture.view.tag];

    if (comment.authorID > 0) {
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:comment.authorID];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}



@end
