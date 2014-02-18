//
//  NSString+Utils.m
//  TV_Thailand
//
//  Created by Nattapong Tonprasert on 1/12/12.
//  Copyright (c) 2012 luciferultram@gmail.com. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

+(NSString *)getDevice
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)?@"ipad":@"iphone";
}

+ (NSString *)getUnixTime
{
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    DLog(@"getUnixTime : %@",[NSString stringWithFormat:@"%.0f",ti]);
    return [NSString stringWithFormat:@"%.0f",ti];
}

+ (NSString *)getUnixTimeKey
{
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    DLog(@"getUnixTimeKey : %@",[NSString stringWithFormat:@"%.0f",ti/10.0]);
    return [NSString stringWithFormat:@"%.0f",ti/10.0];
}


@end
