
//
//  CMUser.m
//  CloudMedia
//
//  Created by April Smith on 10/3/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import "CMUser.h"
#import "AFJSONRequestOperation.h"
#import "CMApiClient.h"
#import "SVProgressHUD.h"

@implementation CMUser

NSString * const kToken = @"token";
NSString * const kMemberId = @"memberId";
NSString * const kUserName = @"userName";
NSString * const kFirstName = @"firstName";
NSString * const kLastName = @"lastName";
NSString * const kSex = @"sex";
NSString * const kTel = @"tel";
NSString * const kEmail = @"email";
NSString * const kCreditAmount = @"creditAmount";
NSString * const kBirthDay = @"birthday";
NSString * const kBirthMonth = @"birthmonth";
NSString * const kBirthYear = @"birthyear";
NSString * const kBirthDate = @"birthdate";



+ (CMUser *) sharedInstance {
    static CMUser *__sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[CMUser alloc] initWithSaved];
    });
    
    return __sharedInstance;
}

- (id)initWithSaved {
    self = [super init];
    if (self) {
        [self reloadFromSaved];
    }
    return self;
}

- (void)setWithDictionary:(NSDictionary *)dictionary{
    
    _token = [dictionary objectForKey:kToken];
    _memberId  = [dictionary objectForKey:kMemberId];
    _userName = [dictionary objectForKey:kUserName];
    _firstName = [dictionary objectForKey:kFirstName]!= [NSNull null]?[dictionary objectForKey:kFirstName]:@"";
    _lastName = [dictionary objectForKey:kLastName]!= [NSNull null]?[dictionary objectForKey:kLastName]:@"";
    _sex = [dictionary objectForKey:kSex]!= [NSNull null]?[dictionary objectForKey:kSex]:@"";
    _tel = [dictionary objectForKey:kTel];
    _email = [dictionary objectForKey:kEmail];
    _creditAmount = [dictionary objectForKey:kCreditAmount];
    _birthDay = [dictionary objectForKey:kBirthDay];
    _birthMonth = [dictionary objectForKey:kBirthMonth];
    _birthYear = [dictionary objectForKey:kBirthYear];
    _birthDate = [NSString stringWithFormat:@"%@-%@-%@",_birthDay,_birthMonth,_birthYear];
    [self save];
    
}

- (NSString *)description {
    //TODO: print model
    return [NSString stringWithFormat:@"userName:%@, memberID:%@, token:%@, credit:%@, fristname:%@, lastname:%@, sex:%@, birthdate:%@"  , _userName,_memberId, _token,_creditAmount,_firstName,_lastName,_sex,_birthDate];
}

- (void)reloadFromSaved {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults setObject:_userName forKey:kUserName];
    _token = [defaults stringForKey:kToken];
    _memberId = [defaults stringForKey:kMemberId];
    _userName = [defaults stringForKey:kUserName];
    _firstName = [defaults stringForKey:kFirstName];
    _lastName = [defaults stringForKey:kLastName];
    _sex = [defaults stringForKey:kSex];
    _tel = [defaults stringForKey:kTel];
    _email = [defaults stringForKey:kEmail];
    _creditAmount = [defaults stringForKey:kCreditAmount];
    _birthDay = [defaults stringForKey:kBirthDay];
    _birthMonth = [defaults stringForKey:kBirthMonth];
    _birthYear = [defaults stringForKey:kBirthYear];
    _birthDate = [defaults stringForKey:kBirthDate];
    //TODO: load data to model
}

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_token forKey:kToken];
    [defaults setObject:_memberId forKey:kMemberId];
    [defaults setObject:_userName forKey:kUserName];
    [defaults setObject:_firstName forKey:kFirstName];
    [defaults setObject:_lastName forKey:kLastName];
    [defaults setObject:_sex forKey:kSex];
    [defaults setObject:_tel forKey:kTel];
    [defaults setObject:_email forKey:kEmail];
    [defaults setObject:_creditAmount forKey:kCreditAmount];
    [defaults setObject:_birthDay forKey:kBirthDay];
    [defaults setObject:_birthMonth forKey:kBirthMonth];
    [defaults setObject:_birthYear forKey:kBirthYear];
    [defaults setObject:_birthDate forKey:kBirthDate];
    //TODO: save all model
    
    [defaults synchronize];
}

