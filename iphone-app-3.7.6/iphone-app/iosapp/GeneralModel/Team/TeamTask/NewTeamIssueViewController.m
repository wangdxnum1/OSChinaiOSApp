//
//  NewTeamIssueViewController.m
//  iosapp
//
//  Created by Holden on 15/5/21.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "NewTeamIssueViewController.h"
#import "TeamIssueDetailCell.h"
#import "TeamAPI.h"
#import "Config.h"
#import "Utils.h"
#import "CheckboxTableCell.h"
#import "TeamMember.h"
#import "TeamProject.h"
#import "TeamIssueList.h"
#import "TableViewCell.h"
#import "AppDelegate.h"

#import "NSString+FontAwesome.h"
#import "TeamCalendarView.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

static NSString *kteamIssueTitleCell = @"teamIssueTitleCell";

@interface NewTeamIssueViewController ()<DatePickViewDelegate>

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, assign) NSInteger selectedRow;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) NSMutableArray *members;
@property (nonatomic, strong) NSMutableArray *projects;
@property (nonatomic, strong) TeamProject *selectedProject;
@property (nonatomic, strong) NSMutableArray *issueGroups;

@property (nonatomic, strong) CheckboxTableCell *projectCell;
@property (nonatomic, strong) CheckboxTableCell *issueGroupCell;
@property (nonatomic, strong) CheckboxTableCell *memberCell;
@property (nonatomic, strong) CheckboxTableCell *deadlineCell;

@property (nonatomic, strong) TableViewCell *projectTableViewCell;
@property (nonatomic, strong) TableViewCell *issueGroupTableViewCell;
@property (nonatomic, strong) TableViewCell *memberTableViewCell;

@property (nonatomic, strong) TeamProject *project;
@property (nonatomic, strong) TeamIssueList *issueGroup;
@property (nonatomic, strong) TeamMember *member;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic,strong) CheckboxTableCell *calendarCell;
@property (nonatomic,copy) NSString *deadlineTime;
@property (nonatomic)int isSynchronous;      //1:同步，0:不同步
@property (nonatomic,strong)UILabel *syncLabel;
@end

