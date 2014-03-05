//
//  CMUser.h
//  TVThailandV2
//
//  Created by April Smith on 3/4/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMUser : NSObject

@property (nonatomic,strong) NSString *fbId;
@property (nonatomic,strong) NSString *displayName;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *firstName;
@property (nonatomic,strong) NSString *lastName;
@property (nonatomic,strong) NSString *birthday;
@property (nonatomic,strong) NSString *gender;



+ (CMUser *) sharedInstance;
- (void) setWithDictionary:(NSDictionary *)dictionary;
- (void) clear;
@end
