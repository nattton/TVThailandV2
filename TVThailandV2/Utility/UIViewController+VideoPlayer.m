//
//  UIViewController+VideoPlayer.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 7/25/55 BE.
//  Copyright (c) 2555 luciferultram@gmail.com. All rights reserved.
//

#import "UIViewController+VideoPlayer.h"

#import "YoutubeViewController.h"
#import "DailyMotionViewController.h"
#import "HTML5PlayerViewController.h"

#import "UserAgent.h"

#import "SBJson.h"
#import "HTMLparser.h"

#import "MBProgressHUD.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation UIViewController (VideoPlayer)

- (NSString *)videoURLWithVideoId:(NSString *)videoId andSrcType:(NSString *)src_type
{
    if([src_type isEqualToString:@"0"])
    {
        return [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",videoId];
    }
    else if([videoId isEqualToString:@"1"])
    {
        return [NSString stringWithFormat:@"http://www.dailymotion.com/video/%@?autoplay=1",videoId];
    }
    else if([src_type isEqualToString:@"2"])
    {
        return [NSString stringWithFormat:@"http://video.mthai.com/player.php?id=%@",videoId];
    }
    else if([src_type isEqualToString:@"3"])
    {
        return [NSString stringWithFormat:@"http://vimeo.com/%@",videoId];
    }
    else if([src_type isEqualToString:@"13"])
    {
        return [NSString stringWithFormat:@"http://video.mthai.com/get_config_event.php?id=%@",videoId];
    }
    else if([src_type isEqualToString:@"14"])
    {
        return [NSString stringWithFormat:@"http://video.mthai.com/player.php?id=24M%@M0",videoId];
    }
    else if([src_type isEqualToString:@"15"])
    {
        return [NSString stringWithFormat:@"http://video.mthai.com/player.php?id=24M%@M0",videoId];
    }
    else
    {
        return [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",videoId];
    }
}

- (NSString *)videoThumbnailWithVideoId:(NSString *)videoId andSrcType:(NSString *)src_type
{
    if([src_type isEqualToString:@"0"])
    {
        return [NSString stringWithFormat:@"http://i.ytimg.com/vi/%@/default.jpg",videoId];
    }
    else if([src_type isEqualToString:@"1"])
    {
        return [NSString stringWithFormat:@"http://www.dailymotion.com/thumbnail/160x120/video/%@",videoId];
    }
    else if([src_type isEqualToString:@"2"])
    {   
        return [NSString stringWithFormat:@"http://video.mthai.com/thumbnail/%@.jpg",
                [videoId substringWithRange:NSMakeRange(3, ([videoId length]-2))]];
    }
    else if ([src_type isEqualToString:@"13"] 
             || [src_type isEqualToString:@"14"]
             || [src_type isEqualToString:@"15"]
             || [src_type isEqualToString:@"mthai"])
    {
        return [NSString stringWithFormat:@"http://video.mthai.com/thumbnail/%@.jpg",videoId];
    }
    else
    {
        return @"http://www.makathon.com/placeholder.png";
    }
}

- (void) openVideoWithTitle:(NSString *)title SrcType:(NSString *)srcType VideoId:(NSString *)videoId Password:(NSString *)password
{
    if ([srcType isEqualToString:@"0"])
    {
        [self openYoutube:videoId andTitle:title];
    }
    else if ([srcType isEqualToString:@"1"])
    {
        [self openDailyMotion:videoId andTitle:title];
    }
        else if ([srcType isEqualToString:@"2"] || [srcType isEqualToString:@"3"])
        {
            NSString *url = [self videoURLWithVideoId:videoId andSrcType:srcType];
//            TTWebController *webController = [[TTWebController alloc] init];
//            [webController openURL:[NSURL URLWithString:url]];
//            [self.navigationController pushViewController:webController animated:YES];
        }
        else if ([srcType isEqualToString:@"11"])
        {
            NSURL *urlVideo = [NSURL URLWithString:videoId];
//            TTWebController *webContrller = [[TTWebController alloc] init];
//            [webContrller setTitle:title];
//            [webContrller openURL:urlVideo];
//            [self.navigationController pushViewController:webContrller animated:YES];
            
        }
        else if ([srcType isEqualToString:@"12"])
        {
            NSURL *urlVideo = [NSURL URLWithString:videoId];
            [self startVideo:urlVideo withTitle:title andPoster:@""];
            
        }
        else if ([srcType isEqualToString:@"13"])
        {
            NSString *url = [self videoURLWithVideoId:videoId andSrcType:srcType];
            [self loadMThaiVideo:videoId url:url withTitle:title];
        }
        else if ([srcType isEqualToString:@"14"])
        {
            NSString *url = [self videoURLWithVideoId:videoId andSrcType:srcType];
            [self loadMThaiVideoWeb:videoId url:url withTitle:title];
        }
        else if ([srcType isEqualToString:@"15"])
        {
            NSString *url = [self videoURLWithVideoId:videoId andSrcType:srcType];
            [self loadMThaiVideoPassword:videoId url:url password:password withTitle:title];
        }
        else
        {
//            TTWebController *webController = [[TTWebController alloc] init];
//            [webController setTitle:@"TV Thailand Fan Page"];
//            [webController openURL:[NSURL URLWithString:kWebUrl]];
//            [self.navigationController pushViewController:webController animated:YES];
        }
}

- (BOOL)isPad
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

- (void)openYoutube:(NSString *)video_id andTitle:(NSString *)title
{
    NSString *nibName = ([self isPad])?@"YoutubeViewController_iPad":@"YoutubeViewController_iPhone";
    YoutubeViewController *youtubeViewController = [[YoutubeViewController alloc] initWithNibName:nibName bundle:nil];
    [youtubeViewController setVideoTitle:title];
    [youtubeViewController setVideoId:video_id];
    [self.navigationController pushViewController:youtubeViewController animated:YES];
}
- (void)openDailyMotion:(NSString *)video_id andTitle:(NSString *)title
{
    NSString *nibName = ([self isPad])?@"DailyMotionViewController_iPad":@"DailyMotionViewController_iPhone";
    DailyMotionViewController *dailyMotionViewController = [[DailyMotionViewController alloc] initWithNibName:nibName bundle:nil];
    dailyMotionViewController.videoId = video_id;
    dailyMotionViewController.videoTitle = title;
    [self.navigationController pushViewController:dailyMotionViewController animated:YES];
}

- (void) startVideo:(NSURL *)urlVideo withTitle:(NSString *)title andPoster:(NSString *)poster
{
    
//    NSLog(@"%@",[urlVideo absoluteString]);
    
    NSString *nibName = ([self isPad])?@"HTML5PlayerViewController_iPad":@"HTML5PlayerViewController_iPhone";
    
    HTML5PlayerViewController *html5player = [[HTML5PlayerViewController alloc] initWithNibName:nibName bundle:nil];
    html5player.videoTitle = title;
    html5player.videoUrl = [urlVideo absoluteString];
    html5player.videoPoster = poster;
    [self.navigationController pushViewController:html5player animated:YES];
    
}

- (void) startMThaiVideoFromHTML:(NSString *)html andVideoId:(NSString *)videoId withTitle:(NSString *)title
{
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *sourceNodes = [bodyNode findChildTags:@"source"];
    
    for (HTMLNode *sourceNode in sourceNodes)
    {
        if ([sourceNode getAttributeNamed:@"src"]) {
            NSString *videoUrl = [NSString stringWithString:[sourceNode getAttributeNamed:@"src"]];
            NSArray *saperateUrl = [videoUrl componentsSeparatedByString:@"/"];
            if ([[saperateUrl lastObject] hasPrefix:videoId]) {
                if ([[saperateUrl lastObject] hasSuffix:@"flv"]) {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    
                    // Configure for text only and offset down
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = [NSString stringWithFormat:@"iOS Cannot Play FLV File"];
                    hud.margin = 10.f;
                    hud.yOffset = 150.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:1];
                    return;
                }else {
                    [self startVideo:[NSURL URLWithString:videoUrl] withTitle:title andPoster:[self videoThumbnailWithVideoId:videoId andSrcType:@"mthai"]];
                } 
                return;
            }
        }
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [NSString stringWithFormat:@"iOS Cannot Play Video"];
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
}

- (void) loadMThaiVideo:(NSString *)videoId url:(NSString *)videoApiUrl withTitle:(NSString *)title
{
    
    NSURL *urlMThai = [NSURL URLWithString:videoApiUrl];
    
    for (NSUInteger i = 0; i < 5; i++) {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlMThai];
        [request setUserAgentString:[UserAgent defaultUserAgent]];
        [request startSynchronous];
        
        NSString *response = [[[request responseString] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];

        NSDictionary *dict = [response JSONValue];
        if(dict)
        {
            NSString *videoUrl = [[[dict objectForKey:@"playlist"] objectAtIndex:1] objectForKey:@"url"];
            NSArray *saperateUrl = [videoUrl componentsSeparatedByString:@"/"];
            NSString *videoFile = [saperateUrl lastObject];
            if ([videoFile hasPrefix:videoId]) {
                if ([[saperateUrl lastObject] hasSuffix:@"flv"]) {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    
                    // Configure for text only and offset down
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = [NSString stringWithFormat:@"iOS Cannot Play FLV File"];
                    hud.margin = 10.f;
                    hud.yOffset = 150.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:1];
                    
                }else {
                    [self startVideo:[NSURL URLWithString:videoUrl] withTitle:title andPoster:[self videoThumbnailWithVideoId:videoId andSrcType:@"mthai"]];
                }  
                return;
            }
            else {
                if (i == 4) {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    // Configure for text only and offset down
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = [NSString stringWithFormat:@"Video not found"];
                    hud.margin = 10.f;
                    hud.yOffset = 150.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    [hud hide:YES afterDelay:1];
                }
            }        
        }
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [NSString stringWithFormat:@"Cannot Play Video"];
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1];
    
}

- (void) loadMThaiVideoWeb:(NSString *)videoId url:(NSString *)videoApiUrl withTitle:(NSString *)title
{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSURL *urlMThai = [NSURL URLWithString:videoApiUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlMThai];
    [request setDelegate:self];
    [request setUserAgentString:[UserAgent defaultUserAgent]];
    [request startSynchronous];
    
    [self startMThaiVideoFromHTML:[request responseString] andVideoId:videoId withTitle:title];
    
}

- (void) loadMThaiVideoPassword:(NSString *)videoId url:(NSString *)videoApiUrl password:(NSString *)pwd withTitle:(NSString *)title
{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSURL *urlMThai = [NSURL URLWithString:videoApiUrl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:urlMThai];
    [request setDelegate:self];
    [request setUserAgentString:[UserAgent defaultUserAgent]];
    [request setPostValue:pwd forKey:@"clip_password"];
    [request startSynchronous];
    
    [self startMThaiVideoFromHTML:[request responseString] andVideoId:videoId withTitle:title];
}

@end
