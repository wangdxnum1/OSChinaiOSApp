//
//  TeamMember.h
//  iosapp
//
//  Created by ChanAetern on 4/15/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface TeamMember : OSCBaseObject

@property (nonatomic, assign) int memberID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *oscName;
@property (nonatomic, strong) NSURL *portraitURL;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *telephone;
@property (nonatomic, copy) NSString *teamJob;
@property (nonatomic, assign) int teamRole;
@property (nonatomic, strong) NSURL *space;
@property (nonatomic, strong) NSDate *joinTime;
@property (nonatomic, copy) NSString *location;

- (instancetype)initWithCollaboratorXML:(ONOXMLElement *)xml;   //协助者
@end
