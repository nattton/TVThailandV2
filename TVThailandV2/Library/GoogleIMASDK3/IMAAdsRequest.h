//
//  IMAAdsRequest.h
//  GoogleIMA3
//
//  Copyright (c) 2013 Google Inc. All rights reserved.
//
//  Declares a simple ad request class.

#import <Foundation/Foundation.h>

/// Data class describing the ad request.
@interface IMAAdsRequest : NSObject

/// The ad request URL set.
@property(nonatomic, readonly, copy) NSString *adTagUrl;

/// The companion slots.
@property(nonatomic, readonly, copy) NSArray *companionSlots;

/// The user context.
@property(nonatomic, readonly) id userContext;

/// Initializes an ads request instance with the |adTagUrl| and
/// |companionSlots| specified.
- (id)initWithAdTagUrl:(NSString *)adTagUrl
        companionSlots:(NSArray *)companionSlots
           userContext:(id)userContext;

@end