@implementation NewTeamIssueViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _members = [NSMutableArray new];
        _projects = [NSMutableArray new];
        _issueGroups = [NSMutableArray new];
        _selectedRow = -2;
        
        _manager = [AFHTTPRequestOperationManager OSCManager];
        
        _projectCell = [[CheckboxTableCell alloc] initWithCellType:CellTypeProject];
        _issueGroupCell = [[CheckboxTableCell alloc] initWithCellType:CellTypeIssue];
        _memberCell = [[CheckboxTableCell alloc] initWithCellType:CellTypeMember];
        _deadlineCell = [[CheckboxTableCell alloc] initWithCellType:CellTypeTime];
        
        _projectTableViewCell = [TableViewCell new];
        _issueGroupTableViewCell = [TableViewCell new];
        _memberTableViewCell = [TableViewCell new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"新团队任务";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建" style:UIBarButtonItemStylePlain target:self action:@selector(pubNewIssue)];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor themeColor];
    
    self.tableView.bounces = NO;
    [self.tableView registerClass:[TeamIssueDetailCell class] forCellReuseIdentifier:kteamIssueDetailCellNomal];
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    _HUD = [[MBProgressHUD alloc] initWithView:window];
    _HUD.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    _HUD.userInteractionEnabled = NO;
    [window addSubview:_HUD];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode = [Config getMode];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark -- 发布新任务
-(void)pubNewIssue
{
    if ([_titleTextField.text length] <= 0) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
        HUD.label.text = @"请先输入任务标题";
        [HUD hideAnimated:YES afterDelay:1];
        return;
    }
    
    [_HUD showAnimated:YES];
    NSDictionary *parameters = @{
                                 @"teamid": @([Config teamID]),
                                 @"uid": @([Config getOwnID]),
                                 @"title": _titleTextField.text?:@"",
                                 @"project": @(_project.gitID),
                                 @"catalogid":@(_issueGroup.teamIssueID),
                                 @"source": _project.source?:@"Git@OSC",
                                 @"gitpush": @(_isSynchronous),    //是否同步,推送：1；不推送：0
                                 @"to_user": @(_member.memberID),    //指派给的人的id
                                 @"deadline_time": _deadlineTime?:@""    //完成时间
                                 };
    [_manager POST:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_ISSUE_PUB]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              [_HUD hideAnimated:YES];
              
              ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];

              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              if (errorCode == 1) {
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.label.text = errorMessage;
                  [self.navigationController popViewControllerAnimated:YES];
              } else {
//                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  if ([errorMessage length] < 10) {
                      HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  }else {
                      HUD.detailsLabel.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  }
              }
              [HUD hideAnimated:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [_HUD hideAnimated:YES];
          }];
    
}
//是否同步到gitHub或gitOsc
-(void)selectSyncOption:(UITapGestureRecognizer*)tap
{
    UIView *syncView = tap.view;
    UILabel *flagLabel = (UILabel*)[syncView viewWithTag:108];
    flagLabel.text = [flagLabel.text isEqualToString:@"\uf046"]?@"\uf096":@"\uf046";
    _isSynchronous = [flagLabel.text isEqualToString:@"\uf046"]?1:0;
}
//footerView
-(UIView*)setupSyncView
{
    UIView *syncView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, CGRectGetWidth([[UIScreen mainScreen] bounds]), 60)];
    [syncView setBackgroundColor:[UIColor themeColor]];
    
    syncView.userInteractionEnabled = YES;
    [syncView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectSyncOption:)]];
    
    UILabel *syncTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 150, CGRectGetHeight(syncView.frame))];
    syncTitleLabel.textColor = [UIColor colorWithHex:0x555555];
    syncTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    syncTitleLabel.text = @"同步到Git@OSC";    //默认
    _syncLabel = syncTitleLabel;
    [syncView addSubview:syncTitleLabel];
    
    UILabel *syncFlagLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth([[UIScreen mainScreen] bounds])-35, 0, 25, 25)];
    syncFlagLabel.center = CGPointMake(syncFlagLabel.center.x, syncTitleLabel.center.y);
    syncFlagLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:16];
    syncFlagLabel.textColor = [UIColor grayColor];
    syncFlagLabel.tag = 108;
    syncFlagLabel.text = @"\uf096";
    [syncView addSubview:syncFlagLabel];
    
    UIView *bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(syncView.frame)-.5, CGRectGetWidth(syncView.frame), .5)];
    bottomLineView.backgroundColor = [UIColor lightGrayColor];
    [syncView addSubview:bottomLineView];
    
    return syncView;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_HUD hideAnimated:YES];
}


