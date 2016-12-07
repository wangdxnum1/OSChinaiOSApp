//
//  TeamMemberViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 3/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamMemberViewController.h"
#import "TeamAPI.h"
#import "TeamMember.h"
#import "MemberCell.h"
#import "Utils.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import "Config.h"
#import "TeamMemberDetailViewController.h"

static NSString * const kMemberCellID = @"MemberCell";

@interface TeamMemberViewController ()

@property (nonatomic, assign) int teamID;
@property (nonatomic, assign) int projectID;
@property (nonatomic, copy) NSString *source;

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, strong) NSMutableArray *members;

@end

@implementation TeamMemberViewController

- (instancetype)initWithTeamID:(int)teamID
{
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    flowLayout.minimumInteritemSpacing = (screenWidth - 40 - 30 * 7) / 7;
    flowLayout.minimumLineSpacing = 25;
    flowLayout.itemSize = CGSizeMake(100, 100);
    flowLayout.sectionInset = UIEdgeInsetsMake(15, 0, 5, 0);
    
    self = [super initWithCollectionViewLayout:flowLayout];
    self.hidesBottomBarWhenPushed = YES;
    
    if (self) {
        _teamID = teamID;
        _URL = [NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_MEMBER_LIST];
        
        _members = [NSMutableArray new];
    }
    
    return self;
}

- (instancetype)initWithTeamID:(int)teamID projectID:(int)projectID andSource:(NSString *)source
{
    self = [self initWithTeamID:teamID];
    
    if (self) {
        _projectID = projectID;
        _source = [source copy];
        
        _URL = [NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_PROJECT_MEMBER_LIST];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[MemberCell class] forCellWithReuseIdentifier:kMemberCellID];
    self.collectionView.backgroundColor = [UIColor themeColor];
    
    self.collectionView.mj_header = ({
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        header;
    });
    
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return (_members.count + 2 ) / 3;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger left = _members.count - section * 3;
    return left >= 3 ? 3: left;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMemberCellID forIndexPath:indexPath];
    TeamMember *member = _members[indexPath.section * 3 + indexPath.row];
    
    [cell setContentWithMember:member];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TeamMember *member = _members[indexPath.section * 3 + indexPath.row];
    TeamMemberDetailViewController *memberDetailVC = [[TeamMemberDetailViewController alloc]initWithUId:member.memberID];
    [self.navigationController pushViewController:memberDetailVC animated:YES];
}


#pragma mark - 更新数据

- (void)refresh
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:_URL
      parameters:@{
                   @"teamid": @(_teamID),
                   @"projectid": @(_projectID),
                   @"source": _source ?: @""
                   }
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             NSArray *membersXML = [[responseObject.rootElement firstChildWithTag:@"members"] childrenWithTag:@"member"];
             
             [self.collectionView.mj_header endRefreshing];
             
             [_members removeAllObjects];
             
             for (ONOXMLElement *memberXML in membersXML) {
                 TeamMember *teamMember = [[TeamMember alloc] initWithXML:memberXML];
                 [_members addObject:teamMember];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.collectionView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             [self.collectionView.mj_header endRefreshing];
         }];
}


@end
