//
//  TeamIssueDetailController.m
//  iosapp
//
//  Created by Holden on 15/4/30.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamIssueDetailController.h"
#import "TeamIssueDetailCell.h"
#import "Utils.h"
#import "Config.h"
#import "TeamAPI.h"
#import "TeamIssue.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>
#import "NSString+FontAwesome.h"

#import "TeamReplyCell.h"
#import "TeamReply.h"

#import "NewTeamIssueViewController.h"

@interface TeamIssueDetailController ()<UITableViewDataSource,UITableViewDelegate>
//@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic)int teamId;
@property (nonatomic)int issueId;

@property (nonatomic,copy)NSString *issueTitle;
@property (nonatomic,strong)TeamIssue *detailIssue;
@property (nonatomic,strong)NSString *issueState;
//@property (nonatomic,strong)TeamIssueDetailCell *issueTitleCell;
//@property (nonatomic,strong)TeamIssueDetailCell *issueStageCell;
@property (nonatomic,strong)NSMutableArray *originDatas;
@property (nonatomic,strong)NSMutableArray *descriptions;
@property (nonatomic,strong)NSMutableArray *subIssueInfos;
@property (nonatomic,strong)NSMutableArray *handledSubIssueInfos;

@property (nonatomic)BOOL isOpeningSubIssue;
@end

@implementation TeamIssueDetailController


- (instancetype)initWithIssueId:(int)issueId
{
    self = [super initWithObjectID:issueId andType:TeamReplyTypeIssue];
    if (self) {
        _issueId = issueId;
        _teamId = [Config teamID];
    }
    
    return self;
}


#pragma mark --任务详情信息
-(void)getIssueDetailNetWorkingInfo
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_ISSUE_DETAIL];
    [manager GET:url
      parameters:@{
                   @"teamid": @(_teamId),
                   @"issueid": @(_issueId)
                   }
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             _detailIssue = [[TeamIssue alloc]initWithDetailIssueXML:[responseObject.rootElement firstChildWithTag:@"issue"]];
             _subIssueInfos = _detailIssue.childIssues;
             [self setupSubIssueCellData];
             _issueTitle = _detailIssue.title;
             _issueState = _detailIssue.state;

             NSString *subIssueCount = _detailIssue.childIssues.count ? [NSString stringWithFormat:@"%d个子任务，%d个已完成", _detailIssue.childIssuesCount, _detailIssue.closedChildIssuesCount] : @"暂无子任务";
             NSString *toUser = _detailIssue.user.name.length ? _detailIssue.user.name : @"未指派";
             
             NSString *deadLineTime = _detailIssue.deadline ? [_detailIssue.deadline formattedDateWithStyle:NSDateFormatterMediumStyle] : @"未指定截止日期";

             NSString *state = [self getChineseNameWithState:_issueState];
             NSString *attachmentsCount = _detailIssue.attachmentsCount ?[NSString stringWithFormat:@"%d",_detailIssue.attachmentsCount] : @"暂无附件";
             NSString *relationIssueCount = _detailIssue.relatedIssuesCount ?[NSString stringWithFormat:@"%d",_detailIssue.relatedIssuesCount] : @"暂无关联";
             NSString *allCollaborator = [self getCollaboratorsStringWithcollabortorsArray:_detailIssue.collaborators];
             
             _descriptions = [NSMutableArray arrayWithArray:@[@"",subIssueCount, toUser, deadLineTime, allCollaborator, state, @"", attachmentsCount, relationIssueCount]];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}
