//
//  CMUser.m
//  TVThailandV2
//
//  Created by April Smith on 3/4/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "CMUser.h"

@implementation CMUser

NSString * const kFbId = @"id";
NSString * const kDisplayName = @"name";
NSString * const kUsername = @"username";
NSString * const kLocation = @"location";
NSString * const kEmail = @"email";
NSString * const kFirstName = @"first_name";
NSString * const kLastName = @"last_name";
NSString * const kBirthday = @"birthday";
NSString * const kGender = @"gender";

- (NSString *)description {
    return [NSString stringWithFormat:@"fbId:%@, displayName:%@, username:%@, location:%@, email:%@, firstName:%@, lastName:%@, birthday:%@, gender:%@",_fbId, _displayName, _username, _location, _email, _firstName, _lastName, _birthday, _gender];
}

+ (CMUser *) sharedInstance {
    
    static CMUser *_sharedCMUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCMUser = [[CMUser alloc]initWithSaved];
    });
    
    return _sharedCMUser;
}

- (id) initWithSaved {
    self = [super init];
    if (self) {
        [self reloadFromSaved];
    }
    return self;
}

- (void) setWithDictionary:(NSDictionary *)dictionary {
    
    _fbId = [dictionary objectForKey:kFbId];
    _displayName = [dictionary objectForKey:kDisplayName];
    _username = [dictionary objectForKey:kUsername];
    _location = [[dictionary objectForKey:kLocation]name];
    _email = [dictionary objectForKey:kEmail];
    _firstName = [dictionary objectForKey:kFirstName];
    _lastName = [dictionary objectForKey:kLastName];
    _birthday = [dictionary objectForKey:kBirthday];
    _gender = [dictionary objectForKey:kGender];
    
    [self save];
    
}

- (void) reloadFromSaved {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _fbId = [defaults stringForKey:kFbId];
    _displayName = [defaults stringForKey:kDisplayName];
    _username = [defaults stringForKey:kUsername];
    _location = [defaults stringForKey:kLocation];
    _email = [defaults stringForKey:kEmail];
    _firstName = [defaults stringForKey:kFirstName];
    _lastName = [defaults stringForKey:kLastName];
    _birthday = [defaults stringForKey:kBirthday];
    _gender = [defaults stringForKey:kGender];
    
}

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_fbId forKey:kFbId];
    [defaults setObject:_displayName forKey:kDisplayName];
    [defaults setObject:_username forKey:kUsername];
    [defaults setObject:_location forKey:kLocation];
    [defaults setObject:_email forKey:kEmail];
    [defaults setObject:_firstName forKey:kFirstName];
    [defaults setObject:_lastName forKey:kLastName];
    [defaults setObject:_birthday forKey:kBirthday];
    [defaults setObject:_gender forKey:kGender];
    
    //TODO: save all model
    [defaults synchronize];
}

- (void) clear {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@"" forKey:kFbId];
    [defaults setObject:@"" forKey:kDisplayName];
    [defaults setObject:@"" forKey:kUsername];
    [defaults setObject:@"" forKey:kLocation];
    [defaults setObject:@"" forKey:kEmail];
    [defaults setObject:@"" forKey:kFirstName];
    [defaults setObject:@"" forKey:kLastName];
    [defaults setObject:@"" forKey:kBirthday];
    [defaults setObject:@"" forKey:kGender];
    
    [defaults synchronize];
    
    [self reloadFromSaved];
}


#pragma mark - set data & save

- (void)setFbId:(NSString *)fbId {
    _fbId = fbId;
    NSUserDefaults *deafults = [NSUserDefaults standardUserDefaults];
    [deafults setObject:fbId forKey:kFbId];
    [deafults synchronize];
}

- (void)setDisplayName:(NSString *)displayName {
    _displayName = displayName;
    NSUserDefaults *deafults = [NSUserDefaults standardUserDefaults];
    [deafults setObject:displayName forKey:kDisplayName];
    [deafults synchronize];
    
}

- (void)setUsername:(NSString *)username {
    _username = username;
    NSUserDefaults *deafults = [NSUserDefaults standardUserDefaults];
    [deafults setObject:username forKey:kUsername];
    [deafults synchronize];
}

- (void)setLocation:(NSString *)location {
    _location = location;
    NSUserDefaults *deafults = [NSUserDefaults standardUserDefaults];
    [deafults setObject:location forKey:kLocation];
    [deafults synchronize];
}

- (void)setEmail:(NSString *)email {
    _email = email;
    NSUserDefaults *deafults = [NSUserDefaults standardUserDefaults];
    [deafults setObject:email forKey:kEmail];
    [deafults synchronize];
}

- (void)setFirstName:(NSString *)firstName {
    _firstName = firstName;
    NSUserDefaults *deafults = [NSUserDefaults standardUserDefaults];
    [deafults setObject:firstName forKey:kFirstName];
    [deafults synchronize];
}

- (void)setLastName:(NSString *)lastName {
    _lastName = lastName;
    NSUserDefaults *deafults = [NSUserDefaults standardUserDefaults];
    [deafults setObject:lastName forKey:kLastName];
    [deafults synchronize];
}

- (void)setBirthday:(NSString *)birthday {
    _birthday = birthday;
    NSUserDefaults *deafults = [NSUserDefaults standardUserDefaults];
    [deafults setObject:birthday forKey:kBirthday];
    [deafults synchronize];
}

- (void)setGender:(NSString *)gender {
    _gender = gender;
    NSUserDefaults *deafults = [NSUserDefaults standardUserDefaults];
    [deafults setObject:gender forKey:kGender];
    [deafults synchronize];
}

@end