- (void)clear{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@"" forKey:kToken];
    [defaults setObject:@"" forKey:kMemberId];
    [defaults setObject:@"" forKey:kUserName];
    [defaults setObject:@"" forKey:kFirstName];
    [defaults setObject:@"" forKey:kLastName];
    [defaults setObject:@"" forKey:kSex];
    [defaults setObject:@"" forKey:kTel];
    [defaults setObject:@"" forKey:kEmail];
    [defaults setObject:@"" forKey:kCreditAmount];
    [defaults setObject:@"" forKey:kBirthDay];
    [defaults setObject:@"" forKey:kBirthMonth];
    [defaults setObject:@"" forKey:kBirthYear];
    [defaults setObject:@"" forKey:kBirthDate];
    
    [defaults synchronize];
    
    [self reloadFromSaved];
}

#pragma mark - set data & save

- (void)setToken:(NSString *)token {
    _token = token;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:kToken];
    [defaults synchronize];
}

- (void)setMemberId:(NSString *)memberId{
    _memberId = memberId;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:memberId forKey:kMemberId];
    [defaults synchronize];
}

- (void)setUserName:(NSString *)userName {
    _userName = userName;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userName forKey:kUserName];
    [defaults synchronize];
}

- (void)setFirstName:(NSString *)firstName{
    _firstName = firstName;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:firstName forKey:kFirstName];
    [defaults synchronize];
}

- (void)setLastName:(NSString *)lastName{
    _lastName = lastName;
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    [defaults setObject:lastName forKey:kLastName];
}

- (void)setSex:(NSString *)sex{
    _sex = sex;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sex forKey:kSex];
}

- (void)setTel:(NSString *)tel{
    _tel = tel;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:tel forKey:kTel];
}

- (void)setEmail:(NSString *)email{
    _email = email;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:email forKey:kEmail];
}

- (void)setCreditAmount:(NSString *)creditAmount{
    _creditAmount = creditAmount;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:creditAmount forKey:kCreditAmount];
}

- (void)setBirthDay:(NSString *)birthDay{
    _birthDay = birthDay;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:birthDay forKey:kBirthDay];
}
- (void)setBirthMonth:(NSString *)birthMonth{
    _birthMonth = birthMonth;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:birthMonth forKey:kBirthMonth];
}
- (void)setBirthYear:(NSString *)birthYear{
    _birthYear = birthYear;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:birthYear forKey:kBirthYear];
}
- (void)setBirthDate:(NSString *)birthDate{
    _birthDate = birthDate;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:birthDate forKey:kBirthDate];
}



//TODO: set & save data model

- (BOOL)isLogin{
    if (![_token isEqualToString:@""]|| _token.length>0 ) {
        NSLog(@"isLogin = TRUE");
        return TRUE;
    }else{
        NSLog(@"isLoin = FALSE");
        return FALSE;
    }
    
}

+ (void)loginWithUsername:(NSString *)username password:(NSString*)password Block:(void (^)(BOOL isSuccess,NSString *message, NSError *error))block{
    NSDictionary *parameter = @{@"userName":username, @"password":password};
    CMApiClient *client = [CMApiClient sharedInstance];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    NSURLRequest *request =  [client requestWithMethod:@"POST" path:@"userprofiles/authentication" parameters:parameter];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             [SVProgressHUD dismiss];
                                             NSLog(@"%@",JSON);
                                             if ([[JSON objectForKey:@"status"] isEqualToString:@"S"]) {
                                                 //save User to NSUserDefaults
                                                 CMUser *user = [CMUser sharedInstance];
                                                 [user setWithDictionary:JSON];
                                                 if (block) {
                                                     block(YES,@"Login Successfully",nil);
                                                 }
                                                 
                                             }else{
                                                 [SVProgressHUD dismiss];
                                                 if (block) {
                                                     block(NO,[JSON objectForKey:@"description"],nil);
                                                 }
                                                 
                                             }
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"NSError: %@",error.localizedDescription);
                                             [SVProgressHUD dismiss];
                                             if (block) {
                                                 block(NO,@"Error",error);
                                             }
                                             
                                         }];
    
    [operation start];
    [SVProgressHUD showWithStatus:@"Login..."];
    
}

