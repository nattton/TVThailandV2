//
//  Program.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/3/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "ProgramObj.h"
#import "ApiClient.h"

@implementation ProgramObj {
@private
    NSString *_imageURL;
}

@synthesize Id = _Id;
@synthesize title = _title;
@synthesize description = _description;

- (id)initWithDictionary:(NSDictionary *)dictionary ImagePath:(NSString *)imagePath {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _Id = [dictionary valueForKeyPath:@"program_id"];
    _title = [dictionary valueForKeyPath:@"title"];
    _description = [dictionary valueForKeyPath:@"time"];
    _imageURL = [NSString stringWithFormat:@"%@%@", imagePath , [dictionary valueForKeyPath:@"thumbnail"]];
    
    return self;
}

- (NSURL *)imageURL {
    return [NSURL URLWithString:_imageURL];
}

#pragma -

+ (void)getDataWithCatId:(NSString *)catId start:(NSInteger)start :(void (^)(NSArray *programs, NSError *error))block {
    [[ApiClient sharedInstance] getPath:[NSString stringWithFormat:@"api/getProgram/%@/%d", catId, start] parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
//        NSLog(@"Response: %@", JSON);
        NSString *imagePath = [JSON valueForKey:@"thumbnail_path"];
        NSArray *programsFromResponse = [JSON valueForKey:@"programs"];

        NSMutableArray *mutablePrograms = [NSMutableArray arrayWithCapacity:[programsFromResponse count]];
        for (NSDictionary *dictionary in programsFromResponse) {
            ProgramObj *program = [[ProgramObj alloc] initWithDictionary:dictionary ImagePath:imagePath];
            [mutablePrograms addObject:program];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutablePrograms], nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];

}

@end