//设置MainCellcell的数据
-(void)setMainCellData
{
    NSDictionary *iconTitleDic0 = @{@"icon":@"\uf10c",@"title":@"",@"cellLevel":@1};
    NSDictionary *iconTitleDic1 = @{@"icon":@"\uf067",@"title":@"子任务",@"cellLevel":@1};
    NSDictionary *iconTitleDic2 = @{@"icon":@"\uf007",@"title":@"指派给",@"cellLevel":@1};
    NSDictionary *iconTitleDic3 = @{@"icon":@"\uf073",@"title":@"截止日期",@"cellLevel":@1};
    NSDictionary *iconTitleDic4 = @{@"icon":@"\uf0c0",@"title":@"协作者",@"cellLevel":@1};
    NSDictionary *iconTitleDic5 = @{@"icon":@"\uf080",@"title":@"阶段",@"cellLevel":@1};
    NSDictionary *iconTitleDic6 = @{@"icon":@"\uf02c",@"title":@"-",@"cellLevel":@1};
    NSDictionary *iconTitleDic7 = @{@"icon":@"\uf0c6",@"title":@"附件",@"cellLevel":@1};
    NSDictionary *iconTitleDic8 = @{@"icon":@"\uf0c1",@"title":@"关联",@"cellLevel":@1};
    
    _originDatas = [NSMutableArray arrayWithArray:@[iconTitleDic0,iconTitleDic1,iconTitleDic2,iconTitleDic3,iconTitleDic4,iconTitleDic5,iconTitleDic6,iconTitleDic7,iconTitleDic8]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"任务详情";
    self.tableView.separatorColor = [UIColor separatorColor];
    
    [self setMainCellData];
    
    //registerCell
    NSArray *identifiers = @[kteamIssueDetailCellNomal,kTeamIssueDetailCellRemark,kTeamIssueDetailCellSubChild];
    for (int i=0; i<3; i++) {
        [self.tableView registerClass:[TeamIssueDetailCell class] forCellReuseIdentifier:[identifiers objectAtIndex:i]];
    }

    [self getIssueDetailNetWorkingInfo];
}

//协助者显示
-(NSString*)getCollaboratorsStringWithcollabortorsArray:(NSArray*)collaborators {
    NSString *allCollaborators = @"";
    if (collaborators.count > 0) {
        for (int k = 0; k < collaborators.count; k++) {
            TeamMember *member = [collaborators objectAtIndex:k];
            if (k == 0) {
                allCollaborators = [allCollaborators stringByAppendingFormat:@"%@",member.name];
            } else {
                allCollaborators = [allCollaborators stringByAppendingFormat:@",%@",member.name];
            }
            if (k == 3) {
                allCollaborators = [allCollaborators stringByAppendingString:@"等"];
                break;
            }
        }
    }else {
        allCollaborators = @"暂无协作者";
    }
    return allCollaborators;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSDictionary *cellDic = _originDatas[indexPath.row];
        if ([cellDic[@"cellLevel"] intValue] == 1) {
            if ([cellDic[@"title"] isEqualToString:@""]) {
                UILabel *label = [UILabel new];
                label.numberOfLines = 0;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.font = [UIFont systemFontOfSize:18];
                label.text = _issueTitle;
                CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
                return height > 55 ? height+10 : 55;
            }else {
                return 55;
            }
        }else {     //子任务
            UILabel *label = [UILabel new];
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.font = [UIFont systemFontOfSize:15];
            label.text = cellDic[@"title"];
            CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
            return height > 55 ? height : 55;
        }
    }else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return _projectName ?: @"";
    }else {
        return [super tableView:tableView titleForHeaderInSection:section];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _originDatas.count;
    }else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
    {
        TeamIssueDetailCell *cell;
        
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
        NSDictionary *tempDic = _originDatas[indexPath.row];
        if (![tempDic[@"title"] isEqualToString:@"-"]) {    //根据原始设定数据判断当前cell的风格
            if ([tempDic[@"cellLevel"] intValue] == 1) {
                cell = [tableView dequeueReusableCellWithIdentifier:kteamIssueDetailCellNomal];
                cell.iconLabel.text = tempDic[@"icon"];
                
                if(_descriptions.count > 0) {
                    cell.descriptionLabel.text = _descriptions[indexPath.row] ?: @"";
                }
                if ([tempDic[@"title"] isEqualToString:@""]) {
                    cell.iconLabel.text = [self getIconStringWithState:_issueState];
                    cell.titleLabel.text =  _issueTitle;
                    cell.titleLabel.font =[UIFont systemFontOfSize:17];
                    cell.titleLabel.textColor = [UIColor titleColor];
                    
                    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
                    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
                    
                    if ([_issueTitle length] > 0) {
                        BOOL isFinish = [_issueState isEqualToString:@"accepted"] || [_issueState isEqualToString:@"closed"];
                        [self editTextAtLabel:cell.titleLabel isStateClosed:isFinish];
                    }
                }else {
                    cell.titleLabel.font =[UIFont systemFontOfSize:15];
                    cell.titleLabel.textColor = [UIColor grayColor];
                    cell.titleLabel.text = tempDic[@"title"];
                }
            }else if ([tempDic[@"cellLevel"] intValue] == 2) {   //cellLevel=2 子任务的cell
                cell = [tableView dequeueReusableCellWithIdentifier:kTeamIssueDetailCellSubChild];
                
                NSDictionary *tempDic = _originDatas[indexPath.row];
                [cell.portraitIv loadPortrait:tempDic[@"portraitUrl"]];
                cell.descriptionLabel.text = tempDic[@"title"];
                cell.iconLabel.text = tempDic[@"icon"];
                
                BOOL isStateClosed = [tempDic[@"childIssueState"] isEqualToString:@"closed"];
                [self editTextAtLabel:cell.descriptionLabel isStateClosed:isStateClosed];
            }
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:kTeamIssueDetailCellRemark];
            cell.iconLabel.text = tempDic[@"icon"];
            if (_detailIssue.issueLabels.count > 0) {
                [cell setupRemarkLabelsWithtexts:_detailIssue.issueLabels];
            }
        }
        return cell;
    }else {
        UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row > _originDatas.count || indexPath.section == 1) {
        return;
    }
     NSDictionary *selectedIssue = [_originDatas objectAtIndex:indexPath.row];
    //更改主任务状态
    if ((indexPath.row == 0 && indexPath.section == 0) || [selectedIssue[@"icon"] isEqualToString:@"\uf080"]) {
        if (_detailIssue.authority.authUpdateState) {
            [self showIssueState];
        }else {
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.label.text = @"对不起，您无权更改任务状态";
            [HUD hideAnimated:YES afterDelay:1];
        }
        return;
    }
   
    if ([selectedIssue[@"cellLevel"] intValue] == 1) {
        
        if ([selectedIssue[@"title"] isEqualToString:@"子任务"]) {
            if (_isOpeningSubIssue) {   //关闭子任务
                NSIndexSet *sets = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row+1, _subIssueInfos.count)];
                [_originDatas removeObjectsAtIndexes:sets];
                [_descriptions removeObjectsAtIndexes:sets];
                NSMutableArray *pathArray = [NSMutableArray new];
                for (int k=1; k<=_subIssueInfos.count; k++) {
                    NSIndexPath *path = [NSIndexPath indexPathForItem:(indexPath.row+k) inSection:indexPath.section];
                    [pathArray addObject:path];
                }
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:pathArray withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
            }else {     //展开子任务
                if (_handledSubIssueInfos.count <= 0) {
                    return;
                }
                NSMutableArray *pathArray = [NSMutableArray new];
                for (int k=1; k<=_handledSubIssueInfos.count; k++) {
                    NSIndexPath *path = [NSIndexPath indexPathForItem:(indexPath.row+k) inSection:indexPath.section];
                    [pathArray addObject:path];
                }
                NSIndexSet *sets = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row+1, _handledSubIssueInfos.count)];
                [_originDatas insertObjects:_handledSubIssueInfos atIndexes:sets];
                [_descriptions insertObjects:_handledSubIssueInfos atIndexes:sets];

                [tableView beginUpdates];
                [tableView insertRowsAtIndexPaths:pathArray withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
            }
            _isOpeningSubIssue = !_isOpeningSubIssue;
        }
    } else {
        NSString *selectedIssueId = [selectedIssue objectForKey:@"childIssueId"];
        int arrayIndex = [[selectedIssue objectForKey:@"arrayIndex"] intValue];
        TeamIssueDetailCell *selectedCell = (TeamIssueDetailCell*)[tableView cellForRowAtIndexPath:indexPath];
        NSString *selectedIssueState = [selectedIssue[@"childIssueState"] isEqualToString:@"opened"] ? @"closed":@"opened";      //当前状态是否为关闭状态
        [self changeChildIssueStateWithIssueId:selectedIssueId newState:selectedIssueState arrayIndex:arrayIndex selectedCell:selectedCell];
    }
}
#pragma mark -- 更改子任务状态
-(void)changeChildIssueStateWithIssueId:(NSString*)issueId newState:(NSString*)newState arrayIndex:(int)arrayIndex selectedCell:(TeamIssueDetailCell*)selectedCell
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_ISSUE_UPDATE_CHILD_ISSUE];
    NSDictionary *parameters = @{
                                 @"teamid": @(_teamId),
                                 @"issueid": @(_issueId),
                                 @"uid":@([Config getOwnID]),
                                 @"childissueid":issueId,
                                 @"state":newState,
                                 @"target":@"state"
                                 };
    [manager POST:url
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              int errorCode = [[[[responseObject.rootElement firstChildWithTag:@"result"] firstChildWithTag:@"errorCode"] numberValue] intValue];
              if (errorCode == 1) {
                  selectedCell.iconLabel.text = [selectedCell.iconLabel.text isEqualToString:@"\uf192"]?@"\uf10c":@"\uf192";
                  //更改本地存储的子任务状态
                  if (arrayIndex < _handledSubIssueInfos.count) {
                      NSMutableDictionary *changedChildIssue = [_handledSubIssueInfos objectAtIndex:arrayIndex];
                      [changedChildIssue removeObjectForKey:@"icon"];
                      [changedChildIssue setObject:selectedCell.iconLabel.text forKey:@"icon"];
                      [changedChildIssue removeObjectForKey:@"childIssueState"];
                      [changedChildIssue setObject:newState forKey:@"childIssueState"];
                  }

                  //画中线
                  BOOL isStateClosed = [newState isEqualToString:@"closed"];
                  [self editTextAtLabel:selectedCell.descriptionLabel isStateClosed:isStateClosed];
              }
              NSString *alertMsg = [[[responseObject.rootElement firstChildWithTag:@"result"] firstChildWithTag:@"errorMessage"] stringValue];
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.label.text = alertMsg;
              [HUD hideAnimated:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
          }];
}
#pragma mark -- 设置子任务状态数据
-(void)setupSubIssueCellData
{
    _handledSubIssueInfos = [NSMutableArray new];
    for (int index=0; index<_subIssueInfos.count; index++) {
        TeamIssue *issue = [_subIssueInfos objectAtIndex:index];
        NSString *iconString = [issue.state isEqualToString:@"opened"]?@"\uf10c":@"\uf192";
        NSURL *portraitUrl = issue.author.portraitURL ?: [NSURL URLWithString:@""];
        NSString *subIssueTitle = issue.title ?: @"";
        NSString *issueId = [NSString stringWithFormat:@"%d",issue.issueID] ?: @"";
        NSString *arrayIndex = [NSString stringWithFormat:@"%d",index];
        NSMutableDictionary *subIssueDic = [NSMutableDictionary dictionaryWithDictionary:@{@"icon":iconString,
                                      @"title":subIssueTitle,
                                      @"portraitUrl":portraitUrl,
                                      @"cellLevel":@2,
                                      @"childIssueId":issueId,
                                      @"childIssueState":issue.state,
                                      @"arrayIndex":arrayIndex
                                      }];
        [_handledSubIssueInfos addObject:subIssueDic];
    }
}
#pragma mark -- util
-(void)editTextAtLabel:(UILabel*)label isStateClosed:(BOOL)isStateClosed
{
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:label.text];
    if (isStateClosed) {    //添加中线
        [content addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [label.text length])];
        label.textColor = [UIColor grayColor];
    }else {     //去掉中线
        [content addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleNone] range:NSMakeRange(0, [label.text length])];
        label.textColor = [UIColor titleColor];
    }
    label.attributedText = content;
}

