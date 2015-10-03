//
//  UIImage+WebCacheRouned.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 5/30/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "UIImageView+WebCacheRounded.h"
#import "UIImage+RoundedImage.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (WebCacheRounded)

- (void)setImageURL:(NSURL *)imageUrl placeholder:(UIImage *)placeholderImage radius:(CGFloat)radius {
    [self setImageURL:imageUrl placeholder:placeholderImage radius:radius toDisk:NO];
}

- (void)setImageURL:(NSURL *)imageURL placeholder:(UIImage *)placeholderImage radius:(CGFloat)radius toDisk:(BOOL)toDisk
{
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:imageURL.absoluteString done:^(UIImage *image, SDImageCacheType cacheType) {
        if (image) {
            self.image = image;
        }
        else {
            self.image = placeholderImage;
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:imageURL
                                  options:SDWebImageProgressiveDownload
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) { /* progression tracking code */ }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                     if (image && finished) {
                                         UIImage *newImage = [UIImage roundedRectImageFromImage:image withRadious:radius];
                                         
                                         [[SDImageCache sharedImageCache] storeImage:newImage
                                                                              forKey:imageURL.absoluteString];
                                         
                                         self.image = newImage;
                                     }
             }];
        }
    }];
}

@end
