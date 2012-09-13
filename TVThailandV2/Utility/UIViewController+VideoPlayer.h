//
//  UIViewController+VideoPlayer.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/25/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (VideoPlayer)

- (void) openVideoWithTitle:(NSString *)title SrcType:(NSString *)srcType VideoId:(NSString *)videoId Password:(NSString *)password;

- (NSString *)videoURLWithVideoId:(NSString *)videoId andSrcType:(NSString *)src_type;
- (NSString *)videoThumbnailWithVideoId:(NSString *)videoId andSrcType:(NSString *)srcType;
@end