#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tableView.tableFooterView == nil)
    {
        self.tableView.tableFooterView = [self setupSyncView];
    }
    
    if(!_project.gitPush)
        self.tableView.tableFooterView.hidden = YES;
    else
        self.tableView.tableFooterView.hidden = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _selectedRow < 0? 5 : 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedRow + 1) {
        if (_selectedRow == 1) {return _projects.count > 4? 200 : (_projects.count + 1) * 40;}
        if (_selectedRow == 2) {return _issueGroups.count > 4? 200 : _issueGroups.count * 40;}
        if (_selectedRow == 3) {return _members.count > 4? 200 : (_members.count + 1) * 40;}
        if (_selectedRow == 4) {return 256;}
        
        return 200;
    } else {
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row;
    if (indexPath.row <= _selectedRow || _selectedRow <= 0) {
        row = indexPath.row;
    } else if (indexPath.row == _selectedRow + 1) {
        row = _selectedRow + 1;
    } else {
        row = indexPath.row - 1;
    }
    
    if (row == 0) {
        UITableViewCell *cell = [UITableViewCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor themeColor];
        _titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 5, CGRectGetWidth([[UIScreen mainScreen] bounds])-40, CGRectGetHeight(cell.frame)-10)];
        _titleTextField.placeholder = @"任务标题";
        _titleTextField.textColor = [UIColor titleColor];
        if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
            _titleTextField.keyboardAppearance = UIKeyboardAppearanceDark;
            [_titleTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        }
        [cell addSubview:_titleTextField];
        
        return cell;
    } else if (row == _selectedRow + 1) {
        __weak typeof(self) weakSelf = self;
        
        if (_selectedRow == 1) {
            if (!_projectTableViewCell.dataSourceSet) {
                [_projectTableViewCell setContentWithDataSource:_projects ofType:DataSourceTypeProject];
                
                _projectTableViewCell.selectRow = ^ (NSInteger row) {
                    weakSelf.projectCell.descriptionLabel.text = weakSelf.projectTableViewCell.title;
                    
                    if (row == 0) {
                        weakSelf.project = nil;
                    } else {
                        TeamProject *project = weakSelf.projects[row-1];
                        if (project.projectID != weakSelf.project.projectID) {
                            weakSelf.project = project;
                            weakSelf.issueGroup = nil;
                            weakSelf.member = nil;
                            [weakSelf.issueGroups removeAllObjects];
                            [weakSelf.members removeAllObjects];
                            
                            weakSelf.issueGroupCell.descriptionLabel.text = @"未指定列表";
                            weakSelf.memberCell.descriptionLabel.text = @"未指派";
                        }
                        weakSelf.syncLabel.text = [NSString stringWithFormat:@"同步到%@",project.source];
                        if(!weakSelf.project.gitPush)
                            weakSelf.tableView.tableFooterView.hidden = YES;
                        else
                            weakSelf.tableView.tableFooterView.hidden = NO;
                    }
                    
                    [weakSelf collapseExpandedCell];
                };
            }
            return _projectTableViewCell;
        } else if (_selectedRow == 2) {
            if (!_issueGroupTableViewCell.dataSourceSet) {
                [_issueGroupTableViewCell setContentWithDataSource:_issueGroups ofType:DataSourceTypeIssueGroup];
                
                _issueGroupTableViewCell.selectRow = ^ (NSInteger row) {
                    weakSelf.issueGroupCell.descriptionLabel.text = weakSelf.issueGroupTableViewCell.title;
                    weakSelf.issueGroup = weakSelf.issueGroups[row];
                    
                    [weakSelf collapseExpandedCell];
                };
            }
            return _issueGroupTableViewCell;
        } else if (_selectedRow == 3) {
            if (!_memberTableViewCell.dataSourceSet) {
                [_memberTableViewCell setContentWithDataSource:_members ofType:DataSourceTypeMember];
                
                _memberTableViewCell.selectRow = ^ (NSInteger row) {
                    weakSelf.memberCell.descriptionLabel.text = weakSelf.memberTableViewCell.title;
                    
                    if (row == 0) {
                        weakSelf.member = nil;
                    } else {
                        weakSelf.member = weakSelf.members[row-1];
                    }
                    
                    [weakSelf collapseExpandedCell];
                };
            }
            return _memberTableViewCell;
        } else {
            UITableViewCell *cell = [UITableViewCell new];
            TeamCalendarView *calendarView = [[TeamCalendarView alloc] initWithSelectedDate:[self getDateWithString:_calendarCell.descriptionLabel.text]];
            calendarView.delegate = self;
            [cell.contentView addSubview:calendarView];
            
            return cell;
        }
    } else {
        return @[_projectCell, _issueGroupCell, _memberCell, _deadlineCell][row-1];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_titleTextField resignFirstResponder];
    
    if (indexPath.row != 0) {
        if (_selectedRow > 0) {
            [self collapseExpandedCell];
            [_calendarCell layoutSubviews];
            return;
        } else {
            _selectedRow = indexPath.row;
        }
        
        switch (indexPath.row) {
            case 1: {
                if (_projects.count) {
                    [tableView beginUpdates];
                    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                     withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];
                } else {
                    [_HUD showAnimated:YES];
                    
                    [_manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_PROJECT_LIST]
                       parameters:@{@"teamid": @([Config teamID])}
                          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                              NSArray *projectsXML = [[responseObject.rootElement firstChildWithTag:@"projects"] childrenWithTag:@"project"];
                              
                              for (ONOXMLElement *projectXML in projectsXML) {
                                  TeamProject *teamProject = [[TeamProject alloc] initWithXML:projectXML];
                                  [_projects addObject:teamProject];
                              }
                              
                              [tableView beginUpdates];
                              [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                               withRowAnimation:UITableViewRowAnimationFade];
                              [tableView endUpdates];
                              
                              [_HUD hideAnimated:YES];
                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              [_HUD hideAnimated:YES];
                          }];
                }
            }
                break;
            case 2: {
                if (_issueGroups.count) {
                    [tableView beginUpdates];
                    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                     withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];
                } else {
                    [_HUD showAnimated:YES];
                    
                    [_manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_PROJECT_CATALOG_LIST]
                       parameters:@{
                                    @"uid": @([Config getOwnID]),
                                    @"teamid": @([Config teamID]),
                                    @"projectid": @(_project.gitID),
                                    @"source": _project.source ?: @"Team@OSC"
                                    }
                          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                              NSArray *issueGroupsXML = [[responseObject.rootElement firstChildWithTag:@"catalogs"] childrenWithTag:@"catalog"];
                              
                              for (ONOXMLElement *issueGroupXMl in issueGroupsXML) {
                                  TeamIssueList *issueGroup = [[TeamIssueList alloc] initWithXML:issueGroupXMl];
                                  [_issueGroups addObject:issueGroup];
                              }
                              
                              _issueGroupTableViewCell.dataSourceSet = NO;
                              
                              [tableView beginUpdates];
                              [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                               withRowAnimation:UITableViewRowAnimationFade];
                              [tableView endUpdates];
                              
                              [_HUD hideAnimated:YES];
                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              [_HUD hideAnimated:YES];
                          }];
                }
            }
                break;
            case 3: {
                if (_members.count) {
                    [tableView beginUpdates];
                    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                     withRowAnimation:UITableViewRowAnimationFade];
                    [tableView endUpdates];
                } else {
                    [_HUD showAnimated:YES];
                    
                    [_manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_PROJECT_MEMBER_LIST]
                       parameters:@{
                                    @"uid": @([Config getOwnID]),
                                    @"teamid": @([Config teamID]),
                                    @"projectid": @(_project.gitID),
                                    @"source": _project.source ?: @"Team@OSC"
                                    }
                          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                              NSArray *membersXML = [[responseObject.rootElement firstChildWithTag:@"members"] childrenWithTag:@"member"];
                              
                              for (ONOXMLElement *memberXML in membersXML) {
                                  TeamMember *teamMember = [[TeamMember alloc] initWithXML:memberXML];
                                  [_members addObject:teamMember];
                              }
                              
                              _memberTableViewCell.dataSourceSet = NO;
                              
                              [tableView beginUpdates];
                              [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                               withRowAnimation:UITableViewRowAnimationFade];
                              [tableView endUpdates];
                              
                              [_HUD hideAnimated:YES];
                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              [_HUD hideAnimated:YES];
                          }];
                }
                break;
            }
            case 4: {
                [tableView beginUpdates];
                [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]]
                                 withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
                
                _calendarCell =  (CheckboxTableCell*)[tableView cellForRowAtIndexPath:indexPath];
            }
                break;
                
            default: break;
        }
    }
}

