//
//  SoftwareListVC.m
//  iosapp
//
//  Created by ChanAetern on 12/9/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "SoftwareListVC.h"
#import "OSCSoftware.h"
#import "SoftwareCell.h"
#import "DetailsViewController.h"
#import "SoftWareViewController.h"

static NSString * const kSoftwareCellID = @"SoftwareCell";

@implementation SoftwareListVC

- (instancetype)initWithSoftwaresType:(SoftwaresType)softwareType
{
    self = [super init];
    if (!self) {return nil;}
    
    NSString *searchTag;
    switch (softwareType) {
        case SoftwaresTypeRecommended:
            searchTag = @"recommend"; break;
        case SoftwaresTypeNewest:
            searchTag = @"time"; break;
        case SoftwaresTypeHottest:
            searchTag = @"view"; break;
        case SoftwaresTypeCN:
            searchTag = @"list_cn"; break;
    }
    
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@?searchTag=%@&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_SOFTWARE_LIST, searchTag, (unsigned long)page, OSCAPI_SUFFIX];
    };
    
    self.objClass = [OSCSoftware class];
    
    return self;
}

- (instancetype)initWIthSearchTag:(int)searchTag
{
    if (self = [super init]) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?searchTag=%d&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_SOFTWARETAG_LIST, searchTag, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.objClass = [OSCSoftware class];
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"softwares"] childrenWithTag:@"software"];
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[SoftwareCell class] forCellReuseIdentifier:kSoftwareCellID];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SoftwareCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSoftwareCellID forIndexPath:indexPath];
    OSCSoftware *software = self.objects[indexPath.row];
    
    cell.backgroundColor = [UIColor themeColor];
    cell.nameLabel.text = software.name;
    cell.descriptionLabel.text = software.softwareDescription;
    cell.nameLabel.textColor = [UIColor titleColor];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCSoftware *software = self.objects[indexPath.row];
    self.label.text = software.name;
    
    CGSize size = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)];
    
    return size.height + 39;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCSoftware *software = self.objects[indexPath.row];
    
    /* 新版软件详情 */
//    SoftWareViewController *detailSoftwareVC = [[SoftWareViewController alloc]initWithSoftWareID:software.softId];
//    [self.navigationController pushViewController:detailSoftwareVC animated:YES];
    
    /* 旧版软件详情 */
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithSoftware:software];
    [self.navigationController pushViewController:detailsViewController animated:YES];
}


@end
