//
//  CMCategory.h
//  CloudMedia
//
//  Created by April Smith on 9/29/56 BE.
//  Copyright (c) 2556 April Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMCategory : NSObject

@property (strong, nonatomic) NSString *idCM;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *descriptionOfCM;
@property (strong, nonatomic) NSString *thumbnail;


-(id) initWithidOfCM:(NSString *)newID
               title:(NSString *)newTitle
         description:(NSString *)newDescription
           thumbnail:(NSString *)newThumbnail;

+(CMCategory *)categoryWithidOfCM:(NSString *)newID
                            title:(NSString *)newTitle
                      description:(NSString *)newDescription
                        thumbnail:(NSString *)newThumbnail;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (void)loadCMCategory:(NSUInteger)start Block:(void (^)(NSArray *cmCategories, NSError *error))block;


@end