-(NSString*)getChineseNameWithState:(NSString*)state
{
    NSString *translatedState;
    if ([state isEqualToString:@"opened"]) {
        translatedState = @"待办中";
    }else if ([state isEqualToString:@"underway"]) {
        translatedState = @"进行中";
    }else if ([state isEqualToString:@"closed"]) {
        translatedState = @"已完成";
    }else if ([state isEqualToString:@"accepted"]) {
        translatedState = @"已验收";
    }else {
        translatedState = @"";
    }
    return translatedState;
}
-(NSString*)getStateWithChineseName:(NSString*)state
{
    NSString *translatedState;
    if ([state isEqualToString:@"待办中"]) {
        translatedState = @"opened";
    }else if ([state isEqualToString:@"进行中"]) {
        translatedState = @"underway";
    }else if ([state isEqualToString:@"已完成"]) {
        translatedState = @"closed";
    }else if ([state isEqualToString:@"已验收"]) {
        translatedState = @"accepted";
    }else {
        translatedState = @"";
    }
    return translatedState;
}

-(NSString*)getIconStringWithState:(NSString*)state
{
    NSString *iconString;
    
    if ([state isEqualToString:@"opened"]) {
        iconString = @"\uf10c";
    }else if ([state isEqualToString:@"underway"]) {
        iconString = @"\uf192";
    }else if ([state isEqualToString:@"closed"]) {
        iconString = @"\uf05d";
    }else if ([state isEqualToString:@"accepted"]) {
        iconString = @"\uf023";
    }else {
        iconString = @"";
    }
    return iconString;
}
#pragma mark -- 显示任务状态
-(void)showIssueState
{
    NSString * stateString = [self getChineseNameWithState:_issueState];
    NSString * showString = [NSString stringWithFormat:@"当前状态：%@",stateString];
    
    NSMutableDictionary *allState = [NSMutableDictionary dictionaryWithDictionary:@{@"opened":@"待办中",@"underway":@"进行中",@"closed":@"已完成",@"accepted":@"已验收"}];
    [allState removeObjectForKey:_issueState];
    
    UIAlertView *stateAlertView = [[UIAlertView alloc]initWithTitle:@"选择任务状态" message:showString delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    for (NSString *stateString in [allState allValues]) {
        [stateAlertView addButtonWithTitle:stateString];
    }
    [stateAlertView show];
}
#pragma mark -- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *selectedState = [alertView buttonTitleAtIndex:buttonIndex];
    if (![selectedState isEqualToString:@"取消"]) {
        NSString *newState = [self getStateWithChineseName:selectedState];
        [self changeIssueStateWithNewState:newState];
    }
}
#pragma mark -- 更改任务状态
-(void)changeIssueStateWithNewState:(NSString*)newState
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_ISSUE_UPDATE_STATE];
    NSDictionary *parameters = @{
                                 @"teamid": @(_teamId),
                                 @"issueid": @(_issueId),
                                 @"uid":@([Config getOwnID]),
                                 @"state":newState
                                 };
    [manager POST:url
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             int errorCode = [[[[responseObject.rootElement firstChildWithTag:@"result"] firstChildWithTag:@"errorCode"] numberValue] intValue];
             if (errorCode == 1) {
                 _issueState = newState;
                 //更改标题cell状态
                 NSIndexPath *titleCellPath = [NSIndexPath indexPathForItem:0 inSection:0];
                 TeamIssueDetailCell *issueTitleCell = (TeamIssueDetailCell*)[self.tableView cellForRowAtIndexPath:titleCellPath];
                 if (issueTitleCell) {
                     issueTitleCell.iconLabel.text = [self getIconStringWithState:newState];
                     BOOL isFinish = [newState isEqualToString:@"accepted"] || [newState isEqualToString:@"closed"];
                     [self editTextAtLabel:issueTitleCell.titleLabel isStateClosed:isFinish];
                     
                 }
                 //更改阶段cell状态
                 //5:在原始数组_originDatas中，阶段cell与标题cell中间隔5个元素。
                 NSInteger itemIndex = _isOpeningSubIssue ? 5+_subIssueInfos.count : 5;
                 NSIndexPath *stageCellPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
                 //更新任务信息数据
                 NSString *newStateInChinese = [self getChineseNameWithState:newState];
                 [_descriptions removeObjectAtIndex:itemIndex];
                 [_descriptions insertObject:newStateInChinese atIndex:itemIndex];
                 
                 TeamIssueDetailCell *issueStageCell = (TeamIssueDetailCell*)[self.tableView cellForRowAtIndexPath:stageCellPath];
                 issueStageCell.descriptionLabel.text = newStateInChinese;
             }
             
             
             NSString *alertMsg = [[[responseObject.rootElement firstChildWithTag:@"result"] firstChildWithTag:@"errorMessage"] stringValue];
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.label.text = alertMsg;
             [HUD hideAnimated:YES afterDelay:1];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}

#pragma 发表评论

- (void)sendContent
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.label.text = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSDictionary *parameter = @{
                                @"teamid": @(_teamId),
                                @"uid": @([Config getOwnID]),
                                @"issueid": @(_issueId),
                                @"content": [Utils convertRichTextToRawText:self.editingBar.editView]
                                };
    [manager POST:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_ISSUE_REPLY]
       parameters:parameter
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"reply"];
              HUD.mode = MBProgressHUDModeCustomView;
              if (result != nil) {
                  self.editingBar.editView.text = @"";
                  [self updateInputBarHeight];
                  
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.label.text = @"评论发表成功";
                  
                  [self.tableView setContentOffset:CGPointZero animated:NO];
                  [self fetchRepliesOnPage:0];
              } else {
//                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.label.text = @"评论失败";;
              }
              
              [HUD hideAnimated:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              HUD.mode = MBProgressHUDModeCustomView;
//              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.detailsLabel.text = error.localizedFailureReason;
              
              [HUD hideAnimated:YES afterDelay:1];
          }];
}




@end
