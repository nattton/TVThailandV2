//
//  AdsClient.m
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 4/3/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "CMVideoAds.h"
#import "AFHTTPRequestOperationManager.h"
#import "NSString+Utils.h"

@interface CMVideoAds () <NSXMLParserDelegate>

@end

NSString * const kTrackingEventTypeArray[] = {
    @"complete",
    @"start",
    @"midpoint",
    @"firstQuartile",
    @"thirdQuartile",
    @"pause",
    @"replay",
    @"fullscreen",
    @"stop",
    @"resume",
    @"mute",
    @"unmute"
};

@implementation CMVideoAds {
    NSString *currentTag;
    NSString *currentEvent;
    NSString *currentMediaFileType;
    
    NSMutableDictionary *tempTrackingEvents;
}

static NSString *kVast = @"VAST";
static NSString *kVASTAdTagURI = @"VASTAdTagURI";
static NSString *kAdTitle = @"AdTitle";
static NSString *kImpression = @"Impression";
static NSString *kClickThrough = @"ClickThrough";
static NSString *kTrackingEvents = @"TrackingEvents";
static NSString *kTracking = @"Tracking";
static NSString *kEvent = @"event";
static NSString *kMediaFile = @"MediaFile";
static NSString *kType = @"type";
static NSString *kMediaTypeMP4 = @"mp4";
static NSString *kMediaFileMP4 = @"video/mp4";
static NSString *kMediaFileXMP4 = @"video/x-mp4";

-(NSString *) trackingTypeEnumToString:(kTrackingEventType)eventType
{
    return kTrackingEventTypeArray[eventType];
}

-(kTrackingEventType) trackingEventTypeStringToEnum:(NSString*)string
{
    int retVal = 0;
    for(int i=0; i < sizeof(kTrackingEventTypeArray)-1; i++)
    {
        if([(NSString*)kTrackingEventTypeArray[i] isEqual:string])
        {
            retVal = i;
            break;
        }
    }
    return (kTrackingEventType)retVal;
}

- (id)initWithVastTagURL:(NSString *)url {
    self = [super init];
    if (self) {
        [self loadWithVastTagURL:url];
    }
    return self;
}

- (void)loadWithVastTagURL:(NSString *)url {
    NSString *vastURL = [url stringByReplacingOccurrencesOfString:@"[timestamp]"
                                                       withString:[NSString getUnixTime]];
    self.vastAdTagURI = nil;
    
    self.vastURL = vastURL;
    tempTrackingEvents = [[NSMutableDictionary alloc] init];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer = requestSerializer;
    
    [manager GET:vastURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSXMLParser *vastXml = (NSXMLParser *)responseObject;
             vastXml.delegate = self;
             BOOL result = [vastXml parse];
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"failure with error %@",error);
             if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestVideoAds:error:)]) {
                 [self.delegate didRequestVideoAds:self error:error];
             }
             
         }];
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    currentTag = elementName;
    
    if ([elementName isEqualToString:kTracking]) {
        currentEvent = [attributeDict objectForKey:kEvent];
        return;
    }
    else if ([elementName isEqualToString:kMediaFile]) {
        currentMediaFileType = [attributeDict objectForKey:kType];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
//    if ([currentTag isEqualToString:kAdTitle]) {
//        DLog(@"found char : %@", string);
//        self.adTitle = string;
//    }
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    if ([currentTag isEqualToString:kAdTitle]) {
        self.adTitle = [NSString stringWithUTF8String:[CDATABlock bytes]];
        return;
    }
    else if ([currentTag isEqualToString:kImpression]) {
        self.impression = [NSString stringWithUTF8String:[CDATABlock bytes]];
        return;
    }
    else if ([currentTag isEqualToString:kVASTAdTagURI]) {
        self.vastAdTagURI = [NSString stringWithUTF8String:[CDATABlock bytes]];
        return;
    }
    else if ([currentTag isEqualToString:kClickThrough]) {
        self.clickThrough = [NSString stringWithUTF8String:[CDATABlock bytes]];
        return;
    }
    else if ([currentTag isEqualToString:kTracking]) {
        if (currentEvent) {
            [tempTrackingEvents setValue:[NSString stringWithUTF8String:[CDATABlock bytes]] forKey:currentEvent];
            return;
        }
    }
    else if ([currentTag isEqualToString:kMediaFile]) {
        if (currentMediaFileType && [currentMediaFileType hasSuffix:kMediaTypeMP4]) {
            self.mediaFile = [NSString stringWithUTF8String:[CDATABlock bytes]];
            return;
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:kTrackingEvents]) {
        self.trackingEvents = [[NSDictionary alloc] initWithDictionary:tempTrackingEvents];
        return;
    }
    else if ([elementName isEqualToString:kVast]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestVideoAds:success:)]) {
            
            if (self.mediaFile)
            {
                [self.delegate didRequestVideoAds:self success:YES];
            }
            else if(self.vastAdTagURI)
            {
                [self loadWithVastTagURL:self.vastAdTagURI];
            }
            else
            {
                [self.delegate didRequestVideoAds:self success:NO];
            }

        }
        return;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"AdTitle : %@\nImpresion : %@\nVASTAdTagURI : %@\nClickThrough : %@\nMediaFile : %@\nTrackingEvents : %@",
            self.adTitle, self.impression, self.vastAdTagURI, self.clickThrough, self.mediaFile, self.trackingEvents];
}

#pragma mark - Hit Request

- (void) hitTrackingEvent:(kTrackingEventType)eventType {
    if (eventType == START
        && self.impression != nil
        && ![self.impression isEqualToString:@""]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.impression]];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
//             DLog(@"%@", data);
         }];
    }
    
    NSString * eventString = [self trackingTypeEnumToString:eventType];
    NSString *urlEvent = [self.trackingEvents objectForKey:eventString];
    if (urlEvent) {
        NSURL *URL = [NSURL URLWithString:urlEvent];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
        {
//            DLog(@"%@", data);
        }];
        
//        [[AFHTTPRequestOperationManager manager]
//         GET:urlEvent
//         parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             
//         }
//         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             
//         }
//         ];
    }
}

@end
