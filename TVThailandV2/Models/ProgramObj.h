//
//  Program.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/3/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProgramObj : NSObject

@property (readonly, nonatomic) NSString *Id;
@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) NSString *description;
@property (readonly, nonatomic, unsafe_unretained) NSURL *imageURL;

+ (void)getDataWithCatId:(NSString *)catId start:(NSInteger)start :(void (^)(NSArray *programs, NSError *error))block;

@end