+ (void)loadUserProfile:(NSString *)movieID Block:(void (^)(BOOL isSuccess, NSError *error))block{
    CMUser *cmUser = [CMUser sharedInstance];
    NSString *path = [NSString stringWithFormat:@"userprofiles/memberId/%@",cmUser.memberId];
    CMApiClient *client = [CMApiClient sharedInstance];
    if (![cmUser.token isEqualToString:@""]) {
        [client setDefaultHeader:@"token" value:cmUser.token];
    }else{
        block(NO,nil);
        return;
    }
    [client getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"LoadUserProfile---------%@",responseObject);
        [cmUser setWithDictionary:responseObject];
        if (block) {
            block(YES,nil);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(block){
            NSLog(@"Fail-LoadUserProfile---------%@",error);
            block(NO,error);
        }
    }];
}

+ (void)registerWithUsername:(NSString *)username tel:(NSString *)tel email:(NSString *)email Block:(void (^)(BOOL isSuccess,NSString *referenceID,NSString *regID,NSString *message, NSError *error))block{
    NSDictionary *params = @{@"userName":username, @"tel":tel, @"email":email};
    
    CMApiClient *client = [CMApiClient sharedInstance];
    [client setParameterEncoding:AFJSONParameterEncoding];
    NSURLRequest *request =  [client requestWithMethod:@"POST" path:@"registrations" parameters:params];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             [SVProgressHUD dismiss];
                                             NSLog(@"%@",JSON);
                                             if ([[JSON objectForKey:@"status"] isEqualToString:@"S"]) {
                                                 NSString *referenceID = [JSON objectForKey:@"referenceId"];
                                                 NSString *regID = [JSON objectForKey:@"regId"];
                                                 NSString *message = [JSON objectForKey:@"description"]?[JSON objectForKey:@"description"]:@"OTP Code will sent to your email and SMS";
                                                 if (block) {
                                                     block(YES,referenceID,regID,message,nil);
                                                 }
                                                 
                                                 
                                             }else{
                                                 [SVProgressHUD dismiss];
                                                 NSString *message = [JSON objectForKey:@"description"]?[JSON objectForKey:@"description"]:@"Registeration not complete";
                                                 if (block) {
                                                     block(NO,nil,nil,message,nil);
                                                 }
                                                 
                                             }
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             [SVProgressHUD dismiss];
                                             NSLog(@"NSError: %@",error.localizedDescription);
                                             NSString *message = [JSON objectForKey:@"description"];
                                             message = message.length>0?[JSON objectForKey:@"description"]:@"Error";
                                             if (block) {
                                                 block(NO,nil,nil,message,error);
                                             }
                                             
                                         }];
    
    [operation start];
    [SVProgressHUD showWithStatus:@"Loading..."];
    
}

+ (void)registerConfirmWihtOTP:(NSString *)otp referenceID:(NSString *)referenceID regID:(NSString *)regID Block:(void (^)(BOOL isSuccess,NSString *message, NSError *error))block{
    NSDictionary *params = @{@"otp":otp,@"referenceId":referenceID,@"regId":regID};
    CMApiClient *client = [CMApiClient sharedInstance];
    [client setParameterEncoding:AFJSONParameterEncoding];
    NSURLRequest *request =  [client requestWithMethod:@"POST" path:@"registrations/confirmation" parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             
                                             NSLog(@"%@",JSON);
                                             if ([[JSON objectForKey:@"status"] isEqualToString:@"S"]) {
                                                 NSLog(@"Successfully confirmation OTP");
                                                 NSString *message = [JSON objectForKey:@"description"]?[JSON objectForKey:@"description"]:@"Registration confirmed!";
                                                 if (block) {
                                                     block(YES,message,nil);
                                                 }
                                                 
                                             }else{
                                                 NSString *message = [JSON objectForKey:@"description"]?[JSON objectForKey:@"description"]:@"Registration not complete!";
                                                 if (block) {
                                                     block(YES,message,nil);
                                                 }
                                                 
                                             }
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"NSError: %@",error.localizedDescription);
                                             NSString *message = [JSON objectForKey:@"description"];
                                             message = message.length>0?[JSON objectForKey:@"description"]:@"Error";
                                             if (block) {
                                                 block(NO,message,error);
                                             }
                                             
                                         }];
    
    [operation start];
}

