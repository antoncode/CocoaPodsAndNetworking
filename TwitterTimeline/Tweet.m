//
//  Tweet.m
//  TwitterTimeline
//
//  Created by Anton Rivera on 3/25/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        self.query = [json objectForKey:@"query"];
        self.count = [json objectForKey:@"count"];
//        
//        NSURL *avatarURL = [NSURL URLWithString:[json[@"owner"] objectForKey:@"avatar_url"]];
//        [self downloadImageForURL:avatarURL];
    }
    return self;
}

//- (void)downloadImageForURL:(NSURL *)url
//{
//    NSOperationQueue *downloadQueue = [NSOperationQueue new];
//    [downloadQueue addOperationWithBlock:^{
//        NSData *avatarData = [NSData dataWithContentsOfURL:url];
//        self.authorAvatar = [UIImage imageWithData:avatarData];
//    }];
//}

@end
