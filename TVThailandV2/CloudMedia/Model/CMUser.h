//
//  CMUser.h
//  CloudMedia
//
//  Created by April Smith on 10/3/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMApiClient.h"

@interface CMUser : NSObject

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *memberId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *tel;
@property (nonatomic, strong) NSString *birthDate;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *creditAmount;
@property (nonatomic, strong) NSString *birthDay;
@property (nonatomic, strong) NSString *birthMonth;
@property (nonatomic, strong) NSString *birthYear;

+ (CMUser *) sharedInstance;

- (void)setWithDictionary:(NSDictionary *)dictionary;

- (BOOL)isLogin;
- (void)clear;

+ (void)loginWithUsername:(NSString *)username password:(NSString*)password Block:(void (^)(BOOL isSuccess,NSString *message, NSError *error))block;
+ (void)loadUserProfile:(NSString *)movieID Block:(void (^)(BOOL isSuccess, NSError *error))block;
+ (void)registerWithUsername:(NSString *)username tel:(NSString *)tel email:(NSString *)email Block:(void (^)(BOOL isSuccess,NSString *referenceID,NSString *regID,NSString *message, NSError *error))block;
+ (void)registerConfirmWihtOTP:(NSString *)otp referenceID:(NSString *)referenceID regID:(NSString *)regID Block:(void (^)(BOOL isSuccess,NSString *message, NSError *error))block;
+ (void)forgotPasswordWithEmail:(NSString *)email tel:(NSString *)tel Block:(void (^)(BOOL isSuccess,NSString *message, NSError *error))block;

+ (void)requestOTPUpdateProfileBlock:(void (^)(BOOL isSuccess,NSString *referenceID,NSString *message, NSError *error))block;
+ (void)confirmUpdateProfileWithOTP:(NSString *)otp referenceID:(NSString *)referenceID firstname:(NSString *)firstname lastname:(NSString *)lastname birthdate:(NSString *)birthdate birthday:(NSString *)birthday birthmonth:(NSString *)birthmonth birthyear:(NSString *)birthyear sex:(NSString *)sex tel:(NSString *)tel email:(NSString *)email Block:(void (^)(BOOL isSuccess,NSString *message, NSError *error))block;

+ (void)changePasswordWithOldPassword:(NSString *)oldpassword aNewPassword:(NSString *)aNewPasswrod confirmNewPassword:(NSString *)confirmNewPassword Block:(void (^)(BOOL isSuccess,NSString *message, NSError *error))block;

@end