+ (void)forgotPasswordWithEmail:(NSString *)email tel:(NSString *)tel Block:(void (^)(BOOL isSuccess,NSString *message, NSError *error))block{
    
    NSString *path = [NSString stringWithFormat:@"userprofiles/forgotpassword?email=%@&tel=%@",email,tel];
    CMApiClient *client = [CMApiClient sharedInstance];
    NSURLRequest *request =  [client requestWithMethod:@"POST" path:path parameters:nil];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             
                                             NSLog(@"%@",JSON);
                                             if ([[JSON objectForKey:@"status"] isEqualToString:@"S"]) {
                                                 
                                                 
                                                 NSString *message = [JSON objectForKey:@"description"]?[JSON objectForKey:@"description"]:@"Password will be sent to your email";
                                                 if (block) {
                                                     block(YES,message,nil);
                                                 }
                                                 
                                                 
                                             }else{
                                                 NSString *message = [JSON objectForKey:@"description"]?[JSON objectForKey:@"description"]:@"Fail to send password!";
                                                 if (block) {
                                                     block(NO,message,nil);
                                                 }
                                                 
                                             }
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"NSError: %@",error.localizedDescription);
                                             if (block) {
                                                 block(NO,@"Error",error);
                                             }
                                         }];
    
    [operation start];
    
}

+ (void)requestOTPUpdateProfileBlock:(void (^)(BOOL isSuccess,NSString *referenceID,NSString *message, NSError *error))block{
    NSString *cmMemberID = @"";
    CMUser *cmUser = [CMUser sharedInstance];
    CMApiClient *client = [CMApiClient sharedInstance];
    if (cmUser.token && cmUser.token.length > 0 ) {
        [client setDefaultHeader:@"token" value:cmUser.token];
        cmMemberID = cmUser.memberId;
    }else{
        block(NO,nil,@"Request OTP fail, please try logout and login again",nil);
        return;
    }
    NSDictionary *params = @{@"memberId":cmMemberID};
    [client setParameterEncoding:AFJSONParameterEncoding];
    NSURLRequest *request =  [client requestWithMethod:@"POST" path:@"otp/updateuserprofile" parameters:params];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             [SVProgressHUD dismiss];
                                             
                                             NSLog(@"requestOTPForUpdateProfile=%@",JSON);
                                             if ([[JSON objectForKey:@"status"] isEqualToString:@"S"]) {
                                                 NSString *referenceID = [JSON objectForKey:@"referenceId"];
                                                 NSString *message = [JSON objectForKey:@"description"]?[JSON objectForKey:@"description"]:@"OTP Code will sent to your email and SMS";
                                                 
                                                 if (block) {
                                                     block(YES,referenceID,message,nil);
                                                 }
                                                 
                                             }else{
                                                 [SVProgressHUD dismiss];
                                                 if (block) {
                                                     NSString *message = [JSON objectForKey:@"description"]?[JSON objectForKey:@"description"]:@"Fail to send OTP code";
                                                     block(NO,nil,message,nil);
                                                 }
                                             }
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"NSError: %@",error.localizedDescription);
                                             [SVProgressHUD dismiss];
                                             if (block) {
                                                 block(NO,nil,@"Error",error);
                                             }
                                         }];
    
    [operation start];
    [SVProgressHUD showWithStatus:@"Loading..."];
    
}