- (void)collapseExpandedCell
{
    if (_selectedRow < 0) {return;}
    
    NSInteger preRow = _selectedRow;
    _selectedRow = -2;
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:preRow + 1 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}


#pragma mark -- NSString<---->NSDate 
- (NSDate*)getDateWithString:(NSString*)dateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[formatter dateFromString:dateStr];
    return date;
}
- (NSString*)getDateStringWithDate:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}


#pragma mark -- DatePickerViewDelegate

- (void)didSelectDate:(NSDate *)date
{
    _calendarCell.descriptionLabel.text = [self getDateStringWithDate:date];
    _deadlineTime = _calendarCell.descriptionLabel.text;
    [self removeCalendarViewCell];
    [_calendarCell layoutSubviews];
}

- (void)clearSelectedDate
{
    _calendarCell.descriptionLabel.text = @"";
    _deadlineTime = _calendarCell.descriptionLabel.text;
    [self removeCalendarViewCell];
    [_calendarCell layoutSubviews];
}

-(void)removeCalendarView
{
    [self removeCalendarViewCell];
    [_calendarCell layoutSubviews];
}


#pragma mark -- 移除日历cell

- (void)removeCalendarViewCell
{
    if (_selectedRow > 0) {
        NSInteger preRow = _selectedRow;
        _selectedRow = -2;
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:preRow + 1 inSection:0]]
                         withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        return;
    } else {
        _selectedRow = [self.tableView indexPathForCell:_calendarCell].row;
    }
}

@end
