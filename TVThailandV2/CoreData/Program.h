//
//  Program.h
//  tvthai
//
//  Created by Nattapong Tonprasert on 11/9/11.
//  Copyright (c) 2011 Makathon Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Program : NSManagedObject

@property (nonatomic, strong) NSString * program_id;
@property (nonatomic, strong) NSString * program_title;
@property (nonatomic, strong) NSString * program_thumbnail;
@property (nonatomic, strong) NSString * program_time;

@end
