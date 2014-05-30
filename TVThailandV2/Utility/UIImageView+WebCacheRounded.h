//
//  UIImage+WebCacheRouned.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/30/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (WebCacheRounded)

- (void)setImageURL:(NSURL *)imageUrl placeholder:(UIImage *)placeholderImage radius:(CGFloat)radius;
- (void)setImageURL:(NSURL *)imageUrl placeholder:(UIImage *)placeholderImage radius:(CGFloat)radius toDisk:(BOOL)toDisk;
@end