+ (void)confirmUpdateProfileWithOTP:(NSString *)otp referenceID:(NSString *)referenceID firstname:(NSString *)firstname lastname:(NSString *)lastname birthdate:(NSString *)birthdate birthday:(NSString *)birthday birthmonth:(NSString *)birthmonth birthyear:(NSString *)birthyear sex:(NSString *)sex tel:(NSString *)tel email:(NSString *)email Block:(void (^)(BOOL isSuccess,NSString *message, NSError *error))block{
    
    CMUser *cmUser = [CMUser sharedInstance];
    NSDictionary *params = @{@"memberId":cmUser.memberId,@"firstName":firstname,@"lastName":lastname,@"birthday":birthday ,@"birthmonth":birthmonth,@"birthyear":birthyear,@"sex":sex,@"tel":tel,@"email":email};
    
    CMApiClient *client = [CMApiClient sharedInstance];
    if (cmUser.token && cmUser.token.length > 0) {
        [client setDefaultHeader:@"token" value:cmUser.token];
        [client setDefaultHeader:@"otp" value:otp];
        [client setDefaultHeader:@"referenceId" value:referenceID];
    }else{
        block(NO,@"Update profile not success, please try logout and login again",nil);
        return;
    }
    
    [client setParameterEncoding:AFJSONParameterEncoding];
    NSURLRequest *request =  [client requestWithMethod:@"POST" path:@"userprofiles/update" parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             [SVProgressHUD dismiss];
                                             NSLog(@"confirmUpdateProfileWithOTP=%@",JSON);
                                             if ([[JSON objectForKey:@"status"] isEqualToString:@"S"]) {
                                                 
                                                 cmUser.firstName = firstname;
                                                 cmUser.lastName = lastname;
                                                 cmUser.birthDate = birthdate;
                                                 cmUser.email = email;
                                                 cmUser.tel = tel;
                                                 cmUser.sex = sex;
                                                 cmUser.birthDay = birthday;
                                                 cmUser.birthMonth =  birthmonth;
                                                 cmUser.birthYear = birthyear;
                                                 NSLog(@"Successfully UpdateProfile");
                                                 
                                                 if (block) {
                                                     block(YES,@"Update profile sucessfully",nil);
                                                 }
                                             }else{
                                                 [SVProgressHUD dismiss];
                                                 if (block) {
                                                     block(NO,@"Update profile not complete",nil);
                                                 }
                                             }
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             NSLog(@"NSError: %@",error.localizedDescription);
                                             [SVProgressHUD dismiss];
                                             if (block) {
                                                 block(NO,@"Error",error);
                                             }
                                         }];
    
    [operation start];
    [SVProgressHUD showWithStatus:@"Updating..."];
    
}


+ (void)changePasswordWithOldPassword:(NSString *)oldpassword aNewPassword:(NSString *)aNewPasswrod confirmNewPassword:(NSString *)confirmNewPassword Block:(void (^)(BOOL isSuccess,NSString *message, NSError *error))block{
    
    CMUser *cmUser = [CMUser sharedInstance];
    NSString *path = [NSString stringWithFormat:@"userprofiles/changepassword?userName=%@&memberId=%@&password=%@&newPassword=%@",cmUser.userName,cmUser.memberId,oldpassword,aNewPasswrod];
    CMApiClient *client = [CMApiClient sharedInstance];
    
    if (cmUser.token && cmUser.token.length > 0 ) {
        [client setDefaultHeader:@"token" value:cmUser.token];
    }else{
        block(NO,@"Change password not complete, please try logout and login again",nil);
        return;
    }
    
    NSURLRequest *request =  [client requestWithMethod:@"POST" path:path parameters:nil];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                             [SVProgressHUD dismiss];
                                             
                                             if ([[JSON objectForKey:@"status"] isEqualToString:@"S"]) {
                                                 
                                                 NSString *message = [JSON objectForKey:@"description"]?[JSON objectForKey:@"description"]:@"Change Password Success";
                                                 
                                                 if (block) {
                                                     block(YES,message,nil);
                                                 }
                                             }else{
                                                 [SVProgressHUD dismiss];
                                                 NSString *message = [JSON objectForKey:@"description"]?[JSON objectForKey:@"description"]:@"Change password not complete";
                                                 if (block) {
                                                     block(NO,message,nil);
                                                 }
                                             }
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             [SVProgressHUD dismiss];
                                             NSLog(@"NSError: %@",error.localizedDescription);
                                             if (block) {
                                                 block(NO,@"Error",error);
                                             }
                                             
                                         }];
    
    [operation start];
    [SVProgressHUD showWithStatus:@"Updating..."];
}


@end
