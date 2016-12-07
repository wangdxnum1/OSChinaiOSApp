//
//  SoftwareCatalogVC.m
//  iosapp
//
//  Created by ChanAetern on 12/9/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "SoftwareCatalogVC.h"
#import "OSCSoftwareCatalog.h"
#import "OSCAPI.h"
#import "UIColor+Util.h"
#import "SoftwareListVC.h"

@interface SoftwareCatalogVC ()

@property (nonatomic, assign) int tag;

@end

static NSString * const kSoftwareCatalogCellID = @"SoftwareCatalogCell";

@implementation SoftwareCatalogVC

- (instancetype)initWithTag:(int)tag
{
    self = [super init];
    if (!self) {return nil;}
    
    _tag = tag;
    
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@?tag=%d", OSCAPI_PREFIX, OSCAPI_SOFTWARECATALOG_LIST, tag];
    };
    
    __weak SoftwareCatalogVC *weakSelf = self;
    self.tableWillReload = ^(NSUInteger responseObjectsCount) {
        weakSelf.lastCell.status = LastCellStatusFinished;
    };
    
    self.objClass = [OSCSoftwareCatalog class];
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"softwareTypes"] childrenWithTag:@"softwareType"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSoftwareCatalogCellID];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSoftwareCatalogCellID forIndexPath:indexPath];
    OSCSoftwareCatalog *softwareCatalog = self.objects[indexPath.row];
    
    cell.backgroundColor = [UIColor themeColor];
    cell.textLabel.text = softwareCatalog.name;
    cell.textLabel.textColor = [UIColor titleColor];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCSoftwareCatalog *softwareCatalog = self.objects[indexPath.row];
    if (_tag == 0) {
        SoftwareCatalogVC *softwareCatalogVC = [[SoftwareCatalogVC alloc] initWithTag:softwareCatalog.tag];
        [self.navigationController pushViewController:softwareCatalogVC animated:YES];
    } else {
        SoftwareListVC *softwareListVC = [[SoftwareListVC alloc] initWIthSearchTag:softwareCatalog.tag];
        [self.navigationController pushViewController:softwareListVC animated:YES];
    }
}


@end
